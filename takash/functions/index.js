const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

// ============================================================
// Helper: Kullanıcının FCM token'larını al
// ============================================================
async function getUserFcmTokens(userId) {
  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) return [];

  const data = userDoc.data();
  const tokens = data?.fcmTokens || [];

  // Eski fcmToken alanını da kontrol et (migration için)
  if (data?.fcmToken && !tokens.includes(data.fcmToken)) {
    tokens.push(data.fcmToken);
  }

  return tokens.filter((t) => t && t.length > 0);
}

// ============================================================
// Helper: Geçersiz token'ları kullanıcıdan sil
// ============================================================
async function removeInvalidToken(userId, invalidToken) {
  const userRef = db.collection("users").doc(userId);
  const userDoc = await userRef.get();
  const data = userDoc.data();

  // fcmTokens array'den sil
  if (data?.fcmTokens && data.fcmTokens.includes(invalidToken)) {
    await userRef.update({
      fcmTokens: admin.firestore.FieldValue.arrayRemove(invalidToken),
    });
  }

  // Eski fcmToken alanını sil
  if (data?.fcmToken === invalidToken) {
    await userRef.update({
      fcmToken: admin.firestore.FieldValue.delete(),
    });
  }
}

// ============================================================
// Helper: Bildirim gönder (çoklu token desteği)
// ============================================================
async function sendNotification(userId, payload, channelType) {
  const tokens = await getUserFcmTokens(userId);
  if (tokens.length === 0) {
    functions.logger.warn(`Kullanıcının token'ı yok: ${userId}`);
    return;
  }

  // Data'ya channel_id ekle (Flutter local notification için)
  payload.data = payload.data || {};
  payload.data.android_channel_id = channelType;

  const invalidTokens = [];

  for (const token of tokens) {
    try {
      const messagePayload = { ...payload, token };
      await admin.messaging().send(messagePayload);
    } catch (error) {
      functions.logger.error(
        `FCM gönderme hatası (${token}): ${error.code} - ${error.message}`
      );
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        invalidTokens.push(token);
      }
    }
  }

  // Geçersiz token'ları temizle
  for (const invalidToken of invalidTokens) {
    await removeInvalidToken(userId, invalidToken);
  }
}

