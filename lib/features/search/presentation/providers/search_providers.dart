import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/food_search_result_entity.dart';
import '../../domain/usecases/search_foods_usecase.dart';
import '../../domain/usecases/get_food_details_usecase.dart';
import '../../data/repositories_impl/food_search_repository_impl.dart';
import '../../domain/entities/food_details_entity.dart';
import 'dart:async';

final searchFoodsUseCaseProvider = Provider<SearchFoodsUseCase>((ref) {
  return SearchFoodsUseCase(ref.watch(foodSearchRepositoryProvider));
});

final getFoodDetailsUseCaseProvider = Provider<GetFoodDetailsUseCase>((ref) {
  return GetFoodDetailsUseCase(ref.watch(foodSearchRepositoryProvider));
});

class SearchResultsNotifier extends AutoDisposeAsyncNotifier<List<FoodSearchResultEntity>> {
  Timer? _debounce;
  String _lastQuery = '';

  @override
  FutureOr<List<FoodSearchResultEntity>> build() {
    ref.onDispose(() => _debounce?.cancel());
    return [];
  }

  void search(String query) {
    if (query == _lastQuery) return;
    _lastQuery = query;

    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final usecase = ref.read(searchFoodsUseCaseProvider);
        final results = await usecase.call(query);
        if (!ref.exists(searchResultsNotifierProvider)) return;
        state = AsyncValue.data(results);
      } catch (e, stack) {
        if (!ref.exists(searchResultsNotifierProvider)) return;
        state = AsyncValue.error(e, stack);
      }
    });
  }
}

final searchResultsNotifierProvider = AutoDisposeAsyncNotifierProvider<SearchResultsNotifier, List<FoodSearchResultEntity>>(
  () => SearchResultsNotifier(),
);

final foodDetailsProvider = FutureProvider.autoDispose.family<FoodDetailsEntity?, String>((ref, id) async {
  final usecase = ref.watch(getFoodDetailsUseCaseProvider);
  return usecase.call(id);
});
