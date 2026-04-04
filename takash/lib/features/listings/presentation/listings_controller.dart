import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:takash/features/map/data/location_service.dart';
import '../data/listing_repository.dart';
import '../domain/listing_model.dart';
import '../domain/listing_category.dart';
import '../../../core/providers.dart';

// ═══════════════════════════════════════
// Stream Providers — Gerçek zamanlı veri
// ═══════════════════════════════════════

/// Tüm aktif ilanları dinle
final allListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getAllActiveListings();
});

/// Arama yarıçapı (km)
final searchRadiusProvider = StateProvider<double>((ref) => 100.0); // Test için 100km yaptık

/// Yakındaki ilanları dinle
final nearbyListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final userLocation = ref.watch(userLocationProvider).value;
  final radius = ref.watch(searchRadiusProvider);
  final allListingsAsync = ref.watch(allListingsProvider);

  if (userLocation == null) {
    print('📍 [NearbyListings] Kullanıcı konumu henüz alınamadı.');
    return Stream.value([]);
  }

  final repo = ref.watch(listingRepositoryProvider);
  print('📍 [NearbyListings] Sorgu başlatılıyor: (${userLocation.latitude}, ${userLocation.longitude})');

  return repo.getNearbyListings(
    center: GeoPoint(userLocation.latitude, userLocation.longitude),
    radiusInKm: radius,
  ).map((nearbyListings) {
    if (nearbyListings.isEmpty && allListingsAsync.hasValue) {
      print('📍 [NearbyListings] Yakında ilan yok, tüm ilanlar gösteriliyor (Fallback)');
      // Konumu olan tüm ilanları filtrele
      return allListingsAsync.value!.where((l) => l.location != null).toList();
    }
    print('📍 [NearbyListings] ${nearbyListings.length} adet yakın ilan bulundu.');
    return nearbyListings;
  });
});

/// Belirli bir kullanıcının ilanlarını dinle
final userListingsProvider =
    StreamProvider.family<List<ListingModel>, String>((ref, userId) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getUserListings(userId);
});

/// Tek ilan detayını getir
final singleListingProvider =
    FutureProvider.family<ListingModel?, String>((ref, listingId) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListingById(listingId);
});

/// İlan favorilerde mi?
final isFavoriteProvider = StreamProvider.family<bool, String>((ref, listingId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);
  
  final repo = ref.watch(listingRepositoryProvider);
  return repo.isFavorite(user.uid, listingId);
});

/// Kullanıcının tüm favori ilanları
final userFavoritesProvider = StreamProvider<List<ListingModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getUserFavorites(user.uid);
});

// ═══════════════════════════════════════
// Filtre & Arama State'leri
// ═══════════════════════════════════════

/// Arama sorgusu
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Seçili kategori filtresi (null = hepsi)
final categoryFilterProvider = StateProvider<ListingCategory?>((ref) => null);

/// Kendi ilanlarımı göster/gizle (Default: false - Gizli)
final showMyListingsProvider = StateProvider<bool>((ref) => false);

/// Filtrelenmiş ilan listesi
final filteredListingsProvider = Provider<AsyncValue<List<ListingModel>>>((ref) {
  final listingsAsync = ref.watch(allListingsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final showMyListings = ref.watch(showMyListingsProvider);
  final currentUser = ref.watch(authStateProvider).value;

  return listingsAsync.whenData((listings) {
    var filtered = listings;

    // Kendi ilanlarımı filtrele (Eğer showMyListings false ise gizle)
    if (currentUser != null && !showMyListings) {
      filtered = filtered.where((l) => l.ownerId != currentUser.uid).toList();
    }

    // Kategori filtresi
    if (categoryFilter != null) {
      filtered = filtered
          .where((l) => l.category == categoryFilter)
          .toList();
    }

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      final lower = searchQuery.toLowerCase();
      filtered = filtered
          .where((l) =>
              l.title.toLowerCase().contains(lower) ||
              l.description.toLowerCase().contains(lower) ||
              l.wantedItem.toLowerCase().contains(lower))
          .toList();
    }

    return filtered;
  });
});

// ═══════════════════════════════════════
// İlan Oluşturma Controller
// ═══════════════════════════════════════

/// İlan oluşturma/düzenleme state'i
final createListingControllerProvider =
    AsyncNotifierProvider<CreateListingController, void>(
  CreateListingController.new,
);

class CreateListingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Yeni ilan oluştur
  Future<String?> createListing({
    required String title,
    required String description,
    required ListingCategory category,
    required String wantedItem,
    required List<File> images,
    GeoPoint? location,
  }) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return null;

    String? resultId;

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);

      // Geohash hesapla (Eğer konum seçilmişse)
      String? geohash;
      if (location != null) {
        final GeoFirePoint geoFirePoint = GeoFirePoint(location);
        geohash = geoFirePoint.geohash;
      }

      resultId = await repo.createListing(
        ownerId: user.uid,
        title: title,
        description: description,
        category: category,
        wantedItem: wantedItem,
        images: images,
        location: location,
        geohash: geohash,
      );
    });

    return state.hasError ? null : resultId;
  }

  /// Mevcut ilanı güncelle
  Future<bool> updateListing({
    required ListingModel listing,
    List<File>? newImages,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);

      if (newImages != null && newImages.isNotEmpty) {
        // Eski fotoğrafları sil ve yenilerini yükle
        await repo.deleteImages(listing.id);
        final newUrls = await repo.uploadImages(newImages, listing.id);
        final updatedListing = listing.copyWith(imageUrls: newUrls);
        await repo.updateListing(updatedListing);
      } else {
        await repo.updateListing(listing);
      }
    });

    return !state.hasError;
  }

  /// İlanı sil
  Future<bool> deleteListing(String listingId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);
      await repo.deleteListing(listingId);
    });

    return !state.hasError;
  }

  /// İlan durumunu değiştir
  Future<bool> updateStatus(String listingId, ListingStatus status) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);
      await repo.updateListingStatus(listingId, status);
    });

    return !state.hasError;
  }

  /// Favori durumunu değiştir
  Future<void> toggleFavorite(ListingModel listing) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final repo = ref.read(listingRepositoryProvider);
    await repo.toggleFavorite(user.uid, listing);
  }
}
