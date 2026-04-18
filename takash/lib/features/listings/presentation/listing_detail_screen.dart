import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/listing_model.dart';
import '../domain/listing_category.dart';
import 'listings_controller.dart';
import '../../chat/presentation/chat_controller.dart';
import '../../profile/data/profile_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/providers.dart';

/// İlan detay ekranı — Fotoğraf carousel, bilgiler, ilan sahibi, teklif ver
class ListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(singleListingProvider(listingId));
    final currentUser = ref.watch(authStateProvider).value;
    final colorScheme = Theme.of(context).colorScheme;
    final isFavorite = ref.watch(isFavoriteProvider(listingId)).value ?? false;

    return listingAsync.when(
      data: (listing) {
        if (listing == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('İlan bulunamadı')),
          );
        }

        final isOwner = currentUser?.uid == listing.ownerId;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── Fotoğraf Carousel AppBar ──
              _buildSliverAppBar(
                  context, ref, listing, colorScheme, isFavorite),

              // ── İlan Bilgileri ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori + Durum
                      _buildCategoryAndStatus(listing, colorScheme),
                      const SizedBox(height: 12),

                      // Başlık
                      Text(
                        listing.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),

                      // Zaman
                      Text(
                        Helpers.timeAgo(listing.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // "Ne istiyor" kartı
                      _buildWantedItemCard(context, listing, colorScheme),
                      const SizedBox(height: 24),

                      // Açıklama
                      Text(
                        'Açıklama',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        listing.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // İlan sahibi kartı
                      _buildOwnerCard(context, ref, listing, colorScheme),
                      const SizedBox(height: 32),

                      // Sahip aksiyonları veya Teklif Ver butonu
                      if (isOwner)
                        _buildOwnerActions(context, ref, listing, colorScheme)
                      else
                        _buildActionButtons(context, ref, listing, colorScheme),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }

  /// Fotoğraf carousel'i ile SliverAppBar
  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref,
      ListingModel listing, ColorScheme colorScheme, bool isFavorite) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      stretch: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surfaceContainerHighest,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: colorScheme.onSurface, size: 22),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : colorScheme.onSurface,
              size: 22,
            ),
            onPressed: () {
              ref
                  .read(createListingControllerProvider.notifier)
                  .toggleFavorite(listing);
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.share_rounded,
                color: colorScheme.onSurface, size: 22),
            onPressed: () {
              Share.share(
                '🔄 ${listing.title}\n\n${listing.description}\n\nKarşılığında: ${listing.wantedItem}\n\nTakaş ile takas yap!',
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: listing.imageUrls.isNotEmpty
            ? _ImageCarousel(imageUrls: listing.imageUrls)
            : Container(
                color: colorScheme.surfaceContainerHighest,
                child: Icon(Icons.image, size: 64, color: colorScheme.outline),
              ),
      ),
    );
  }

  /// Kategori badge + durum badge
  Widget _buildCategoryAndStatus(
      ListingModel listing, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${listing.category.icon}  ${listing.category.label}',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: listing.status == ListingStatus.active
                ? colorScheme.primary.withValues(alpha: 0.15)
                : colorScheme.tertiary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            listing.status.label,
            style: TextStyle(
              color: listing.status == ListingStatus.active
                  ? colorScheme.primary
                  : colorScheme.tertiary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  /// "Karşılığında ne istiyor" kartı
  Widget _buildWantedItemCard(
      BuildContext context, ListingModel listing, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.secondaryContainer,
            colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.swap_horiz_rounded,
                color: colorScheme.secondary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Karşılığında İstenen',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  listing.wantedItem,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// İlan sahibi mini profil kartı
  Widget _buildOwnerCard(BuildContext context, WidgetRef ref,
      ListingModel listing, ColorScheme colorScheme) {
    final ownerData = ref.watch(userDataProvider(listing.ownerId));

    return ownerData.when(
      data: (user) => InkWell(
        onTap: () => context.push('/user/${listing.ownerId}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: user?.photoUrl != null
                    ? CachedNetworkImageProvider(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? Icon(Icons.person,
                        color: colorScheme.onPrimaryContainer, size: 32)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Kullanıcı',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${user?.rating.toStringAsFixed(1) ?? "0.0"} (${user?.ratingCount ?? 0} Değerlendirme)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Teklif Ver ve Mesaj Gönder butonları
  Widget _buildActionButtons(BuildContext context, WidgetRef ref,
      ListingModel listing, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () async {
                final owner = ref.read(userDataProvider(listing.ownerId)).value;
                if (owner == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('İlan sahibi bilgisi yüklenemedi')),
                  );
                  return;
                }
                try {
                  final chat =
                      await ref.read(chatControllerProvider.notifier).startChat(
                            otherUser: owner,
                            listingId: listing.id,
                            listingTitle: listing.title,
                          );

                  if (chat != null && context.mounted) {
                    context.push('/chat/${chat.id}');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Mesaj Gönder'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: listing.status == ListingStatus.active
                  ? () async {
                      final owner =
                          ref.read(userDataProvider(listing.ownerId)).value;
                      if (owner == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('İlan sahibi bilgisi yüklenemedi')),
                        );
                        return;
                      }
                      try {
                        final chat = await ref
                            .read(chatControllerProvider.notifier)
                            .startChat(
                              otherUser: owner,
                              listingId: listing.id,
                              listingTitle: listing.title,
                            );

                        if (chat != null) {
                          await ref
                              .read(chatControllerProvider.notifier)
                              .sendTextMessage(
                                chat.id,
                                'Merhaba, "${listing.title}" ilanın için bir takas teklifim var! 🤝',
                              );
                          if (context.mounted) {
                            context.push('/chat/${chat.id}');
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Hata: $e')),
                          );
                        }
                      }
                    }
                  : null,
              icon: const Icon(Icons.handshake),
              label: const Text('Teklif Ver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// İlan sahibinin kendi ilanı için aksiyonlar
  Widget _buildOwnerActions(BuildContext context, WidgetRef ref,
      ListingModel listing, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Durum değiştir
        if (listing.status == ListingStatus.active)
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await _showConfirmDialog(
                context,
                'İlanı Rezerve Et',
                'Bu ilan "Rezerve" olarak işaretlenecek.',
              );
              if (confirm == true) {
                await ref
                    .read(createListingControllerProvider.notifier)
                    .updateStatus(listing.id, ListingStatus.reserved);
              }
            },
            icon: const Icon(Icons.bookmark),
            label: const Text('Rezerve Et'),
          ),
        const SizedBox(height: 8),

        // Sil
        OutlinedButton.icon(
          onPressed: () async {
            final confirm = await _showConfirmDialog(
              context,
              'İlanı Sil',
              'Bu ilan kalıcı olarak silinecek. Bu işlem geri alınamaz.',
            );
            if (confirm == true) {
              final success = await ref
                  .read(createListingControllerProvider.notifier)
                  .deleteListing(listing.id);
              if (success && context.mounted) {
                context.go('/');
              }
            }
          },
          icon: Icon(Icons.delete_outline, color: colorScheme.error),
          label: Text('İlanı Sil', style: TextStyle(color: colorScheme.error)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.error),
          ),
        ),
      ],
    );
  }

  Future<bool?> _showConfirmDialog(
      BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }
}

/// Fotoğraf carousel widget'ı (PageView)
class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const _ImageCarousel({required this.imageUrls});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // PageView
        PageView.builder(
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, size: 48),
              ),
            );
          },
        ),

        // Sayfa göstergesi (dots)
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                return Container(
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
