# Faz 4: Firebase Tabanlı Sohbet Sistemi — Uygulama Planı

## 📌 Genel Bakış
~~Stream Chat SDK~~ yerine **Firestore + Firebase Storage** kullanarak sıfır ek maliyetli bir sohbet sistemi kurulacak. Zaten projede Firebase altyapısı mevcut, ekstra SDK veya Cloud Function gerekmeyecek.

**Avantajları:**
- 💰 Sıfır ek maliyet (Firebase free tier içinde)
- 🔧 Halihazırda kurulu altyapı (Firestore, Storage, Auth)
- 🎯 Tam kontrol (premium özellikler kolayca eklenebilir)
- 📦 `stream_chat_flutter` bağımlılığı kaldırılacak → APK boyutu küçülecek

---

## 📊 Firestore Veri Yapısı

```
chats/{chatId}
  - participants: string[]     ← [uid1, uid2]
  - participantNames: map      ← {uid1: "Ali", uid2: "Ayşe"}
  - participantPhotos: map     ← {uid1: "url", uid2: "url"}
  - listingId: string?         ← İlgili ilan (opsiyonel)
  - listingTitle: string?      ← İlan başlığı (önizleme için)
  - lastMessage: string
  - lastMessageAt: timestamp
  - createdAt: timestamp
  - imageCount: number         ← Gönderilen resim sayacı (sınır için)

chats/{chatId}/messages/{messageId}
  - senderId: string
  - text: string
  - imageUrl: string?          ← Resim mesajı (opsiyonel)
  - type: string               ← "text" | "image" | "offer"
  - createdAt: timestamp
  - isRead: bool
```

> **Kanal ID Stratejisi:** `generateChatId(uid1, uid2)` → UID'leri alfabetik sırala ve birleştir. Aynı iki kişi arasında her zaman aynı chat ID.

---

## 🚀 Uygulama Adımları

### Adım 1 — Veri Modelleri
#### [NEW] `lib/features/chat/domain/chat_model.dart`
- `ChatModel` — Sohbet odası modeli (participants, lastMessage, listingId, imageCount vs.)
- `fromJson/toJson/copyWith`

#### [NEW] `lib/features/chat/domain/message_model.dart`
- `MessageModel` — Mesaj modeli (senderId, text, imageUrl, type, isRead)
- `MessageType` enum: `text`, `image`, `offer`
- `fromJson/toJson`

---

### Adım 2 — Chat Repository
#### [NEW] `lib/features/chat/data/chat_repository.dart`
- `createOrGetChat(currentUserId, otherUserId, listingId?)` — Var olan sohbeti bul veya yeni oluştur
- `getUserChats(userId)` — Kullanıcının tüm sohbetlerini dinle (Stream)
- `getMessages(chatId)` — Bir sohbetin mesajlarını dinle (Stream, sayfalama ile)
- `sendMessage(chatId, message)` — Metin mesajı gönder
- `sendImageMessage(chatId, File image)` — Resim gönder (Storage'a yükle + mesaj oluştur)
- `markAsRead(chatId, messageId)` — Okundu işaretle
- `getImageCount(chatId)` — Sohbetteki resim sayısını al
- `generateChatId(uid1, uid2)` — Benzersiz sohbet ID üret
- `getUnreadCount(userId)` — Toplam okunmamış mesaj sayısı (badge için)

---

### Adım 3 — Chat Controller (Riverpod)
#### [NEW] `lib/features/chat/presentation/chat_controller.dart`
- `userChatsProvider` — Kullanıcının sohbet listesi (Stream)
- `chatMessagesProvider(chatId)` — Bir sohbetin mesajları (Stream)
- `unreadCountProvider` — Okunmamış mesaj sayısı (bottom bar badge)
- `sendMessageController` — Mesaj gönderme state yönetimi
- `chatImageCountProvider(chatId)` — Sohbetteki resim sayısı (sınır kontrolü)

---

### Adım 4 — Sohbet Listesi Ekranı
#### [MODIFY] `lib/features/chat/presentation/chat_list_screen.dart`
- Placeholder kaldırılacak → Gerçek sohbet listesi
- Her kart: Karşı kullanıcı fotoğrafı/adı, son mesaj, tarih, okunmamış badge
- İlgili ilan bilgisi (varsa mini başlık)
- Boş durum: "Henüz bir sohbetiniz yok. Keşfet'ten bir ilana teklif verin!"
- Swipe ile sohbet silme

---

### Adım 5 — Mesajlaşma Ekranı
#### [MODIFY] `lib/features/chat/presentation/chat_detail_screen.dart`
- Placeholder kaldırılacak → Tam mesajlaşma ekranı
- AppBar: Karşı kullanıcı adı + fotoğrafı, ilan bilgisi (varsa)
- Mesaj balonları (gönderen/alıcı farklı renk)
- Metin girişi + gönder butonu
- Resim gönderme (kamera/galeri) — **Sohbet başına max 3 resim sınırı**
- Sınır aşıldığında: "📸 Resim sınırına ulaştınız. Premium'a geçerek sınırsız resim gönderin!" uyarısı
- Teklif mesajı özel kartı (farklı tasarım)
- Mesaj okundu işareti (çift tik)

---

### Adım 6 — İlan Detayından Sohbete Geçiş
#### [MODIFY] `lib/features/listings/presentation/listing_detail_screen.dart`
- "Mesaj Gönder" butonu → `chatRepository.createOrGetChat()` + `context.push('/chats/$chatId')`
- "Teklif Ver" butonu → Aynı chat kanalına "offer" tipinde mesaj gönder + sohbete yönlendir

---

### Adım 7 — Temizlik ve Entegrasyon
#### [MODIFY] `pubspec.yaml`
- `stream_chat_flutter: ^9.2.0` satırı **kaldırılacak** (artık gerekmiyor)

#### [MODIFY] `lib/app/router.dart`
- `ChatDetailScreen` artık `chatId` yerine sohbet ID'si ile çalışacak (zaten mevcut)

#### [MODIFY] Bottom Navigation Bar
- "Sohbetler" tab'ına okunmamış mesaj sayısı badge'i eklenecek

---

## 🖼️ Resim Sınırlama Stratejisi (Premium Hazırlık)

| Özellik | Ücretsiz | Premium (ileride) |
|---|---|---|
| Metin mesajı | ∞ Sınırsız | ∞ Sınırsız |
| Resim / sohbet | **3 adet** | Sınırsız |
| Teklif mesajı | ✅ | ✅ |

- `chats/{chatId}.imageCount` alanı ile takip
- Her resim gönderildiğinde `FieldValue.increment(1)` ile artır
- Gönderim öncesi sayaç kontrolü

---

## ✅ Doğrulama Planı
- Android debug build (`flutter build apk --debug`)
- İki test kullanıcısıyla gerçek zamanlı mesajlaşma testi
- İlan detay → Mesaj Gönder → Sohbet ekranı akışı
- Resim sınırı kontrolü (3. resimden sonra uyarı)
- Okunmamış mesaj badge testi

---

## ⚠️ Kullanıcıdan Gerekli
Ek bir şey gerekmiyor! Firebase zaten kurulu. Onay verin, hemen başlayalım.
