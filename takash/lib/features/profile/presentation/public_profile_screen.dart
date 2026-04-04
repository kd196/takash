import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:takash/features/profile/data/profile_repository.dart';
import 'package:takash/features/listings/presentation/listings_controller.dart';
import 'package:takash/features/listings/presentation/widgets/listing_card.dart';
import 'package:takash/features/listings/domain/listing_category.dart';
import 'package:takash/shared/widgets/loading_indicator.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kullanıcı bilgilerini izle
    final userAsync = ref.watch(userDataProvider(userId));
    // Kullanıcının ilanlarını izle
    final userListingsAsync = ref.watch(userListingsProvider(userId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Profili'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Kullanıcı bulunamadı.'));
          }

          return CustomScrollView(
            slivers: [
              // ── Profil Üst Kısım ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profil Fotoğrafı
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage: user.photoUrl != null
                              ? CachedNetworkImageProvider(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Icon(Icons.person,
                                  size: 60, color: colorScheme.outline)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // İsim
                      Text(
                        user.displayName,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),
                      // Puan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${user.rating.toStringAsFixed(1)} (${user.ratingCount} Değerlendirme)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Hakkında (Bio)
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Hakkında',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            user.bio!,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                      // İlanlar Başlığı
                      const Divider(),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Kullanıcının İlanları',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── İlan Listesi (Sliver) ──
              userListingsAsync.when(
                data: (listings) {
                  // Sadece aktif ilanları göster
                  final activeListings = listings
                      .where((l) => l.status == ListingStatus.active)
                      .toList();

                  if (activeListings.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('Bu kullanıcının aktif ilanı bulunmuyor.'),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final listing = activeListings[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              height: 200,
                              child: ListingCard(
                                listing: listing,
                                onTap: () =>
                                    context.go('/listing/${listing.id}'),
                              ),
                            ),
                          );
                        },
                        childCount: activeListings.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Center(
                      child: Text('İlanlar yüklenirken hata oluştu: $err')),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          );
        },
        loading: () => const LoadingIndicator(message: 'Profil yükleniyor...'),
        error: (err, stack) =>
            Center(child: Text('Profil yüklenirken hata oluştu: $err')),
      ),
    );
  }
}
