import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../listings_controller.dart';
import '../../domain/listing_category.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(categoryFilterProvider);
    final showMyListings = ref.watch(showMyListingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrele',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(categoryFilterProvider.notifier).state = null;
                  ref.read(showMyListingsProvider.notifier).state = false;
                  ref.read(searchQueryProvider.notifier).state = '';
                },
                child: const Text('Temizle'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Kategori Seçimi
          Text(
            'Kategori',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ListingCategory.values.length,
              itemBuilder: (context, index) {
                final category = ListingCategory.values[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('${category.icon} ${category.label}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(categoryFilterProvider.notifier).state =
                          selected ? category : null;
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Seçenekler
          Text(
            'Ayarlar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Kendi İlanlarımı Göster'),
            subtitle: const Text('Keşfet akışında kendi ilanların yer alsın mı?'),
            value: showMyListings,
            onChanged: (value) {
              ref.read(showMyListingsProvider.notifier).state = value;
            },
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Uygula'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