// ============================================================
// 1. YENİ MESAJ → Karşı tarafa push notification gönder
// ============================================================
exports.onNewMessage = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const { chatId } = context.params;
    const senderId = message.senderId;

    // Sohbeti bul
    const chatDoc = await db.collection("chats").doc(chatId).get();
    if (!chatDoc.exists) return null;

    const chatData = chatDoc.data();
    const participants = chatData.participants || [];

    // Alıcıyı bul (göndermeyen kişi)
    const receiverId = participants.find((id) => id !== senderId);
    if (!receiverId) return null;

    // Gönderenin adını al
    const senderDoc = await db.collection("users").doc(senderId).get();
    const senderName = senderDoc.exists
      ? senderDoc.data().displayName
      : "Biri";

    // Bildirim mesajı
    const notificationBody =
      message.type === "image"
        ? "📷 Fotoğraf gönderdi"
        : message.text;

    // In-app notification kaydet
    const notificationRef = db.collection("notifications").doc();
    await notificationRef.set({
      id: notificationRef.id,
      userId: receiverId,
      type: "newMessage",
      title: senderName,
      body: notificationBody,
      relatedId: chatId,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Push notification gönder
    const payload = {
      notification: {
        title: senderName,
        body: notificationBody,
      },
      data: {
        type: "newMessage",
        chatId: chatId,
        relatedId: chatId,
        senderId: senderId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "chat_messages",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    await sendNotification(receiverId, payload, "chat_messages");
    functions.logger.info(`Mesaj bildirimi gönderildi: ${receiverId}`);

    return null;
  });

// ============================================================
// 2. YENİ TEKLİF → İlan sahibine push notification gönder
// ============================================================
exports.onNewOffer = functions.firestore
  .document("offers/{offerId}")
  .onCreate(async (snap, context) => {
    const offer = snap.data();
    const { offerId } = context.params;
    const offererId = offer.offererId;
    const listingId = offer.listingId;

    // İlanı bul
    const listingDoc = await db
      .collection("listings")
      .doc(listingId)
      .get();
    if (!listingDoc.exists) return null;

    const listingData = listingDoc.data();
    const ownerId = listingData.ownerId;
    const listingTitle = listingData.title;

    // Teklif verenin adını al
    const offererDoc = await db
      .collection("users")
      .doc(offererId)
      .get();
    const offererName = offererDoc.exists
      ? offererDoc.data().displayName
      : "Biri";

    // In-app notification kaydet
    const notificationRef = db.collection("notifications").doc();
    await notificationRef.set({
      id: notificationRef.id,
      userId: ownerId,
      type: "newOffer",
      title: "Yeni Teklif!",
      body: `${offererName} ilanınıza teklif gönderdi: "${listingTitle}"`,
      relatedId: listingId,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Push notification gönder
    const payload = {
      notification: {
        title: "Yeni Teklif! 🎉",
        body: `${offererName} ilanınıza teklif gönderdi`,
      },
      data: {
        type: "newOffer",
        offerId: offerId,
        listingId: listingId,
        relatedId: listingId,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "offers",
        },
      },
    };

    await sendNotification(ownerId, payload, "offers");
    functions.logger.info(`Teklif bildirimi gönderildi: ${ownerId}`);

    return null;
  });

// ============================================================
// 3. TAKAS TAMAMLANDI → Her iki tarafa da push notification
// ============================================================
exports.onTradeCompleted = functions.firestore
  .document("listings/{listingId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Sadece status "completed" olduysa tetikle
    if (before.status !== "completed" && after.status === "completed") {
      const { listingId } = context.params;
      const ownerId = after.ownerId;
      const listingTitle = after.title;

      // İlgili sohbeti bul
      const chatSnapshot = await db
        .collection("chats")
        .where("listingId", "==", listingId)
        .limit(1)
        .get();

      const participants = [ownerId];
      if (!chatSnapshot.empty) {
        const chatData = chatSnapshot.docs[0].data();
        chatData.participants.forEach((id) => {
          if (!participants.includes(id)) participants.push(id);
        });
      }

      // Her katılımcıya bildirim gönder
      for (const userId of participants) {
        // In-app notification
        const notificationRef = db.collection("notifications").doc();
        await notificationRef.set({
          id: notificationRef.id,
          userId: userId,
          type: "tradeCompleted",
          title: "Takas Tamamlandı! ✅",
          body: `"${listingTitle}" takası başarıyla tamamlandı.`,
          relatedId: listingId,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Push notification
        const payload = {
          notification: {
            title: "Takas Tamamlandı! ✅",
            body: `"${listingTitle}" takası başarıyla tamamlandı. Puanlamayı unutmayın!`,
          },
          data: {
            type: "tradeCompleted",
            listingId: listingId,
            relatedId: listingId,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: "high",
            notification: {
              sound: "default",
              channelId: "trades",
            },
          },
        };

        await sendNotification(userId, payload, "trades");
      }

      functions.logger.info(
        `Takas tamamlanma bildirimi gönderildi: ${listingId}`
      );
    }

    return null;
  });

// ============================================================
// 4. YENİ PUANLAMA → Puanlanan kişiye push notification
// ============================================================
exports.onNewRating = functions.firestore
  .document("ratings/{ratingId}")
  .onCreate(async (snap, context) => {
    const rating = snap.data();
    const { ratingId } = context.params;
    const fromUserId = rating.fromUserId;
    const toUserId = rating.toUserId;
    const score = rating.score;

    // Puanlayan kişinin adını al
    const fromUserDoc = await db
      .collection("users")
      .doc(fromUserId)
      .get();
    const fromUserName = fromUserDoc.exists
      ? fromUserDoc.data().displayName
      : "Biri";

    // Yıldız string'i oluştur
    const stars = "⭐".repeat(score);

    // In-app notification kaydet
    const notificationRef = db.collection("notifications").doc();
    await notificationRef.set({
      id: notificationRef.id,
      userId: toUserId,
      type: "newRating",
      title: "Yeni Puanlama!",
      body: `${fromUserName} sizi puanladı: ${stars} (${score}/5)`,
      relatedId: rating.listingId || "",
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Push notification gönder
    const payload = {
      notification: {
        title: "Yeni Puanlama! ⭐",
        body: `${fromUserName} sizi ${score}/5 olarak puanladı`,
      },
      data: {
        type: "newRating",
        ratingId: ratingId,
        relatedId: rating.listingId || "",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "ratings",
        },
      },
    };

    await sendNotification(toUserId, payload, "ratings");
    functions.logger.info(`Puanlama bildirimi gönderildi: ${toUserId}`);

    return null;
  });

// ============================================================
// 5. PERİYODİK TEMİZLİK → 30 günden eski okunmuş bildirimleri sil
// ============================================================
exports.cleanupOldNotifications = functions.pubsub
  .schedule("every 24 hours")
  .timeZone("Europe/Istanbul")
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const snapshot = await db
      .collection("notifications")
      .where("isRead", "==", true)
      .where("createdAt", "<", thirtyDaysAgo)
      .limit(500)
      .get();

    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    functions.logger.info(
      `${snapshot.size} eski bildirim temizlendi`
    );

    return null;
  });
