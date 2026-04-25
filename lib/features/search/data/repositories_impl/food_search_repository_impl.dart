import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/food_search_repository.dart';
import '../../domain/entities/food_search_result_entity.dart';
import '../../domain/entities/food_details_entity.dart';
import '../datasources/open_food_facts_remote_data_source.dart';
import '../models/off_models.dart';
import 'package:test_splash/core/network/dio_client.dart';

final foodSearchRepositoryProvider = Provider<FoodSearchRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final dataSource = OpenFoodFactsRemoteDataSource(dio);
  return FoodSearchRepositoryImpl(dataSource);
});

class FoodSearchRepositoryImpl implements FoodSearchRepository {
  final OpenFoodFactsRemoteDataSource remoteDataSource;

  FoodSearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<FoodSearchResultEntity>> searchFoods(String query, {int page = 1}) async {
    final response = await remoteDataSource.searchFoods(query, page);
    final products = response['products'] as List<dynamic>? ?? [];
    
    return products.map((json) {
      final product = OffProduct.fromJson(json as Map<String, dynamic>);
      return FoodSearchResultEntity(
        id: product.code ?? product.id ?? '',
        name: product.productName ?? product.productNameEn ?? 'Unknown',
        brand: product.brands,
        imageUrl: product.imageFrontSmallUrl ?? product.imageUrl,
        calories: _extractCalories(product.nutriments),
      );
    }).where((item) => item.id.isNotEmpty && item.name != 'Unknown').toList();
  }

  @override
  Future<FoodDetailsEntity?> getFoodDetails(String id) async {
    final response = await remoteDataSource.getFoodDetails(id);
    final json = response['product'] as Map<String, dynamic>?;
    if (json == null) return null;

    final product = OffProduct.fromJson(json);
    
    return FoodDetailsEntity(
      id: product.code ?? product.id ?? '',
      name: product.productName ?? product.productNameEn ?? 'Unknown',
      category: product.categories?.split(',').first.trim(),
      calories: _extractCalories(product.nutriments),
      protein: _extractMacro(product.nutriments, ['proteins_100g', 'proteins']),
      carbs: _extractMacro(product.nutriments, ['carbohydrates_100g', 'carbohydrates']),
      fats: _extractMacro(product.nutriments, ['fat_100g', 'fat']),
      imageUrl: product.imageUrl ?? product.imageFrontSmallUrl,
    );
  }

  double _extractCalories(Map<String, dynamic>? nutriments) {
    if (nutriments == null) return 0.0;
    final val = nutriments['energy-kcal_100g'] ?? nutriments['energy_100g'] ?? nutriments['energy-kcal'];
    return (val as num?)?.toDouble() ?? 0.0;
  }

  double _extractMacro(Map<String, dynamic>? nutriments, List<String> keys) {
    if (nutriments == null) return 0.0;
    for (final key in keys) {
      final val = nutriments[key];
      if (val != null) {
        return (val as num).toDouble();
      }
    }
    return 0.0;
  }
}
