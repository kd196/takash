import 'dart:io';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:takash/features/map/data/location_service.dart';
import '../data/listing_repository.dart';
import '../domain/listing_model.dart';
import '../domain/listing_category.dart';
import '../../../core/providers.dart';

enum ListingStatusFilter { active, traded, all }

extension ListingStatusFilterExtension on ListingStatusFilter {
  ListingStatus? get listingStatus {
    switch (this) {
      case ListingStatusFilter.active:
        return ListingStatus.active;
      case ListingStatusFilter.traded:
        return ListingStatus.traded;
      case ListingStatusFilter.all:
        return null;
    }
  }

  String get label {
    switch (this) {
      case ListingStatusFilter.active:
        return 'Aktif';
      case ListingStatusFilter.traded:
        return 'Takaslandı';
      case ListingStatusFilter.all:
        return 'Tümü';
    }
  }
}

enum DateFilter { today, thisWeek, thisMonth, all }

extension DateFilterExtension on DateFilter {
  String get label {
    switch (this) {
      case DateFilter.today:
        return 'Bugün';
      case DateFilter.thisWeek:
        return 'Bu Hafta';
      case DateFilter.thisMonth:
        return 'Bu Ay';
      case DateFilter.all:
        return 'Tümü';
    }
  }
}

enum SortBy { newest, oldest, nearest, farthest }

extension SortByExtension on SortBy {
  String get label {
    switch (this) {
      case SortBy.newest:
        return 'En Yeni';
      case SortBy.oldest:
        return 'En Eski';
      case SortBy.nearest:
        return 'En Yakın';
      case SortBy.farthest:
        return 'En Uzak';
    }
  }
}

final allListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) return Stream.value([]);
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getAllActiveListings();
});

final searchRadiusProvider = StateProvider<double>((ref) => 100.0);

final nearbyListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) return Stream.value([]);
  final userLocation = ref.watch(userLocationProvider).value;
  final radius = ref.watch(searchRadiusProvider);
  final allListingsAsync = ref.watch(allListingsProvider);

  if (userLocation == null) {
    return Stream.value([]);
  }

  final repo = ref.watch(listingRepositoryProvider);

  return repo
      .getNearbyListings(
    center: GeoPoint(userLocation.latitude, userLocation.longitude),
    radiusInKm: radius,
  )
      .map((nearbyListings) {
    if (nearbyListings.isEmpty && allListingsAsync.hasValue) {
      return allListingsAsync.value!.where((l) => l.location != null).toList();
    }
    return nearbyListings;
  });
});

final userListingsProvider =
    StreamProvider.family<List<ListingModel>, String>((ref, userId) {
  final authState = ref.watch(authStateProvider);
  if (authState.value == null) return Stream.value([]);
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getUserListings(userId);
});

final singleListingProvider =
    FutureProvider.family<ListingModel?, String>((ref, listingId) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListingById(listingId);
});

final isFavoriteProvider =
    StreamProvider.family<bool, String>((ref, listingId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);

  final repo = ref.watch(listingRepositoryProvider);
  return repo.isFavorite(user.uid, listingId);
});

final userFavoritesProvider = StreamProvider<List<ListingModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  final repo = ref.watch(listingRepositoryProvider);
  return repo.getUserFavorites(user.uid);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final categoryFilterProvider = StateProvider<ListingCategory?>((ref) => null);

final showMyListingsProvider = StateProvider<bool>((ref) => false);

final distanceFilterProvider = StateProvider<double>((ref) => 50.0);

final statusFilterProvider =
    StateProvider<ListingStatusFilter>((ref) => ListingStatusFilter.active);

final dateFilterProvider = StateProvider<DateFilter>((ref) => DateFilter.all);

final sortByProvider = StateProvider<SortBy>((ref) => SortBy.newest);

