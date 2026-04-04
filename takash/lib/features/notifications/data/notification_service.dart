import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../domain/notification_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _saveInAppNotification(message);
}

Future<void> _saveInAppNotification(RemoteMessage message) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid,
      type: NotificationType.values.firstWhere(
        (e) => e.name == message.data['type'],
        orElse: () => NotificationType.system,
      ),
      title: message.notification?.title ?? message.data['title'] ?? '',
      body: message.notification?.body ?? message.data['body'] ?? '',
      relatedId: message.data['relatedId'],
      isRead: false,
      createdAt: message.sentTime ?? DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toJson());
  } catch (e) {
    print('Bildirim kaydetme hatası: $e');
  }
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // Android notification channel'ları oluştur
    await _createNotificationChannels();

    // Local notifications plugin'i başlat
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // FCM izinlerini al
    final fcmSettings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (fcmSettings.authorizationStatus == AuthorizationStatus.authorized) {
      await _saveToken();
      _messaging.onTokenRefresh.listen(_updateToken);
    }

    // Foreground mesajları dinle → local notification göster
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'chat_messages',
        'Sohbet Mesajları',
        description: 'Yeni mesaj bildirimleri',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
      AndroidNotificationChannel(
        'offers',
        'Teklif Bildirimleri',
        description: 'Yeni teklif bildirimleri',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'trades',
        'Takas Bildirimleri',
        description: 'Takas durumu bildirimleri',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'ratings',
        'Puanlama Bildirimleri',
        description: 'Yeni puanlama bildirimleri',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
      AndroidNotificationChannel(
        'system',
        'Sistem Bildirimleri',
        description: 'Genel sistem bildirimleri',
        importance: Importance.low,
        playSound: false,
      ),
    ];

    for (final channel in channels) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _showLocalNotification(message);
    _saveInAppNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final android = message.data['android_channel_id'];
    String channelId = 'system';

    if (android != null) {
      channelId = android;
    } else if (message.data['type'] != null) {
      switch (message.data['type']) {
        case 'newMessage':
          channelId = 'chat_messages';
          break;
        case 'newOffer':
          channelId = 'offers';
          break;
        case 'tradeCompleted':
          channelId = 'trades';
          break;
        case 'newRating':
          channelId = 'ratings';
          break;
        default:
          channelId = 'system';
      }
    }

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'chat_messages':
        return 'Sohbet Mesajları';
      case 'offers':
        return 'Teklif Bildirimleri';
      case 'trades':
        return 'Takas Bildirimleri';
      case 'ratings':
        return 'Puanlama Bildirimleri';
      default:
        return 'Sistem Bildirimleri';
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // payload'dan data'yı parse edip yönlendirme yapılabilir
    print('Bildirim tıklandı: ${response.payload}');
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> _saveToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmTokens': FieldValue.arrayUnion([token]),
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> _updateToken(String newToken) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'fcmTokens': FieldValue.arrayUnion([newToken]),
      }, SetOptions(merge: true));
    }
  }

  Future<void> deleteToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await _messaging.getToken();
    if (user != null && token != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
    }
    await _messaging.deleteToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final notifications = await getUserNotifications(userId).first;
    final unread = notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    final batch = _firestore.batch();
    for (final notification in unread) {
      batch.update(
        _firestore.collection('notifications').doc(notification.id),
        {'isRead': true},
      );
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService());
