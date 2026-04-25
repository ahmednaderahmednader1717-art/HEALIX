import '../repositories/food_search_repository.dart';
import '../entities/food_search_result_entity.dart';

class SearchFoodsUseCase {
  final FoodSearchRepository repository;
  SearchFoodsUseCase(this.repository);

  Future<List<FoodSearchResultEntity>> call(String query, {int page = 1}) {
    return repository.searchFoods(query, page: page);
  }
}
