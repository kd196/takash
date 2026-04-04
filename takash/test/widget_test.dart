import 'package:flutter_test/flutter_test.dart';
import 'package:takash/features/notifications/domain/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('fromJson and toJson should work correctly', () {
      final json = {
        'id': 'test_123',
        'userId': 'user_456',
        'type': 'newMessage',
        'title': 'Test Bildirim',
        'body': 'Test mesaj içeriği',
        'relatedId': 'chat_789',
        'isRead': false,
        'createdAt': DateTime(2024, 1, 1),
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.id, 'test_123');
      expect(notification.userId, 'user_456');
      expect(notification.type, NotificationType.newMessage);
      expect(notification.title, 'Test Bildirim');
      expect(notification.body, 'Test mesaj içeriği');
      expect(notification.relatedId, 'chat_789');
      expect(notification.isRead, false);
    });

    test('copyWith should work correctly', () {
      final notification = NotificationModel(
        id: '1',
        userId: 'user1',
        type: NotificationType.newMessage,
        title: 'Original',
        body: 'Original body',
        createdAt: DateTime.now(),
      );

      final copied = notification.copyWith(
        title: 'Updated',
        isRead: true,
      );

      expect(copied.title, 'Updated');
      expect(copied.isRead, true);
      expect(copied.id, '1');
      expect(copied.userId, 'user1');
    });
  });
}
