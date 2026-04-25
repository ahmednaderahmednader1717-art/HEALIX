import '../entities/food_search_result_entity.dart';
import '../entities/food_details_entity.dart';

abstract class FoodSearchRepository {
  Future<List<FoodSearchResultEntity>> searchFoods(String query, {int page = 1});
  Future<FoodDetailsEntity?> getFoodDetails(String id);
}
