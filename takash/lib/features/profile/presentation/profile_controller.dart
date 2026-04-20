import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takash/features/profile/data/profile_repository.dart';
import 'package:takash/features/auth/domain/user_model.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {
    // Initial state is null or void
  }

  /// Profil bilgilerini (isim, bio) ve opsiyonel fotoğrafı günceller
  Future<void> updateProfile({
    required UserModel user,
    String? displayName,
    String? bio,
    File? imageFile,
  }) async {
    final repo = ref.read(profileRepositoryProvider);

    String? photoUrl = user.photoUrl;

    if (imageFile != null) {
      photoUrl = await repo.uploadProfilePhoto(user.uid, imageFile);
    }

    final updatedUser = user.copyWith(
      displayName: displayName,
      bio: bio,
      photoUrl: photoUrl,
    );

    await repo.updateProfile(updatedUser);
  }

  /// Sadece profil fotoğrafını yükler ve Firestore'daki photoUrl'i günceller
  Future<void> uploadPhoto({
    required UserModel user,
    required File imageFile,
  }) async {
    final repo = ref.read(profileRepositoryProvider);
    final photoUrl = await repo.uploadProfilePhoto(user.uid, imageFile);
    final updatedUser = user.copyWith(photoUrl: photoUrl);
    await repo.updateProfile(updatedUser);
  }

  /// Banner fotoğrafını yükler ve Firestore'daki bannerUrl'i günceller
  Future<void> uploadBanner({
    required UserModel user,
    required File imageFile,
  }) async {
    final repo = ref.read(profileRepositoryProvider);
    final bannerUrl = await repo.uploadBannerPhoto(user.uid, imageFile);
    final updatedUser = user.copyWith(bannerUrl: bannerUrl);
    await repo.updateProfile(updatedUser);
  }
}
