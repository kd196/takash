import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../listings/presentation/widgets/manage_listing_card.dart';
import '../../profile/data/profile_repository.dart';
import '../../listings/data/listing_repository.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId; // Kendi profilimiz için null, başkası için UID

  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authStateProvider).value?.uid;
    final targetUserId = userId ?? currentUserId;

    if (targetUserId == null)
      return const Center(child: Text('Giriş yapmalısınız.'));

    final userDataAsync = ref.watch(userDataProvider(targetUserId));
    final userListingsAsync = ref.watch(userListingsProvider(targetUserId));

    final bool isMe = targetUserId == currentUserId;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMe ? 'Profilim' : 'Kullanıcı Profili'),
        actions: [
          if (isMe)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
        ],
      ),
      body: userDataAsync.when(
        data: (user) {
          if (user == null)
            return const Center(child: Text('Kullanıcı bulunamadı.'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profil Fotoğrafı
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoUrl != null
                      ? CachedNetworkImageProvider(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),

                // İsim
                Text(
                  user.displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                // ── YILDIZ BÖLÜMÜ (KESİN GÖRÜNÜR) ──
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 22),
                    Text(
                      user.rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      '(${user.ratingCount} Değerlendirme)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey),
                ),

                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],

                // ── AKSİYON BUTONLARI ──
                if (isMe) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ActionButton(
                        icon: Icons.edit,
                        label: 'Profili Düzenle',
                        onTap: () => context.push('/edit-profile'),
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.notifications_none,
                        label: 'Bildirimler',
                        onTap: () => context.push('/notifications'),
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.favorite_border,
                        label: 'Favoriler',
                        onTap: () => context.push('/favorites'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // ── İLANLARIM (GİZLİ KUTUCUK) ──
                if (isMe) ...[
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF333333)
                              : const Color(0xFFEEEEEE)),
                    ),
                    child: ExpansionTile(
                      leading:
                          Icon(Icons.storefront, color: colorScheme.primary),
                      title: Text(
                        'İlanlarım',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: userListingsAsync.when(
                        data: (listings) => Text('${listings.length} ilan'),
                        loading: () => const Text('Yükleniyor...'),
                        error: (_, __) => const Text('—'),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: userListingsAsync.when(
                            data: (listings) {
                              if (listings.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Text(
                                    'Henüz ilan yok.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: listings.length,
                                itemBuilder: (context, index) {
                                  final listing = listings[index];
                                  return ManageListingCard(listing: listing);
                                },
                              );
                            },
                            loading: () => const Padding(
                              padding: EdgeInsets.all(16),
                              child: LoadingIndicator(),
                            ),
                            error: (err, _) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('Hata: $err'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Başka kullanıcının ilanları
                  userListingsAsync.when(
                    data: (listings) {
                      if (listings.isEmpty) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text('Henüz ilan yok.'),
                        ));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Kullanıcının İlanları',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listings.length,
                            itemBuilder: (context, index) {
                              final listing = listings[index];
                              return ManageListingCard(listing: listing);
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => const LoadingIndicator(),
                    error: (err, _) => Text('Hata: $err'),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (err, _) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
