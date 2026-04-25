import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:test_splash/models/nutrition_models.dart';
import 'package:test_splash/services/nutrition_service.dart';
import '../providers/search_providers.dart';
import '../widgets/macro_breakdown.dart';

class FoodDetailsPage extends ConsumerWidget {
  final String id;

  const FoodDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(foodDetailsProvider(id));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: detailsAsync.when(
        data: (details) {
          if (details == null) {
            return const Center(child: Text('Food details not found.'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    if (details.imageUrl != null && details.imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: details.imageUrl!,
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 350,
                          color: colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 350,
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.broken_image_rounded, size: 64, color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    else
                      Container(
                        height: 350,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.fastfood_rounded, size: 64, color: colorScheme.onSurfaceVariant),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Text(
                        details.name,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      if (details.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            details.category!,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      MacroBreakdown(
                        calories: details.calories,
                        protein: details.protein,
                        carbs: details.carbs,
                        fats: details.fats,
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            final date = DateTime.now().toIso8601String().split('T').first;
                            final logItem = NutritionLog(
                              id: -DateTime.now().millisecondsSinceEpoch,
                              foodId: -DateTime.now().millisecondsSinceEpoch,
                              foodName: details.name,
                              imageUrl: details.imageUrl,
                              quantity: 100,
                              protein: details.protein,
                              carbs: details.carbs,
                              fats: details.fats,
                              calories: details.calories,
                              date: date,
                            );

                            NutritionService().saveLocalLog(logItem, date).then((_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Success! Food logged to diary.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Add to Daily Log',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Could not load details'),
              TextButton(
                onPressed: () => ref.refresh(foodDetailsProvider(id)),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
