import 'package:flutter_test/flutter_test.dart';
import 'package:takash/features/chat/domain/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('ChatModel', () {
    test('fromJson ve toJson uyumlu olmalı', () {
      final chat = ChatModel(
        id: 'chat-1',
        participants: ['user-1', 'user-2'],
        participantDetails: {
          'user-1': {'name': 'Ahmet'},
          'user-2': {'name': 'Mehmet'},
        },
        lastMessage: 'Selam!',
        lastMessageAt: DateTime(2024, 3, 1, 10, 0),
        imageCount: 0,
        listingId: 'listing-1',
        listingTitle: 'iPhone 13',
        unreadCounts: {'user-1': 1, 'user-2': 0},
      );

      final json = chat.toJson();
      final parsed = ChatModel.fromJson(json, chat.id);

      expect(parsed.id, chat.id);
      expect(parsed.participants, chat.participants);
      expect(parsed.lastMessage, chat.lastMessage);
      expect(parsed.imageCount, chat.imageCount);
      expect(parsed.listingId, chat.listingId);
      expect(parsed.listingTitle, chat.listingTitle);
      expect(parsed.unreadCounts, chat.unreadCounts);
    });

    test('opsiyonel alanlar null olabilir', () {
      final chat = ChatModel(
        id: 'chat-2',
        participants: ['user-3', 'user-4'],
        participantDetails: {},
        lastMessage: '',
        lastMessageAt: DateTime.now(),
      );

      final json = chat.toJson();
      final parsed = ChatModel.fromJson(json, chat.id);

      expect(parsed.listingId, isNull);
      expect(parsed.listingTitle, isNull);
      expect(parsed.unreadCounts, isEmpty);
      expect(parsed.imageCount, 0);
    });

    test('tam dolu chat round-trip', () {
      final chat = ChatModel(
        id: 'chat-3',
        participants: ['user-5', 'user-6'],
        participantDetails: {
          'user-5': {'name': 'Ayşe', 'photo': 'url1'},
          'user-6': {'name': 'Fatma', 'photo': 'url2'},
        },
        lastMessage: 'Takas yapalım mı?',
        lastMessageAt: DateTime(2024, 5, 20, 15, 30),
        imageCount: 3,
        listingId: 'listing-10',
        listingTitle: 'MacBook Pro',
        unreadCounts: {'user-5': 2, 'user-6': 0},
      );

      final json = chat.toJson();
      final parsed = ChatModel.fromJson(json, chat.id);

      expect(parsed.id, 'chat-3');
      expect(parsed.participants.length, 2);
      expect(parsed.participantDetails['user-5']['name'], 'Ayşe');
      expect(parsed.lastMessage, 'Takas yapalım mı?');
      expect(parsed.imageCount, 3);
      expect(parsed.listingId, 'listing-10');
      expect(parsed.listingTitle, 'MacBook Pro');
      expect(parsed.unreadCounts['user-5'], 2);
    });

    test('createdAt Timestamp olarak serialize edilmeli', () {
      final chat = ChatModel(
        id: 'chat-4',
        participants: ['user-7', 'user-8'],
        participantDetails: {},
        lastMessage: 'Test',
        lastMessageAt: DateTime(2024, 1, 1),
      );

      final json = chat.toJson();
      expect(json['lastMessageAt'], isA<Timestamp>());
    });

    test('copyWith belirli alanları güncelleyebilmeli', () {
      final chat = ChatModel(
        id: 'chat-5',
        participants: ['user-9', 'user-10'],
        participantDetails: {},
        lastMessage: 'Original',
        lastMessageAt: DateTime(2024, 1, 1),
        imageCount: 0,
        unreadCounts: {},
      );

      final copied = chat.copyWith(
        lastMessage: 'Updated message',
        imageCount: 5,
        unreadCounts: {'user-9': 3},
      );

      expect(copied.id, 'chat-5');
      expect(copied.lastMessage, 'Updated message');
      expect(copied.imageCount, 5);
      expect(copied.unreadCounts['user-9'], 3);
      expect(copied.participants, chat.participants);
    });
  });
}
