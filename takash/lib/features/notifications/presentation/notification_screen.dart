import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:takash/shared/widgets/takash_icon.dart';
import '../domain/notification_model.dart';
import 'notification_controller.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final controller = ref.read(notificationControllerProvider.notifier);

    notificationsAsync.whenData((notifications) {
      final unreadCount = notifications.where((n) => !n.isRead).length;
      if (ref.read(unreadNotificationCountProvider) != unreadCount) {
        ref.read(unreadNotificationCountProvider.notifier).state = unreadCount;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => controller.markAllAsRead(),
            tooltip: 'Tümünü Okundu İşaretle',
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TakashIcon(
                      assetName: TakashIcon.notifications,
                      size: 80,
                      color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz bildirim yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(
                notification: notification,
                onTap: () {
                  if (!notification.isRead) {
                    controller.markAsRead(notification.id);
                  }
                  _handleNotificationTap(context, notification);
                },
                onDismiss: () => controller.deleteNotification(notification.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Hata: $error'),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(
      BuildContext context, NotificationModel notification) {
    if (notification.relatedId != null) {
      switch (notification.type) {
        case NotificationType.newMessage:
          context.push('/chat/${notification.relatedId}');
          break;
        case NotificationType.newOffer:
          context.push('/listing/${notification.relatedId}');
          break;
        case NotificationType.tradeCompleted:
        case NotificationType.newRating:
        case NotificationType.system:
          break;
      }
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.newMessage:
        return Icons.chat_bubble_outline;
      case NotificationType.newOffer:
        return Icons.swap_horiz;
      case NotificationType.tradeCompleted:
        return Icons.check_circle_outline;
      case NotificationType.newRating:
        return Icons.star_outline;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  String get _timeAgo {
    final now = DateTime.now();
    final diff = now.difference(notification.createdAt);
    if (diff.inMinutes < 1) return 'Şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
    if (diff.inHours < 24) return '${diff.inHours}sa önce';
    if (diff.inDays < 7) return '${diff.inDays}g önce';
    return '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead
              ? Colors.grey.shade200
              : Colors.green.shade100,
          child: Icon(_icon,
              color: notification.isRead ? Colors.grey : Colors.green),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(notification.body),
        trailing:
            Text(_timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey)),
        onTap: onTap,
      ),
    );
  }
}
