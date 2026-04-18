import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../domain/listing_category.dart';
import '../domain/listing_model.dart';
import 'listings_controller.dart';

/// İlan düzenleme ekranı
class EditListingScreen extends ConsumerStatefulWidget {
  final String listingId;
  const EditListingScreen({super.key, required this.listingId});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _wantedItemController;
  ListingCategory _selectedCategory = ListingCategory.other;
  final List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  final _picker = ImagePicker();
  ListingModel? _originalListing;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _wantedItemController = TextEditingController();

    // Veriyi çek
    Future.microtask(() => _fetchListing());
  }

  Future<void> _fetchListing() async {
    final listing =
        await ref.read(singleListingProvider(widget.listingId).future);
    if (listing != null && mounted) {
      setState(() {
        _originalListing = listing;
        _titleController.text = listing.title;
        _descriptionController.text = listing.description;
        _wantedItemController.text = listing.wantedItem;
        _selectedCategory = listing.category;
        _existingImageUrls = List.from(listing.imageUrls);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _wantedItemController.dispose();
    super.dispose();
  }

  /// Fotoğraf seç (galeri veya kamera)
  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length + _existingImageUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En fazla 5 fotoğraf ekleyebilirsiniz')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
      });
    }
  }

  /// Fotoğraf seçme bottom sheet'i göster
  void _showImageSourceSheet() {
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
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Fotoğraf Çek'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// İlanı güncelle
  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_originalListing == null) return;

    if (_selectedImages.isEmpty && _existingImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az 1 fotoğraf olmalı')),
      );
      return;
    }

    final controller = ref.read(createListingControllerProvider.notifier);

    final updatedListing = _originalListing!.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      wantedItem: _wantedItemController.text.trim(),
      // Not: Controller image upload kısmını handle ediyor eğer newImages verilirse.
      // Ancak mevcut controller tasarımı sadece newImages varsa her şeyi siliyor ve yenilerini yüklüyor.
      // Bu basit MVP tasarımı olduğu için şimdilik öyle bırakabiliriz ya da iyileştirebiliriz.
      // Kullanıcının isteği doğrultusunda "Düzenle" ekranını yapıyorum.
    );

    final success = await controller.updateListing(
      listing: updatedListing,
      newImages: _selectedImages.isNotEmpty ? _selectedImages : null,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İlan başarıyla güncellendi! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Geri dön
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Güncellenirken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_originalListing == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final asyncState = ref.watch(createListingControllerProvider);
    final isLoading = asyncState.isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlanı Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Fotoğraf Seçici ──
              _buildImageSection(colorScheme),
              const SizedBox(height: 24),

              // ── Başlık ──
              TextFormField(
                controller: _titleController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'İlan Başlığı',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Başlık gerekli';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Açıklama ──
              TextFormField(
                controller: _descriptionController,
                maxLength: 500,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Açıklama gerekli';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Kategori ──
              DropdownButtonFormField<ListingCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
                items: ListingCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text('${category.icon}  ${category.label}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),

              // ── Karşılığında Ne İstiyorum ──
              TextFormField(
                controller: _wantedItemController,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Karşılığında Ne İstiyorsun?',
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty)
                    return 'Bu alan gerekli';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ── Güncelle Butonu ──
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _updateListing,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                      isLoading ? 'Güncelleniyor...' : 'Değişiklikleri Kaydet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotoğraflar (${_selectedImages.length + _existingImageUrls.length}/5)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (_selectedImages.length + _existingImageUrls.length < 5)
                _buildAddImageButton(colorScheme),

              // Mevcut Fotoğraflar (Network)
              ..._existingImageUrls.map((url) => _buildImageItem(url: url)),

              // Yeni Seçilen Fotoğraflar (File)
              ..._selectedImages.map((file) => _buildImageItem(file: file)),
            ],
          ),
        ),
        if (_selectedImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '* Yeni fotoğraf eklediğinizde tüm eski fotoğraflar silinecektir.',
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildAddImageButton(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: _showImageSourceSheet,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 32, color: colorScheme.primary),
              const Text('Ekle'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem({String? url, File? file}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: url != null
                ? Image.network(url, width: 120, height: 120, fit: BoxFit.cover)
                : Image.file(file!, width: 120, height: 120, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (url != null) _existingImageUrls.remove(url);
                  if (file != null) _selectedImages.remove(file);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
