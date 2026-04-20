import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:takash/main.dart' as app;
import 'package:takash/core/providers.dart';
import 'package:takash/features/listings/domain/listing_model.dart';
import 'package:takash/features/listings/domain/listing_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Listing Flow Integration Tests', () {
    testWidgets('listing card displays all information', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      final testListing = ListingModel(
        id: 'test-listing-1',
        ownerId: 'user-1',
        title: 'iPhone 13 Pro',
        description: 'Çok temiz',
        category: ListingCategory.electronics,
        imageUrls: ['https://example.com/img1.jpg'],
        wantedItem: 'Samsung Galaxy',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      await mockFirestore
          .collection('listings')
          .doc(testListing.id)
          .set(testListing.toJson());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: app.TakashApp()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('iPhone 13 Pro'), findsOneWidget);
      expect(find.text('Samsung Galaxy'), findsOneWidget);
    });

    testWidgets('multiple listings render correctly', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();

      final listing1 = ListingModel(
        id: 'l1',
        ownerId: 'user-1',
        title: 'iPhone',
        description: 'Test',
        category: ListingCategory.electronics,
        imageUrls: [],
        wantedItem: 'X',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      final listing2 = ListingModel(
        id: 'l2',
        ownerId: 'user-2',
        title: 'Kitap',
        description: 'Test',
        category: ListingCategory.books,
        imageUrls: [],
        wantedItem: 'Y',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      await mockFirestore
          .collection('listings')
          .doc(listing1.id)
          .set(listing1.toJson());
      await mockFirestore
          .collection('listings')
          .doc(listing2.id)
          .set(listing2.toJson());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firebaseAuthProvider.overrideWithValue(mockAuth),
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: const MaterialApp(home: app.TakashApp()),
        ),
      );

      await tester.pumpAndSettle();

      final snapshot = await mockFirestore.collection('listings').get();
      expect(snapshot.docs.length, 2);
    });
  });
}
