import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:takash/features/profile/domain/rating_model.dart';

void main() {
  group('RatingModel', () {
    test('fromJson ve toJson uyumlu olmalı', () {
      final rating = RatingModel(
        id: 'rating-1',
        fromUserId: 'user-1',
        toUserId: 'user-2',
        listingId: 'listing-1',
        score: 5.0,
        createdAt: DateTime(2024, 3, 1),
      );

      final json = rating.toJson();
      final parsed = RatingModel.fromJson(json, rating.id);

      expect(parsed.id, rating.id);
      expect(parsed.fromUserId, rating.fromUserId);
      expect(parsed.toUserId, rating.toUserId);
      expect(parsed.listingId, rating.listingId);
      expect(parsed.score, rating.score);
    });

    test('opsiyonel alanlar için varsayılan değerler', () {
      final json = {
        'fromUserId': 'user-1',
        'toUserId': 'user-2',
        'listingId': 'listing-1',
        'score': null,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      final parsed = RatingModel.fromJson(json, 'rating-2');

      expect(parsed.score, 0.0);
      expect(parsed.fromUserId, 'user-1');
    });

    test('score double olarak serialize edilmeli', () {
      final rating = RatingModel(
        id: 'rating-3',
        fromUserId: 'user-1',
        toUserId: 'user-2',
        listingId: 'listing-1',
        score: 4,
        createdAt: DateTime.now(),
      );

      final json = rating.toJson();
      final parsed = RatingModel.fromJson(json, rating.id);

      expect(parsed.score, 4.0);
    });

    test('createdAt Timestamp olarak serialize edilmeli', () {
      final rating = RatingModel(
        id: 'rating-4',
        fromUserId: 'user-1',
        toUserId: 'user-2',
        listingId: 'listing-1',
        score: 5.0,
        createdAt: DateTime(2024, 6, 1),
      );

      final json = rating.toJson();
      expect(json['createdAt'], isA<Timestamp>());
    });
  });
}
