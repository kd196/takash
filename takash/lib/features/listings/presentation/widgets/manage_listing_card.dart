import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/listing_model.dart';
import '../../domain/listing_category.dart';
import '../listings_controller.dart';

class ManageListingCard extends ConsumerWidget {
  final ListingModel listing;

  const ManageListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Üst Kısım (İlan Bilgileri)
          InkWell(
            onTap: () => context.go('/listing/${listing.id}'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resim
                if (listing.imageUrls.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: listing.imageUrls.first,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    width: 120,
                    height: 120,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported),
                  ),
                // Metinler
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                listing.category.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              listing.status.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(listing.status),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'İstenen: ${listing.wantedItem}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Alt Kısım (Aksiyonlar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: TextButton.icon(
                    onPressed: () =>
                        context.push('/edit-listing/${listing.id}'),
                    icon: const Icon(Icons.edit, size: 18),
                    label:
                        const Text('Düzenle', overflow: TextOverflow.ellipsis),
                  ),
                ),
                Flexible(
                  child: _StatusPicker(listing: listing),
                ),
                Flexible(
                  child: TextButton.icon(
                    onPressed: () => _showDeleteDialog(context, ref),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Sil', overflow: TextOverflow.ellipsis),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return Colors.green;
      case ListingStatus.traded:
        return Colors.blue;
      case ListingStatus.cancelled:
        return Colors.red;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text(
            'Bu ilanı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(createListingControllerProvider.notifier)
                  .deleteListing(listing.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('İlan başarıyla silindi')),
                  );
                }
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusPicker extends ConsumerWidget {
  final ListingModel listing;
  const _StatusPicker({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<ListingStatus>(
      initialValue: listing.status,
      onSelected: (status) async {
        final success = await ref
            .read(createListingControllerProvider.notifier)
            .updateStatus(listing.id, status);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('İlan durumu "${status.label}" olarak güncellendi')),
          );
        }
      },
      itemBuilder: (context) => ListingStatus.values.map((status) {
        return PopupMenuItem(
          value: status,
          child: Row(
            children: [
              Icon(
                status == listing.status ? Icons.check : null,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(status.label),
            ],
          ),
        );
      }).toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert,
                size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 2),
            Text(
              'Durum',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
