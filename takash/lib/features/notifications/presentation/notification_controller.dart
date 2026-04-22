import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/notification_service.dart';
import '../domain/notification_model.dart';
import '../../../core/providers.dart';

final unreadNotificationCountProvider = StateProvider<int>((ref) => 0);

final userNotificationsProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(notificationServiceProvider).getUserNotifications(user.uid);
});

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, void>(
        NotificationController.new);

class NotificationController extends AsyncNotifier<void> {
  late final NotificationService _notificationService;

  @override
  Future<void> build() async {
    _notificationService = ref.read(notificationServiceProvider);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }

  Future<void> initialize() async {
    state = const AsyncLoading();
    await AsyncValue.guard(() async {
      await _notificationService.initialize();
    });
    state = const AsyncData(null);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      ref.read(unreadNotificationCountProvider.notifier).state++;
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    if (data['relatedId'] != null) {
      debugPrint('Bildirim tıklandı: ${data['type']} - ${data['relatedId']}');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    state = const AsyncLoading();
    await AsyncValue.guard(() async {
      await _notificationService.markAsRead(notificationId);
      final currentCount = ref.read(unreadNotificationCountProvider);
      if (currentCount > 0) {
        ref.read(unreadNotificationCountProvider.notifier).state =
            currentCount - 1;
      }
    });
    state = const AsyncData(null);
  }

  Future<void> markAllAsRead() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    await AsyncValue.guard(() async {
      await _notificationService.markAllAsRead(user.uid);
      ref.read(unreadNotificationCountProvider.notifier).state = 0;
    });
    state = const AsyncData(null);
  }

  Future<void> deleteNotification(String notificationId) async {
    state = const AsyncLoading();
    await AsyncValue.guard(() async {
      await _notificationService.deleteNotification(notificationId);
    });
    state = const AsyncData(null);
  }

  Future<int> getUnreadCount() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return 0;

    return await _notificationService.getUnreadCount(user.uid);
  }

  Future<void> refreshUnreadCount() async {
    final count = await getUnreadCount();
    ref.read(unreadNotificationCountProvider.notifier).state = count;
  }
}
