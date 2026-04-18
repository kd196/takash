import 'package:flutter_test/flutter_test.dart';
import 'package:takash/features/auth/domain/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserModel', () {
    test('fromJson ve toJson uyumlu olmalı', () {
      final user = UserModel(
        uid: 'test-uid',
        displayName: 'Test User',
        email: 'test@test.com',
        rating: 4.5,
        ratingCount: 10,
        createdAt: DateTime(2024, 1, 1),
        totalImageCount: 2,
      );

      final json = user.toJson();
      final parsed = UserModel.fromJson(json);

      expect(parsed.uid, user.uid);
      expect(parsed.displayName, user.displayName);
      expect(parsed.email, user.email);
      expect(parsed.rating, user.rating);
      expect(parsed.ratingCount, user.ratingCount);
    });

    test('opsiyonel alanlar null olabilir', () {
      final user = UserModel(
        uid: 'test-uid',
        displayName: 'Test',
        email: 'test@test.com',
        rating: 0,
        ratingCount: 0,
        createdAt: DateTime.now(),
        totalImageCount: 0,
        bio: null,
        photoUrl: null,
      );

      final json = user.toJson();
      final parsed = UserModel.fromJson(json);

      expect(parsed.bio, isNull);
      expect(parsed.photoUrl, isNull);
    });

    test('tam dolu user round-trip', () {
      final user = UserModel(
        uid: 'uid-123',
        displayName: 'Ahmet Yılmaz',
        email: 'ahmet@test.com',
        photoUrl: 'https://example.com/photo.jpg',
        bio: 'Merhaba!',
        rating: 4.8,
        ratingCount: 25,
        createdAt: DateTime(2024, 6, 15),
        totalImageCount: 5,
      );

      final json = user.toJson();
      final parsed = UserModel.fromJson(json);

      expect(parsed.uid, 'uid-123');
      expect(parsed.displayName, 'Ahmet Yılmaz');
      expect(parsed.email, 'ahmet@test.com');
      expect(parsed.photoUrl, 'https://example.com/photo.jpg');
      expect(parsed.bio, 'Merhaba!');
      expect(parsed.rating, 4.8);
      expect(parsed.ratingCount, 25);
    });

    test('toJson totalImageCount içermemeli', () {
      final user = UserModel(
        uid: 'uid-1',
        displayName: 'Test',
        email: 'test@test.com',
        rating: 0,
        ratingCount: 0,
        createdAt: DateTime.now(),
        totalImageCount: 99,
      );

      final json = user.toJson();
      expect(json.containsKey('totalImageCount'), isFalse);
    });

    test('createdAt Timestamp olarak serialize edilmeli', () {
      final user = UserModel(
        uid: 'uid-1',
        displayName: 'Test',
        email: 'test@test.com',
        rating: 0,
        ratingCount: 0,
        createdAt: DateTime(2024, 3, 15, 10, 30, 0),
        totalImageCount: 0,
      );

      final json = user.toJson();
      expect(json['createdAt'], isA<Timestamp>());
    });

    test('copyWith belirli alanları güncelleyebilmeli', () {
      final user = UserModel(
        uid: 'uid-1',
        displayName: 'Original',
        email: 'test@test.com',
        rating: 3.0,
        ratingCount: 5,
        createdAt: DateTime.now(),
        totalImageCount: 2,
      );

      final copied = user.copyWith(
        displayName: 'Updated',
        rating: 4.5,
        ratingCount: 10,
      );

      expect(copied.uid, 'uid-1');
      expect(copied.displayName, 'Updated');
      expect(copied.email, 'test@test.com');
      expect(copied.rating, 4.5);
      expect(copied.ratingCount, 10);
      expect(copied.totalImageCount, 2);
    });

    test('varsayılan değerler doğru olmalı', () {
      final user = UserModel(
        uid: 'uid-1',
        displayName: 'Test',
        email: 'test@test.com',
        createdAt: DateTime.now(),
      );

      expect(user.rating, 0.0);
      expect(user.ratingCount, 0);
      expect(user.totalImageCount, 0);
      expect(user.photoUrl, isNull);
      expect(user.bio, isNull);
    });
  });
}
