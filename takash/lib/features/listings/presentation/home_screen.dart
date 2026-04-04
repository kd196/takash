import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/listing_category.dart';
import 'listings_controller.dart';
import 'widgets/listing_card.dart';
import 'widgets/filter_sheet.dart';

/// Ana sayfa — Letgo tarzı grid layout
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredListings = ref.watch(filteredListingsProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keşfet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Arama Çubuğu ──
          _buildSearchBar(context, ref),

          // ── Kategori Filtreleri ──
          _buildCategoryChips(context, ref, selectedCategory, colorScheme),

          // ── Aktif Arama Göstergesi ──
          _buildActiveSearchBanner(context, ref),

          // ── İlan Listesi ──
          Expanded(
            child: filteredListings.when(
              data: (listings) {
                if (listings.isEmpty) {
                  return _buildEmptyState(context, ref, colorScheme);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    // ignore: unused_result
                    ref.refresh(allListingsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      final cardHeight =
                          (MediaQuery.of(context).size.height - 300) / 2;
                      return SizedBox(
                        height: cardHeight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListingCard(
                            listing: listing,
                            onTap: () {
                              context.go('/listing/${listing.id}');
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text('İlanlar yüklenirken hata oluştu',
                        style: TextStyle(color: colorScheme.error)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.refresh(allListingsProvider),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Minimal arama çubuğu
  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: GestureDetector(
        onTap: () => _showSearchDialog(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade600),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  query.isNotEmpty ? query : 'Ne arıyorsun?',
                  style: TextStyle(
                    color: query.isNotEmpty
                        ? Colors.black87
                        : Colors.grey.shade600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                  child: Icon(Icons.clear, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kategori filtre chip'leri
  Widget _buildCategoryChips(BuildContext context, WidgetRef ref,
      ListingCategory? selectedCategory, ColorScheme colorScheme) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // "Hepsi" chip'i
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Hepsi'),
              selected: selectedCategory == null,
              onSelected: (_) {
                ref.read(categoryFilterProvider.notifier).state = null;
              },
              selectedColor: colorScheme.primaryContainer,
            ),
          ),
          // Kategori chip'leri
          ...ListingCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text('${category.icon} ${category.label}'),
                selected: selectedCategory == category,
                onSelected: (_) {
                  ref.read(categoryFilterProvider.notifier).state =
                      selectedCategory == category ? null : category;
                },
                selectedColor: colorScheme.primaryContainer,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Aktif arama varsa banner göster
  Widget _buildActiveSearchBanner(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search,
              size: 18,
              color: Theme.of(context).colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"$query" için sonuçlar',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(searchQueryProvider.notifier).state = '';
            },
            child: Icon(Icons.close,
                size: 18,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }

  /// Boş durum ekranı
  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    final query = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final showMyListings = ref.watch(showMyListingsProvider);
    final hasFilters =
        query.isNotEmpty || selectedCategory != null || showMyListings;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'Eşleşen ilan bulunamadı' : 'Henüz ilan yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Farklı bir arama yapmayı veya filtreleri temizlemeyi dene.'
                  : 'İlk ilanı sen oluştur!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(categoryFilterProvider.notifier).state = null;
                  ref.read(showMyListingsProvider.notifier).state = false;
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Filtreleri Temizle'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Filtre sheet'i göster
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterSheet(),
    );
  }

  /// Arama dialog'u
  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final controller =
        TextEditingController(text: ref.read(searchQueryProvider));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlan Ara'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Başlık veya açıklama ara...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            ref.read(searchQueryProvider.notifier).state = value.trim();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = '';
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state =
                  controller.text.trim();
              Navigator.pop(context);
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }
}
