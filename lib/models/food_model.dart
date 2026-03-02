class Food {
  final int? id;
  final String? name;
  final String? description;
  final String? category;
  final String? dietType;
  final String? measurementType;
  final String? unitName;
  final double protein;
  final double carbs;
  final double fats;
  final double? weightPerUnit;
  final String? imageUrl;

  Food({
    this.id,
    this.name,
    this.description,
    this.category,
    this.dietType,
    this.measurementType,
    this.unitName,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.weightPerUnit,
    this.imageUrl,
  });

  int get calories => ((protein * 4) + (carbs * 4) + (fats * 9)).round();

  factory Food.fromJson(Map<String, dynamic> json) {
    // Helper to get value regardless of key casing
    dynamic getValue(String key) =>
        json[key] ?? json[key[0].toUpperCase() + key.substring(1)];

    return Food(
      id: getValue('id'),
      name: getValue('name'),
      description: getValue('description'),
      category: _mapCategory(getValue('category')),
      dietType: _mapDietType(getValue('dietType')),
      measurementType: _mapMeasurementType(getValue('measurementType')),
      unitName: getValue('unitName'),
      protein: (getValue('protein') ?? 0).toDouble(),
      carbs: (getValue('carbs') ?? 0).toDouble(),
      fats: (getValue('fats') ?? 0).toDouble(),
      weightPerUnit: getValue('weightPerUnit')?.toDouble(),
      imageUrl: getValue('imageUrl') ?? getValue('image'),
    );
  }

  static String? _mapCategory(dynamic val) {
    if (val is String) return val;
    if (val is int) {
      const categories = [
        'Protein',
        'Carbs',
        'Fats',
        'Dairy',
        'Fruits',
        'Vegetables',
        'Drinks',
        'Snacks',
      ];
      if (val >= 0 && val < categories.length) return categories[val];
    }
    return null;
  }

  static String? _mapDietType(dynamic val) {
    if (val is String) return val;
    if (val is int) {
      const types = ['Vegan', 'Vegetarian', 'Pescatarian', 'Standard'];
      if (val >= 0 && val < types.length) return types[val];
    }
    return null;
  }

  static String? _mapMeasurementType(dynamic val) {
    if (val is String) return val;
    if (val is int) {
      const types = ['Weight', 'Volume', 'Unit'];
      if (val >= 0 && val < types.length) return types[val];
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'dietType': dietType,
      'measurementType': measurementType,
      'unitName': unitName,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'weightPerUnit': weightPerUnit,
      'imageUrl': imageUrl,
    };
  }
}
