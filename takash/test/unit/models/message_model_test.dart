import 'package:flutter_test/flutter_test.dart';
import 'package:takash/features/chat/domain/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('MessageModel', () {
    test('fromJson ve toJson uyumlu olmalı', () {
      final message = MessageModel(
        id: 'msg-1',
        senderId: 'user-1',
        text: 'Merhaba!',
        type: MessageType.text,
        createdAt: DateTime(2024, 3, 1, 10, 0),
        isRead: false,
      );

      final json = message.toJson();
      final parsed = MessageModel.fromJson(json, message.id);

      expect(parsed.id, message.id);
      expect(parsed.senderId, message.senderId);
      expect(parsed.text, message.text);
      expect(parsed.type, message.type);
      expect(parsed.isRead, message.isRead);
    });

    test('imageUrl içeren mesaj round-trip', () {
      final message = MessageModel(
        id: 'msg-2',
        senderId: 'user-2',
        text: 'Fotoğraf',
        imageUrl: 'https://example.com/photo.jpg',
        type: MessageType.image,
        createdAt: DateTime(2024, 3, 2, 11, 0),
        isRead: true,
      );

      final json = message.toJson();
      final parsed = MessageModel.fromJson(json, message.id);

      expect(parsed.imageUrl, 'https://example.com/photo.jpg');
      expect(parsed.type, MessageType.image);
      expect(parsed.isRead, true);
    });

    test('offer tip mesaj round-trip', () {
      final message = MessageModel(
        id: 'msg-3',
        senderId: 'user-3',
        text: 'Takas teklifim: MacBook Air',
        type: MessageType.offer,
        createdAt: DateTime(2024, 3, 3, 12, 0),
        isRead: false,
      );

      final json = message.toJson();
      final parsed = MessageModel.fromJson(json, message.id);

      expect(parsed.type, MessageType.offer);
      expect(parsed.text, 'Takas teklifim: MacBook Air');
    });

    test('opsiyonel imageUrl null olabilir', () {
      final message = MessageModel(
        id: 'msg-4',
        senderId: 'user-4',
        text: 'Sadece metin',
        type: MessageType.text,
        createdAt: DateTime.now(),
      );

      final json = message.toJson();
      final parsed = MessageModel.fromJson(json, message.id);

      expect(parsed.imageUrl, isNull);
    });

    test('varsayılan isRead false olmalı', () {
      final message = MessageModel(
        id: 'msg-5',
        senderId: 'user-5',
        text: 'Test',
        type: MessageType.text,
        createdAt: DateTime.now(),
      );

      expect(message.isRead, false);
    });

    test('createdAt Timestamp olarak serialize edilmeli', () {
      final message = MessageModel(
        id: 'msg-6',
        senderId: 'user-6',
        text: 'Test',
        type: MessageType.text,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = message.toJson();
      expect(json['createdAt'], isA<Timestamp>());
    });

    test('type enum name olarak serialize edilmeli', () {
      final message = MessageModel(
        id: 'msg-7',
        senderId: 'user-7',
        text: 'Test',
        type: MessageType.image,
        createdAt: DateTime.now(),
      );

      final json = message.toJson();
      expect(json['type'], 'image');
    });
  });
}
