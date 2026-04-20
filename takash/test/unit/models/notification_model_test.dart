import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:takash/features/notifications/domain/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('fromJson ve toJson uyumlu olmalı', () {
      final notification = NotificationModel(
        id: 'notif-1',
        userId: 'user-1',
        type: NotificationType.newMessage,
        title: 'Yeni Mesaj',
        body: 'Ahmet size mesaj gönderdi',
        relatedId: 'chat-1',
        isRead: false,
        createdAt: DateTime(2024, 3, 1),
      );

      final json = notification.toJson();
      final parsed = NotificationModel.fromJson(json);

      expect(parsed.id, notification.id);
      expect(parsed.userId, notification.userId);
      expect(parsed.type, notification.type);
      expect(parsed.title, notification.title);
      expect(parsed.body, notification.body);
      expect(parsed.relatedId, notification.relatedId);
      expect(parsed.isRead, notification.isRead);
    });

    test('opsiyonel alanlar null olabilir', () {
      final notification = NotificationModel(
        id: 'notif-2',
        userId: 'user-1',
        type: NotificationType.system,
        title: 'Sistem',
        body: 'Bildirim',
        createdAt: DateTime.now(),
      );

      final json = notification.toJson();
      final parsed = NotificationModel.fromJson(json);

      expect(parsed.relatedId, isNull);
      expect(parsed.isRead, false);
    });

    test('bilinmeyen type için system döner', () {
      final json = {
        'id': 'notif-3',
        'userId': 'user-1',
        'type': 'unknown_type',
        'title': 'Test',
        'body': 'Test',
        'isRead': false,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      final parsed = NotificationModel.fromJson(json);
      expect(parsed.type, NotificationType.system);
    });

    test('tüm notification tipleri serialize edilmeli', () {
      final types = [
        NotificationType.newMessage,
        NotificationType.newOffer,
        NotificationType.tradeCompleted,
        NotificationType.newRating,
        NotificationType.system,
      ];

      for (final type in types) {
        final notification = NotificationModel(
          id: 'notif-${type.name}',
          userId: 'user-1',
          type: type,
          title: 'Test',
          body: 'Test',
          createdAt: DateTime.now(),
        );

        final json = notification.toJson();
        final parsed = NotificationModel.fromJson(json);

        expect(parsed.type, type);
      }
    });

    test('createdAt Timestamp olarak serialize edilmeli', () {
      final notification = NotificationModel(
        id: 'notif-4',
        userId: 'user-1',
        type: NotificationType.system,
        title: 'Test',
        body: 'Test',
        createdAt: DateTime(2024, 6, 1),
      );

      final json = notification.toJson();
      expect(json['createdAt'], isA<Timestamp>());
    });

    test('copyWith belirli alanları güncelleyebilmeli', () {
      final notification = NotificationModel(
        id: 'notif-5',
        userId: 'user-1',
        type: NotificationType.newMessage,
        title: 'Orijinal',
        body: 'Test',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final copied = notification.copyWith(
        title: 'Güncellenmiş',
        isRead: true,
      );

      expect(copied.id, 'notif-5');
      expect(copied.title, 'Güncellenmiş');
      expect(copied.isRead, true);
      expect(copied.type, NotificationType.newMessage);
    });

    test('varsayılan isRead false olmalı', () {
      final notification = NotificationModel(
        id: 'notif-6',
        userId: 'user-1',
        type: NotificationType.system,
        title: 'Test',
        body: 'Test',
        createdAt: DateTime.now(),
      );

      expect(notification.isRead, false);
    });
  });
}
