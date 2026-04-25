import '../repositories/food_search_repository.dart';
import '../entities/food_details_entity.dart';

class GetFoodDetailsUseCase {
  final FoodSearchRepository repository;
  GetFoodDetailsUseCase(this.repository);

  Future<FoodDetailsEntity?> call(String id) {
    return repository.getFoodDetails(id);
  }
}
