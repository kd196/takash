import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/rating_model.dart';
import '../../../core/providers.dart';

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository(ref.watch(firestoreProvider));
});

class RatingRepository {
  final FirebaseFirestore _firestore;

  RatingRepository(this._firestore);

  /// Puan Gönder ve Kullanıcı Ortalamasını Güncelle (Atomic Transaction)
  Future<void> submitRating({
    required String fromUserId,
    required String toUserId,
    required String listingId,
    required double score,
  }) async {
    final ratingRef = _firestore.collection('ratings').doc();
    final userRef = _firestore.collection('users').doc(toUserId);

    await _firestore.runTransaction((transaction) async {
      // 1. Hedef kullanıcının verisini çek
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) throw Exception('Hedef kullanıcı bulunamadı!');

      final userData = userDoc.data()!;
      final double currentRating = (userData['rating'] ?? 0.0).toDouble();
      final int currentCount = userData['ratingCount'] ?? 0;

      // 2. Yeni ortalamayı hesapla
      final int newCount = currentCount + 1;
      final double newRating = ((currentRating * currentCount) + score) / newCount;

      // 3. Puan dökümanını oluştur
      final rating = RatingModel(
        id: ratingRef.id,
        fromUserId: fromUserId,
        toUserId: toUserId,
        listingId: listingId,
        score: score,
        createdAt: DateTime.now(),
      );

      // 4. Batch/Transaction olarak yaz
      transaction.set(ratingRef, rating.toJson());
      transaction.update(userRef, {
        'rating': newRating,
        'ratingCount': newCount,
      });
    });
  }

  /// Belirli bir kullanıcıya ait puanları getir (Opsiyonel: Gelecekte liste için)
  Stream<List<RatingModel>> getUserRatings(String userId) {
    return _firestore
        .collection('ratings')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RatingModel.fromJson(doc.data(), doc.id))
            .toList());
  }
}
