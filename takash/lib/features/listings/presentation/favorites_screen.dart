import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:takash/features/listings/presentation/listings_controller.dart';
import 'package:takash/features/listings/presentation/widgets/listing_card.dart';
import 'package:takash/shared/widgets/loading_indicator.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(userFavoritesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz favori ilanınız yok',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlanları inceleyip favorilerinize ekleyebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.explore),
                    label: const Text('Keşfetmeye Başla'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final listing = favorites[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ListingCard(
                  listing: listing,
                  onTap: () => context.push('/listing/${listing.id}'),
                ),
              );
            },
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Favoriler yükleniyor...'),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Hata oluştu: $err',
                  style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
      ),
    );
  }
}
