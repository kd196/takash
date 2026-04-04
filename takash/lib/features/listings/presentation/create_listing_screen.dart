import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:takash/features/map/data/location_service.dart';
import '../domain/listing_category.dart';
import 'listings_controller.dart';

/// İlan oluşturma / düzenleme ekranı
class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _wantedItemController = TextEditingController();
  
  ListingCategory _selectedCategory = ListingCategory.other;
  GeoPoint? _selectedLocation;
  bool _isGettingLocation = false;
  final List<File> _selectedImages = [];
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _wantedItemController.dispose();
    super.dispose();
  }

  /// Fotoğraf seç (galeri veya kamera)
  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
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

  /// Mevcut konumu GPS'ten al
  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final service = ref.read(locationServiceProvider);
      final position = await service.getCurrentLocation();
      if (position != null) {
        setState(() {
          _selectedLocation = GeoPoint(position.latitude, position.longitude);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konum başarıyla eklendi! 📍'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum izni verilmedi veya GPS kapalı.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  /// İlanı yayınla
  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az 1 fotoğraf eklemelisiniz')),
      );
      return;
    }

    final controller = ref.read(createListingControllerProvider.notifier);

    final result = await controller.createListing(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      wantedItem: _wantedItemController.text.trim(),
      images: _selectedImages,
      location: _selectedLocation,
    );

    if (mounted) {
      if (result != null) {
        // Formu temizle
        _titleController.clear();
        _descriptionController.clear();
        _wantedItemController.clear();
        setState(() {
          _selectedImages.clear();
          _selectedCategory = ListingCategory.other;
          _selectedLocation = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İlan başarıyla yayınlandı! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/profile/my-listings');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İlan yayınlanırken bir hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(createListingControllerProvider);
    final isLoading = asyncState is AsyncLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan'),
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
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Başlık gerekli' : null,
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
                validator: (value) => (value == null || value.trim().length < 10) ? 'En az 10 karakter' : null,
              ),
              const SizedBox(height: 16),

              // ── Kategori ──
              DropdownButtonFormField<ListingCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category)),
                items: ListingCategory.values.map((category) {
                  return DropdownMenuItem(value: category, child: Text('${category.icon}  ${category.label}'));
                }).toList(),
                onChanged: (value) { if (value != null) setState(() => _selectedCategory = value); },
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
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Bu alan gerekli' : null,
              ),
              const SizedBox(height: 24),

              // ── Konum Seçici ──
              _buildLocationSection(colorScheme),
              const SizedBox(height: 32),

              // ── Yayınla Butonu ──
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submitListing,
                  icon: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.publish),
                  label: Text(isLoading ? 'Yayınlanıyor...' : 'İlanı Yayınla'),
                  style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Konum Bilgisi', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isGettingLocation ? null : _getCurrentLocation,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _selectedLocation != null ? colorScheme.primary.withOpacity(0.05) : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selectedLocation != null ? colorScheme.primary : Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedLocation != null ? Icons.location_on : Icons.location_on_outlined,
                  color: _selectedLocation != null ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedLocation != null 
                      ? 'Konum Eklendi (${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)})'
                      : 'Mevcut Konumumu Kullan',
                    style: TextStyle(
                      color: _selectedLocation != null ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      fontWeight: _selectedLocation != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (_isGettingLocation)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else if (_selectedLocation != null)
                  GestureDetector(
                    onTap: () => setState(() => _selectedLocation = null),
                    child: Icon(Icons.close, size: 20, color: colorScheme.primary),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fotoğraflar (${_selectedImages.length}/5)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (_selectedImages.length < 5)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeriden Seç'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
                            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Fotoğraf Çek'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
                          ],
                        ),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                        borderRadius: BorderRadius.circular(12),
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 32, color: colorScheme.primary), const Text('Ekle', style: TextStyle(fontWeight: FontWeight.w500))]),
                    ),
                  ),
                ),
              ...List.generate(_selectedImages.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImages[index], width: 120, height: 120, fit: BoxFit.cover)),
                      Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => _selectedImages.removeAt(index)), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 16)))),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
