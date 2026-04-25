class FoodDetailsEntity {
  final String id;
  final String name;
  final String? category;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String? imageUrl;

  const FoodDetailsEntity({
    required this.id,
    required this.name,
    this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.imageUrl,
  });
}
