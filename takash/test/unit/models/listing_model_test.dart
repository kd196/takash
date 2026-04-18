import 'package:flutter_test/flutter_test.dart';
import 'package:takash/features/listings/domain/listing_model.dart';
import 'package:takash/features/listings/domain/listing_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('ListingModel', () {
    test('fromJson ve toJson uyumlu olmalı', () {
      final listing = ListingModel(
        id: 'listing-1',
        ownerId: 'user-1',
        title: 'iPhone 13',
        description: 'Temiz kullanılmış',
        category: ListingCategory.electronics,
        imageUrls: ['https://example.com/img1.jpg'],
        wantedItem: 'MacBook',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime(2024, 3, 1),
      );

      final json = listing.toJson();
      final parsed = ListingModel.fromJson(json);

      expect(parsed.id, listing.id);
      expect(parsed.ownerId, listing.ownerId);
      expect(parsed.title, listing.title);
      expect(parsed.description, listing.description);
      expect(parsed.category, listing.category);
      expect(parsed.wantedItem, listing.wantedItem);
      expect(parsed.status, listing.status);
      expect(parsed.imageUrls.length, 1);
    });

    test('çoklu fotoğraf listesi round-trip', () {
      final listing = ListingModel(
        id: 'listing-2',
        ownerId: 'user-2',
        title: 'Koltuk',
        description: '3 kişilik',
        category: ListingCategory.furniture,
        imageUrls: ['url1', 'url2', 'url3'],
        wantedItem: 'Masa',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      final json = listing.toJson();
      final parsed = ListingModel.fromJson(json);

      expect(parsed.imageUrls.length, 3);
      expect(parsed.imageUrls.first, 'url1');
      expect(parsed.imageUrls.last, 'url3');
    });

    test('durum değişikliği', () {
      final listing = ListingModel(
        id: 'listing-3',
        ownerId: 'user-3',
        title: 'Test',
        description: 'Test',
        category: ListingCategory.books,
        imageUrls: [],
        wantedItem: 'X',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      expect(listing.status, ListingStatus.active);
    });

    test('createdAt Timestamp olarak serialize edilmeli', () {
      final listing = ListingModel(
        id: 'listing-4',
        ownerId: 'user-4',
        title: 'Test',
        description: 'Test',
        category: ListingCategory.other,
        imageUrls: [],
        wantedItem: 'Y',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime(2024, 6, 1),
      );

      final json = listing.toJson();
      expect(json['createdAt'], isA<Timestamp>());
    });

    test('kategori enum name olarak serialize edilmeli', () {
      final listing = ListingModel(
        id: 'listing-5',
        ownerId: 'user-5',
        title: 'Test',
        description: 'Test',
        category: ListingCategory.sports,
        imageUrls: [],
        wantedItem: 'Z',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      final json = listing.toJson();
      expect(json['category'], 'sports');
    });

    test('status enum name olarak serialize edilmeli', () {
      final listing = ListingModel(
        id: 'listing-6',
        ownerId: 'user-6',
        title: 'Test',
        description: 'Test',
        category: ListingCategory.other,
        imageUrls: [],
        wantedItem: 'W',
        location: null,
        geohash: null,
        status: ListingStatus.reserved,
        createdAt: DateTime.now(),
      );

      final json = listing.toJson();
      expect(json['status'], 'reserved');
    });

    test('boş imageUrls listesi round-trip', () {
      final listing = ListingModel(
        id: 'listing-7',
        ownerId: 'user-7',
        title: 'Test',
        description: 'Test',
        category: ListingCategory.other,
        imageUrls: [],
        wantedItem: 'V',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      final json = listing.toJson();
      final parsed = ListingModel.fromJson(json);

      expect(parsed.imageUrls, isEmpty);
    });

    test('copyWith belirli alanları güncelleyebilmeli', () {
      final listing = ListingModel(
        id: 'listing-8',
        ownerId: 'user-8',
        title: 'Original',
        description: 'Original desc',
        category: ListingCategory.electronics,
        imageUrls: ['url1'],
        wantedItem: 'Original wanted',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      final copied = listing.copyWith(
        title: 'Updated',
        status: ListingStatus.completed,
      );

      expect(copied.id, 'listing-8');
      expect(copied.title, 'Updated');
      expect(copied.description, 'Original desc');
      expect(copied.status, ListingStatus.completed);
    });

    test('varsayılan status active olmalı', () {
      final listing = ListingModel(
        id: 'listing-9',
        ownerId: 'user-9',
        title: 'Test',
        description: 'Test',
        category: ListingCategory.other,
        imageUrls: [],
        wantedItem: 'U',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      expect(listing.status, ListingStatus.active);
    });
  });
}
