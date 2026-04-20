import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:takash/features/listings/presentation/widgets/listing_card.dart';
import 'package:takash/features/listings/domain/listing_model.dart';
import 'package:takash/features/listings/domain/listing_category.dart';
import 'package:takash/core/providers.dart';
import 'package:takash/features/listings/presentation/listings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ListingCard', () {
    late ListingModel testListing;

    setUp(() {
      testListing = ListingModel(
        id: 'test-listing-1',
        ownerId: 'user-1',
        title: 'iPhone 13',
        description: 'Temiz kullanılmış',
        category: ListingCategory.electronics,
        imageUrls: ['https://example.com/img1.jpg'],
        wantedItem: 'MacBook',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );
    });

    testWidgets('ilan başlığını gösterir', (tester) async {
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListingCard(
                listing: testListing,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('iPhone 13'), findsOneWidget);
    });

    testWidgets('ista istenen ürünü gösterir', (tester) async {
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListingCard(
                listing: testListing,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('MacBook'), findsOneWidget);
    });

    testWidgets('kategori etiketini gösterir', (tester) async {
      final mockFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListingCard(
                listing: testListing,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Elektronik'), findsOneWidget);
    });

    testWidgets('resim sayısını gösterir', (tester) async {
      final mockFirestore = FakeFirebaseFirestore();
      final listingWithMultipleImages = ListingModel(
        id: 'test-listing-2',
        ownerId: 'user-1',
        title: 'Test',
        description: 'Test',
        category: ListingCategory.electronics,
        imageUrls: ['url1', 'url2', 'url3'],
        wantedItem: 'X',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListingCard(
                listing: listingWithMultipleImages,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tıklandığında callback çalışır', (tester) async {
      final mockFirestore = FakeFirebaseFirestore();
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListingCard(
                listing: testListing,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.byType(ListingCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('resimsiz ilan için placeholder gösterir', (tester) async {
      final mockFirestore = FakeFirebaseFirestore();
      final listingWithoutImage = ListingModel(
        id: 'test-listing-3',
        ownerId: 'user-1',
        title: 'Test',
        description: 'Test',
        category: ListingCategory.furniture,
        imageUrls: [],
        wantedItem: 'Y',
        location: null,
        geohash: null,
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(mockFirestore),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ListingCard(
                listing: listingWithoutImage,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.image), findsOneWidget);
    });
  });
}
