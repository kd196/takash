import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:takash/features/map/data/location_service.dart';
import '../../domain/listing_model.dart';
import '../../domain/listing_category.dart';
import '../listings_controller.dart';
import '../../../../core/utils/helpers.dart';

/// Dikey ilan kartı — üstte fotoğraf, altta bilgiler
class ListingCard extends ConsumerWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isFavorite = ref.watch(isFavoriteProvider(listing.id)).value ?? false;
    final userLocation = ref.watch(userLocationProvider).value;

    String? distanceText;
    if (userLocation != null && listing.location != null) {
      final double distance = Helpers.calculateDistance(
        GeoPoint(userLocation.latitude, userLocation.longitude),
        listing.location!,
      );
      distanceText = Helpers.formatDistance(distance);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final photoHeight = constraints.maxHeight * 0.6;
            return Column(
              children: [
                // Üst: Fotoğraf
                SizedBox(
                  height: photoHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'image_${listing.id}_${context.hashCode}',
                        child: listing.imageUrls.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: listing.imageUrls.first,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Icon(Icons.image_not_supported,
                                      size: 48, color: colorScheme.outline),
                                ),
                              )
                            : Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.image,
                                    size: 48, color: colorScheme.outline),
                              ),
                      ),

                      // Kategori badge'i
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${listing.category.icon} ${listing.category.label}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Favori Butonu
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white70,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.black87,
                              size: 20,
                            ),
                            onPressed: () {
                              ref
                                  .read(
                                      createListingControllerProvider.notifier)
                                  .toggleFavorite(listing);
                            },
                          ),
                        ),
                      ),

                      // Fotoğraf sayısı
                      if (listing.imageUrls.length > 1)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.photo_library,
                                    size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '${listing.imageUrls.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Alt: İlan bilgileri
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.swap_horiz,
                                size: 14, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                listing.wantedItem,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (distanceText != null)
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 2),
                                  Text(
                                    distanceText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            else
                              const SizedBox.shrink(),
                            Text(
                              Helpers.timeAgo(listing.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
