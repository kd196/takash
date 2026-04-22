import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takash/features/auth/domain/user_model.dart';
import 'package:takash/features/profile/data/profile_repository.dart';
import 'package:takash/features/profile/presentation/profile_controller.dart';
import 'package:takash/shared/widgets/custom_button.dart';
import 'package:takash/shared/widgets/custom_text_field.dart';
import 'package:takash/shared/widgets/loading_indicator.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  File? _selectedImage;
  File? _selectedBanner;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera ile Çek'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      _selectedBanner = File(picked.path);
    });
  }

  Future<void> _saveProfile(UserModel user) async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(profileControllerProvider.notifier);

    try {
      await controller.updateProfile(
        user: user,
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        imageFile: _selectedImage,
      );

      if (_selectedBanner != null) {
        await controller.uploadBanner(
          user: user,
          imageFile: _selectedBanner!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil başarıyla güncellendi.')),
        );
        Navigator.pop(context);
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
    final userProfileAsync = ref.watch(userProfileProvider);
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
      ),
      body: userProfileAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Hata!'));

          if (!_initialized) {
            _nameController = TextEditingController(text: user.displayName);
            _bioController = TextEditingController(text: user.bio ?? '');
            _initialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (user.photoUrl != null
                                  ? CachedNetworkImageProvider(user.photoUrl!)
                                      as ImageProvider
                                  : null),
                          child: _selectedImage == null && user.photoUrl == null
                              ? const Icon(Icons.person_rounded,
                                  size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  size: 18, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Ad Soyad',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'İsim boş olamaz.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Hakkında',
                    controller: _bioController,
                    prefixIcon: Icons.info_outline,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Değişiklikleri Kaydet',
                    isLoading: profileState.isLoading,
                    onPressed: () => _saveProfile(user),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}
