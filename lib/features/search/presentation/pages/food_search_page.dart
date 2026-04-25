import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../domain/entities/food_search_result_entity.dart';
import '../providers/search_providers.dart';
import '../widgets/search_result_card.dart';
import 'food_details_page.dart';

class FoodSearchPage extends ConsumerWidget {
  const FoodSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchResultsNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Search Food'),
      ),
      body: Column(
        children: [
          _buildSearchBar(context, ref),
          Expanded(
            child: searchState.when(
              data: (results) {
                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Discover global food entries',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return SearchResultCard(
                      entity: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailsPage(id: item.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong.',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: 6,
                itemBuilder: (context, index) => Skeletonizer(
                  enabled: true,
                  child: SearchResultCard(
                    entity: const FoodSearchResultEntity(
                      id: '',
                      name: 'Loading Item Name',
                      calories: 0,
                    ),
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          ref.read(searchResultsNotifierProvider.notifier).search(value);
        },
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search for any food...',
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
