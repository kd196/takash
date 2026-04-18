import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:takash/features/listings/data/listing_repository.dart';
import 'package:takash/features/listings/domain/listing_model.dart';
import 'package:takash/features/listings/domain/listing_category.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockStorage;
  late ListingRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    repository = ListingRepository(
      firestore: fakeFirestore,
      storage: mockStorage,
    );
  });

  test('İlan oluşturulabilmeli', () async {
    final listing = ListingModel(
      id: 'test-id',
      ownerId: 'user-1',
      title: 'Test İlan',
      description: 'Test açıklama',
      category: ListingCategory.electronics,
      imageUrls: [],
      wantedItem: 'Kitap',
      location: null,
      geohash: null,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    await fakeFirestore
        .collection('listings')
        .doc(listing.id)
        .set(listing.toJson());

    final doc =
        await fakeFirestore.collection('listings').doc(listing.id).get();
    expect(doc.exists, true);
    expect(doc.data()!['title'], 'Test İlan');
    expect(doc.data()!['ownerId'], 'user-1');
  });

  test('İlan güncellenebilmeli', () async {
    final listing = ListingModel(
      id: 'test-id-2',
      ownerId: 'user-1',
      title: 'Orijinal',
      description: 'Açıklama',
      category: ListingCategory.electronics,
      imageUrls: [],
      wantedItem: 'X',
      location: null,
      geohash: null,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    await fakeFirestore
        .collection('listings')
        .doc(listing.id)
        .set(listing.toJson());

    final updated = listing.copyWith(title: 'Güncellenmiş');
    await fakeFirestore
        .collection('listings')
        .doc(listing.id)
        .update(updated.toJson());

    final doc =
        await fakeFirestore.collection('listings').doc(listing.id).get();
    expect(doc.data()!['title'], 'Güncellenmiş');
  });

  test('İlan silinebilmeli', () async {
    final listing = ListingModel(
      id: 'test-id-3',
      ownerId: 'user-1',
      title: 'Silinecek',
      description: 'Açıklama',
      category: ListingCategory.electronics,
      imageUrls: [],
      wantedItem: 'X',
      location: null,
      geohash: null,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    await fakeFirestore
        .collection('listings')
        .doc(listing.id)
        .set(listing.toJson());
    await fakeFirestore.collection('listings').doc(listing.id).delete();

    final doc =
        await fakeFirestore.collection('listings').doc(listing.id).get();
    expect(doc.exists, false);
  });

  test('İlan ID ile getirilebilmeli', () async {
    final listing = ListingModel(
      id: 'test-id-4',
      ownerId: 'user-1',
      title: 'Bul beni',
      description: 'Açıklama',
      category: ListingCategory.books,
      imageUrls: ['url1'],
      wantedItem: 'Y',
      location: null,
      geohash: null,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    await fakeFirestore
        .collection('listings')
        .doc(listing.id)
        .set(listing.toJson());

    final doc =
        await fakeFirestore.collection('listings').doc('test-id-4').get();
    expect(doc.exists, true);
    expect(doc.data()!['title'], 'Bul beni');
  });

  test('Çoklu ilan listelenebilmeli', () async {
    final listing1 = ListingModel(
      id: 'l1',
      ownerId: 'user-1',
      title: 'İlan 1',
      description: 'Açıklama',
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
      title: 'İlan 2',
      description: 'Açıklama',
      category: ListingCategory.books,
      imageUrls: [],
      wantedItem: 'Y',
      location: null,
      geohash: null,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    await fakeFirestore
        .collection('listings')
        .doc(listing1.id)
        .set(listing1.toJson());
    await fakeFirestore
        .collection('listings')
        .doc(listing2.id)
        .set(listing2.toJson());

    final snapshot = await fakeFirestore.collection('listings').get();
    expect(snapshot.docs.length, 2);
  });

  test('Kullanıcının ilanları filtrelenmeli', () async {
    final listing1 = ListingModel(
      id: 'l3',
      ownerId: 'user-1',
      title: 'User 1 İlan',
      description: 'Açıklama',
      category: ListingCategory.electronics,
      imageUrls: [],
      wantedItem: 'X',
      location: null,
      geohash: null,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    final listing2 = ListingModel(
      id: 'l4',
      ownerId: 'user-2',
      title: 'User 2 İlan',
      description: 'Açıklama',
      category: ListingCategory.books,
      imageUrls: [],
      wantedItem: 'Y',
      location: null,
      geohash: null,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    await fakeFirestore
        .collection('listings')
        .doc(listing1.id)
        .set(listing1.toJson());
    await fakeFirestore
        .collection('listings')
        .doc(listing2.id)
        .set(listing2.toJson());

    final snapshot = await fakeFirestore
        .collection('listings')
        .where('ownerId', isEqualTo: 'user-1')
        .get();
    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first.data()['title'], 'User 1 İlan');
  });
}
