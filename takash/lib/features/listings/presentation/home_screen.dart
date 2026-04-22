import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:takash/shared/widgets/takash_icon.dart';
import '../domain/listing_category.dart';
import 'listings_controller.dart';
import 'widgets/listing_card.dart';
import 'widgets/filter_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredListings = ref.watch(filteredListingsProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: colorScheme.surface,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const TakashIcon(assetName: TakashIcon.swap, size: 22),
                ),
                const SizedBox(width: 10),
                Text(
                  'Keşfet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.tune_rounded, color: colorScheme.onSurface),
                  onPressed: () => _showFilterSheet(context),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildSearchBar(context, ref),
          ),
          SliverToBoxAdapter(
            child: _buildCategoryChips(
                context, ref, selectedCategory, colorScheme),
          ),
          SliverToBoxAdapter(
            child: _buildActiveSearchBanner(context, ref),
          ),
          filteredListings.when(
            data: (listings) {
              if (listings.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context, ref, colorScheme),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final listing = listings[index];
                      return ListingCard(
                        listing: listing,
                        onTap: () {
                          context.go('/listing/${listing.id}');
                        },
                      );
                    },
                    childCount: listings.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 56, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Bir şeyler ters gitti',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text(error.toString(),
                        style: TextStyle(
                            fontSize: 14, color: colorScheme.outline)),
                    const SizedBox(height: 20),
                    FilledButton(
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

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GestureDetector(
        onTap: () => _showSearchDialog(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              TakashIcon(
                  assetName: TakashIcon.search,
                  size: 22,
                  color: colorScheme.outline),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  query.isNotEmpty ? query : 'Ne arıyorsun?',
                  style: TextStyle(
                    color: query.isNotEmpty
                        ? colorScheme.onSurface
                        : colorScheme.outline,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (query.isNotEmpty)
                GestureDetector(
                  onTap: () =>
                      ref.read(searchQueryProvider.notifier).state = '',
                  child: Icon(Icons.close_rounded,
                      size: 20, color: colorScheme.outline),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, WidgetRef ref,
      ListingCategory? selectedCategory, ColorScheme colorScheme) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Tümü'),
              selected: selectedCategory == null,
              onSelected: (_) {
                ref.read(categoryFilterProvider.notifier).state = null;
              },
              showCheckmark: false,
            ),
          ),
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
                showCheckmark: false,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActiveSearchBanner(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    if (query.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          TakashIcon(
              assetName: TakashIcon.search,
              size: 18,
              color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"$query" için sonuçlar',
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(searchQueryProvider.notifier).state = '',
            child: Icon(Icons.close_rounded,
                size: 18, color: colorScheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    final query = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final showMyListings = ref.watch(showMyListingsProvider);
    final hasFilters =
        query.isNotEmpty || selectedCategory != null || showMyListings;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: TakashIcon(
                  assetName: TakashIcon.inventory,
                  size: 36,
                  color: colorScheme.outline),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilters ? 'Sonuç bulunamadı' : 'Henüz ilan yok',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Farklı filtreler deneyebilirsin'
                  : 'İlk ilanı sen ver!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.outline,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () {
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(categoryFilterProvider.notifier).state = null;
                  ref.read(showMyListingsProvider.notifier).state = false;
                },
                child: const Text('Filtreleri Temizle'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterSheet(),
    );
  }

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
            prefixIcon: TakashIcon(assetName: TakashIcon.search),
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
