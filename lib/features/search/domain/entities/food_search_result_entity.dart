class FoodSearchResultEntity {
  final String id;
  final String name;
  final String? brand;
  final String? imageUrl;
  final double calories;

  const FoodSearchResultEntity({
    required this.id,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.calories,
  });
}
