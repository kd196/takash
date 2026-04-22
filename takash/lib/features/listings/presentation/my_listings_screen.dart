import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:takash/shared/widgets/takash_icon.dart';
import '../domain/listing_category.dart';
import 'listings_controller.dart';
import 'widgets/manage_listing_card.dart';
import '../../../core/providers.dart';

/// Kullanıcının kendi ilanları — Aktif ve Devre Dışı (Rezerve/Tamamlandı) sekmeli görünüm
class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('İlanlarım')),
        body: const Center(child: Text('Giriş yapmalısınız')),
      );
    }

    final userListings = ref.watch(userListingsProvider(currentUser.uid));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('İlanlarım'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.check_circle_outline),
                text: 'Aktif İlanlar',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Diğer İlanlar',
              ),
            ],
          ),
        ),
        body: userListings.when(
          data: (listings) {
            final activeListings = listings
                .where((l) => l.status == ListingStatus.active)
                .toList();
            final inactiveListings = listings
                .where((l) => l.status != ListingStatus.active)
                .toList();

            return TabBarView(
              children: [
                _buildListingList(
                  context,
                  ref,
                  activeListings,
                  'Henüz aktif ilanınız yok',
                  showCreateButton: true,
                ),
                _buildListingList(
                  context,
                  ref,
                  inactiveListings,
                  'Burada eski veya rezerve ilanlarınız yer alacak',
                  showCreateButton: false,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Hata: $error'),
          ),
        ),
        // Yeni ilan oluşturma FAB
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/create-listing'),
          icon: const Icon(Icons.add),
          label: const Text('Yeni İlan'),
        ),
      ),
    );
  }

  Widget _buildListingList(
    BuildContext context,
    WidgetRef ref,
    List listings,
    String emptyMessage, {
    required bool showCreateButton,
  }) {
    if (listings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TakashIcon(
                  assetName: TakashIcon.inventory,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
              if (showCreateButton) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/create-listing'),
                  icon: const Icon(Icons.add),
                  label: const Text('Hemen İlan Oluştur'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ManageListingCard(listing: listing),
        );
      },
    );
  }
}
