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
    final distance = ref.watch(distanceFilterProvider);
    final dateFilter = ref.watch(dateFilterProvider);
    final sortBy = ref.watch(sortByProvider);
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
                  ref.read(distanceFilterProvider.notifier).state = 50.0;
                  ref.read(dateFilterProvider.notifier).state = DateFilter.all;
                  ref.read(sortByProvider.notifier).state = SortBy.newest;
                },
                child: const Text('Temizle'),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
          Text(
            'Mesafe',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: distance,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: '${distance.toInt()} km',
                  onChanged: (value) {
                    ref.read(distanceFilterProvider.notifier).state = value;
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '${distance.toInt()} km',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tarih',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: DateFilter.values.length,
              itemBuilder: (context, index) {
                final date = DateFilter.values[index];
                final isSelected = dateFilter == date;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(date.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(dateFilterProvider.notifier).state = date;
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sırala',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: SortBy.values.length,
              itemBuilder: (context, index) {
                final sort = SortBy.values[index];
                final isSelected = sortBy == sort;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(sort.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(sortByProvider.notifier).state = sort;
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Kendi İlanlarımı Göster'),
            value: showMyListings,
            onChanged: (value) {
              ref.read(showMyListingsProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: 24),
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
