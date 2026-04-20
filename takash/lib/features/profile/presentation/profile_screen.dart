import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../listings/presentation/listings_controller.dart';
import '../../auth/domain/user_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _pickBanner(UserModel user) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    try {
      final controller = ref.read(profileControllerProvider.notifier);
      await controller.uploadBanner(
        user: user,
        imageFile: File(picked.path),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner yüklendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authStateProvider).value?.uid;
    final targetUserId = widget.userId ?? currentUserId;

    if (targetUserId == null) {
      return const Center(child: Text('Giriş yapmalısınız.'));
    }

    final userDataAsync = ref.watch(userDataProvider(targetUserId));
    final bool isMe = targetUserId == currentUserId;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: userDataAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Kullanıcı bulunamadı.'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                stretch: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: colorScheme.primary,
                actions: [
                  if (isMe)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.settings_rounded,
                            color: Colors.white),
                        onPressed: () => context.push('/settings'),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (user.bannerUrl != null)
                        CachedNetworkImage(
                          imageUrl: user.bannerUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              _buildGradientBanner(colorScheme),
                        )
                      else
                        _buildGradientBanner(colorScheme),
                      Container(
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      if (isMe)
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: GestureDetector(
                            onTap: () => _pickBanner(user),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 48),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                backgroundImage: user.photoUrl != null
                                    ? CachedNetworkImageProvider(user.photoUrl!)
                                    : null,
                                child: user.photoUrl == null
                                    ? const Icon(Icons.person_rounded,
                                        size: 48, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.displayName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (user.bio != null && user.bio!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  user.bio!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '${user.rating.toStringAsFixed(1)} ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '(${user.ratingCount})',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      children: [
                        _QuickAction(
                          icon: Icons.edit_rounded,
                          label: 'Düzenle',
                          color: colorScheme.primary,
                          onTap: () => context.push('/profile/edit'),
                        ),
                        const SizedBox(height: 8),
                        _QuickAction(
                          icon: Icons.favorite_rounded,
                          label: 'Favoriler',
                          color: Colors.red,
                          onTap: () => context.push('/profile/favorites'),
                        ),
                        const SizedBox(height: 8),
                        _QuickAction(
                          icon: Icons.notifications_none_rounded,
                          label: 'Bildirimler',
                          color: colorScheme.tertiary,
                          onTap: () => context.push('/notifications'),
                        ),
                        const SizedBox(height: 8),
                        _QuickAction(
                          icon: Icons.inventory_2_rounded,
                          label: 'İlanlarım',
                          color: colorScheme.secondary,
                          onTap: () => context.push('/profile/my-listings'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, _) => Center(child: Text('Hata: $err')),
      ),
    );
  }

  Widget _buildGradientBanner(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 21, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}
