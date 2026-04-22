import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers.dart';
import '../domain/listing_model.dart';
import '../domain/listing_category.dart';

/// Listing Repository Provider
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider),
  );
});

class ListingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  ListingRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  /// Firestore koleksiyon referansı
  CollectionReference<Map<String, dynamic>> get _listingsRef =>
      _firestore.collection('listings');

  // ═══════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════

  /// Yeni ilan oluştur
  Future<String> createListing({
    required String ownerId,
    required String title,
    required String description,
    required ListingCategory category,
    required ListingCondition condition,
    required String wantedItem,
    required List<File> images,
    GeoPoint? location,
    String? geohash,
  }) async {
    final listingId = _uuid.v4();

    // Fotoğrafları yükle
    final imageUrls = await uploadImages(images, listingId);

    // Model oluştur
    final listing = ListingModel(
      id: listingId,
      ownerId: ownerId,
      title: title,
      description: description,
      category: category,
      condition: condition,
      imageUrls: imageUrls,
      wantedItem: wantedItem,
      location: location,
      geohash: geohash,
      status: ListingStatus.active,
      createdAt: DateTime.now(),
    );

    // Firestore'a kaydet
    await _listingsRef.doc(listingId).set(listing.toJson());

    return listingId;
  }

  // ═══════════════════════════════════════
  // READ
  // ═══════════════════════════════════════

  /// Tek bir ilanı ID ile getir
  Future<ListingModel?> getListingById(String listingId) async {
    final doc = await _listingsRef.doc(listingId).get();
    if (doc.exists && doc.data() != null) {
      return ListingModel.fromJson(doc.data()!);
    }
    return null;
  }

  /// Tüm aktif ilanları getir (Stream)
  Stream<List<ListingModel>> getAllActiveListings() {
    return _listingsRef
        .where('status', isEqualTo: ListingStatus.active.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromJson(doc.data()))
            .toList());
  }

  /// Yakındaki aktif ilanları getir (Geofencing Stream)
  Stream<List<ListingModel>> getNearbyListings({
    required GeoPoint center,
    required double radiusInKm,
  }) {
    final GeoCollectionReference<Map<String, dynamic>> geoRef =
        GeoCollectionReference(_listingsRef);

    return geoRef
        .subscribeWithin(
          center: GeoFirePoint(center),
          radiusInKm: radiusInKm,
          field: 'location',
          geopointFrom: (data) => data['location'] as GeoPoint,
          queryBuilder: (query) =>
              query.where('status', isEqualTo: ListingStatus.active.name),
        )
        .map((snapshots) => snapshots
            .map((doc) => ListingModel.fromJson(doc.data()!))
            .toList());
  }

  /// Bir kullanıcının ilanlarını getir (Stream)
  Stream<List<ListingModel>> getUserListings(String userId) {
    return _listingsRef
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromJson(doc.data()))
            .toList());
  }

  /// Kategoriye göre ilanları getir
  Stream<List<ListingModel>> getListingsByCategory(ListingCategory category) {
    return _listingsRef
        .where('status', isEqualTo: ListingStatus.active.name)
        .where('category', isEqualTo: category.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromJson(doc.data()))
            .toList());
  }

  /// Başlık bazlı arama (client-side filtre — küçük veri setleri için)
  Future<List<ListingModel>> searchListings(String query) async {
    final lowerQuery = query.toLowerCase();
    final snapshot = await _listingsRef
        .where('status', isEqualTo: ListingStatus.active.name)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ListingModel.fromJson(doc.data()))
        .where((listing) =>
            listing.title.toLowerCase().contains(lowerQuery) ||
            listing.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // ═══════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════

  /// İlanı güncelle
  Future<void> updateListing(ListingModel listing) async {
    await _listingsRef.doc(listing.id).update(listing.toJson());
  }

  /// İlan durumunu değiştir
  Future<void> updateListingStatus(
      String listingId, ListingStatus status) async {
    await _listingsRef.doc(listingId).update({'status': status.name});
  }

  // ═══════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════

  /// İlanı ve fotoğraflarını sil
  Future<void> deleteListing(String listingId) async {
    // Önce fotoğrafları sil
    await deleteImages(listingId);
    // Sonra dökümanı sil
    await _listingsRef.doc(listingId).delete();
  }

  // ═══════════════════════════════════════
  // FAVORITES
  // ═══════════════════════════════════════

  /// Favori durumunu değiştir (Ekle/Çıkar)
  Future<void> toggleFavorite(String userId, ListingModel listing) async {
    final favRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(listing.id);

    final doc = await favRef.get();
    if (doc.exists) {
      await favRef.delete();
    } else {
      await favRef.set(listing.toJson());
    }
  }

  /// İlan favorilerde mi kontrol et (Stream)
  Stream<bool> isFavorite(String userId, String listingId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(listingId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Kullanıcının favori ilanlarını getir (Stream)
  Stream<List<ListingModel>> getUserFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ListingModel.fromJson(doc.data()))
            .toList());
  }

  // ═══════════════════════════════════════
  // STORAGE — Fotoğraf İşlemleri
  // ═══════════════════════════════════════

  /// Birden fazla fotoğrafı Firebase Storage'a yükle
  /// Dönen: İndirilebilir URL listesi
  Future<List<String>> uploadImages(List<File> images, String listingId) async {
    final List<String> urls = [];

    for (int i = 0; i < images.length; i++) {
      final ref = _storage.ref().child('listings/$listingId/image_$i.jpg');
      final uploadTask = await ref.putFile(
        images[i],
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  /// İlana ait tüm fotoğrafları sil
  Future<void> deleteImages(String listingId) async {
    try {
      final ref = _storage.ref().child('listings/$listingId');
      final result = await ref.listAll();
      for (final item in result.items) {
        await item.delete();
      }
    } catch (_) {
      // Fotoğraf yoksa hata vermesin
    }
  }
}