final filteredListingsProvider =
    Provider<AsyncValue<List<ListingModel>>>((ref) {
  final listingsAsync = ref.watch(allListingsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final showMyListings = ref.watch(showMyListingsProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  final dateFilter = ref.watch(dateFilterProvider);
  final sortBy = ref.watch(sortByProvider);
  final currentUser = ref.watch(authStateProvider).value;
  final userLocation = ref.watch(userLocationProvider).value;
  final distance = ref.watch(distanceFilterProvider);

  return listingsAsync.whenData((listings) {
    var filtered = List<ListingModel>.from(listings);

    // HER ZAMAN sadece aktif ilanları göster - takaslanan/iptal gizli
    filtered = filtered.where((l) => l.status == ListingStatus.active).toList();

    if (userLocation != null && distance < 100) {
      filtered = filtered.where((l) {
        if (l.location == null) return false;
        final dist = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          l.location!.latitude,
          l.location!.longitude,
        );
        return dist <= distance;
      }).toList();
    }

    if (currentUser != null && !showMyListings) {
      filtered = filtered.where((l) => l.ownerId != currentUser.uid).toList();
    }

    if (categoryFilter != null) {
      filtered = filtered.where((l) => l.category == categoryFilter).toList();
    }

    if (statusFilter != ListingStatusFilter.all) {
      filtered = filtered
          .where((l) => l.status == statusFilter.listingStatus)
          .toList();
    }

    if (dateFilter != DateFilter.all) {
      final now = DateTime.now();
      filtered = filtered.where((l) {
        switch (dateFilter) {
          case DateFilter.today:
            return l.createdAt.isAfter(now.subtract(const Duration(days: 1)));
          case DateFilter.thisWeek:
            return l.createdAt.isAfter(now.subtract(const Duration(days: 7)));
          case DateFilter.thisMonth:
            return l.createdAt.isAfter(now.subtract(const Duration(days: 30)));
          default:
            return true;
        }
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      final lower = searchQuery.toLowerCase();
      filtered = filtered
          .where((l) =>
              l.title.toLowerCase().contains(lower) ||
              l.description.toLowerCase().contains(lower) ||
              l.wantedItem.toLowerCase().contains(lower))
          .toList();
    }

    switch (sortBy) {
      case SortBy.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SortBy.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SortBy.nearest:
        if (userLocation != null) {
          filtered.sort((a, b) {
            final distA = a.location != null
                ? _calculateDistance(
                    userLocation.latitude,
                    userLocation.longitude,
                    a.location!.latitude,
                    a.location!.longitude)
                : double.infinity;
            final distB = b.location != null
                ? _calculateDistance(
                    userLocation.latitude,
                    userLocation.longitude,
                    b.location!.latitude,
                    b.location!.longitude)
                : double.infinity;
            return distA.compareTo(distB);
          });
        }
      case SortBy.farthest:
        if (userLocation != null) {
          filtered.sort((a, b) {
            final distA = a.location != null
                ? _calculateDistance(
                    userLocation.latitude,
                    userLocation.longitude,
                    a.location!.latitude,
                    a.location!.longitude)
                : double.negativeInfinity;
            final distB = b.location != null
                ? _calculateDistance(
                    userLocation.latitude,
                    userLocation.longitude,
                    b.location!.latitude,
                    b.location!.longitude)
                : double.negativeInfinity;
            return distB.compareTo(distA);
          });
        }
    }

    return filtered;
  });
});

double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371;
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRad(lat1)) *
          math.cos(_toRad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

double _toRad(double deg) => deg * math.pi / 180;

final createListingControllerProvider =
    AsyncNotifierProvider<CreateListingController, void>(
  CreateListingController.new,
);

class CreateListingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> createListing({
    required String title,
    required String description,
    required ListingCategory category,
    required ListingCondition condition,
    required String wantedItem,
    required List<File> images,
    GeoPoint? location,
  }) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return null;

    String? resultId;

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);

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
        condition: condition,
        wantedItem: wantedItem,
        images: images,
        location: location,
        geohash: geohash,
      );
    });

    return state.hasError ? null : resultId;
  }

  Future<bool> updateListing({
    required ListingModel listing,
    List<File>? newImages,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);

      if (newImages != null && newImages.isNotEmpty) {
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

  Future<bool> deleteListing(String listingId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);
      await repo.deleteListing(listingId);
    });

    return !state.hasError;
  }

  Future<bool> updateStatus(String listingId, ListingStatus status) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);
      await repo.updateListingStatus(listingId, status);
    });

    return !state.hasError;
  }

  Future<void> toggleFavorite(ListingModel listing) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final repo = ref.read(listingRepositoryProvider);
    await repo.toggleFavorite(user.uid, listing);
  }
}
