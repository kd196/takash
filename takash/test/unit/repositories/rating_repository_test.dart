import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:takash/features/profile/data/rating_repository.dart';
import 'package:takash/features/profile/domain/rating_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RatingRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = RatingRepository(fakeFirestore);
  });

  test('Puanlama kaydedilebilmeli', () async {
    await fakeFirestore.collection('users').doc('user-2').set({
      'uid': 'user-2',
      'displayName': 'Test User',
      'email': 'test@test.com',
      'rating': 0.0,
      'ratingCount': 0,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'totalImageCount': 0,
    });

    final ratingRef = fakeFirestore.collection('ratings').doc();
    final rating = RatingModel(
      id: ratingRef.id,
      fromUserId: 'user-1',
      toUserId: 'user-2',
      listingId: 'listing-1',
      score: 5,
      createdAt: DateTime.now(),
    );

    await ratingRef.set(rating.toJson());

    final doc =
        await fakeFirestore.collection('ratings').doc(ratingRef.id).get();
    expect(doc.exists, true);
    expect(doc.data()!['score'], 5);
    expect(doc.data()!['toUserId'], 'user-2');
  });

  test('Kullanıcı puanları listelenebilmeli', () async {
    final rating1 = RatingModel(
      id: 'r1',
      fromUserId: 'user-1',
      toUserId: 'user-2',
      listingId: 'listing-1',
      score: 5,
      createdAt: DateTime.now(),
    );

    final rating2 = RatingModel(
      id: 'r2',
      fromUserId: 'user-3',
      toUserId: 'user-2',
      listingId: 'listing-2',
      score: 4,
      createdAt: DateTime.now(),
    );

    await fakeFirestore.collection('ratings').doc('r1').set(rating1.toJson());
    await fakeFirestore.collection('ratings').doc('r2').set(rating2.toJson());

    final snapshot = await fakeFirestore
        .collection('ratings')
        .where('toUserId', isEqualTo: 'user-2')
        .get();
    expect(snapshot.docs.length, 2);
  });

  test('Kullanıcı ortalaması güncellenebilmeli', () async {
    await fakeFirestore.collection('users').doc('user-2').set({
      'uid': 'user-2',
      'displayName': 'Test User',
      'email': 'test@test.com',
      'rating': 0.0,
      'ratingCount': 0,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'totalImageCount': 0,
    });

    final userDoc = await fakeFirestore.collection('users').doc('user-2').get();
    expect(userDoc.exists, true);
    expect(userDoc.data()!['rating'], 0.0);
    expect(userDoc.data()!['ratingCount'], 0);

    await fakeFirestore.collection('users').doc('user-2').update({
      'rating': 5.0,
      'ratingCount': 1,
    });

    final updatedDoc =
        await fakeFirestore.collection('users').doc('user-2').get();
    expect(updatedDoc.data()!['rating'], 5.0);
    expect(updatedDoc.data()!['ratingCount'], 1);
  });
}
