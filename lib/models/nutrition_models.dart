/// A single logged food entry.
class NutritionLog {
  final int id;
  final int foodId;
  final String foodName;
  final String? imageUrl;
  final double quantity;
  final String? unitName;
  final String? measurementType;
  final double protein;
  final double carbs;
  final double fats;
  final double calories;
  final String date;

  // ── AI meal sync fields (original per-100g values for server food creation) ──
  final double? originalProteinPer100;
  final double? originalCarbsPer100;
  final double? originalFatsPer100;
  final String? category;
  final double? weightPerUnit;
  final String? description;

  NutritionLog({
    required this.id,
    required this.foodId,
    required this.foodName,
    this.imageUrl,
    required this.quantity,
    this.unitName,
    this.measurementType,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.calories,
    required this.date,
    this.originalProteinPer100,
    this.originalCarbsPer100,
    this.originalFatsPer100,
    this.category,
    this.weightPerUnit,
    this.description,
  });

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    // Highly aggressive key lookup: camelCase, PascalCase, snake_case
    dynamic g(String key) {
      if (json[key] != null) return json[key];
      // PascalCase
      final pascal = key[0].toUpperCase() + key.substring(1);
      if (json[pascal] != null) return json[pascal];
      // sneak_case (very simple conversion for common short keys)
      final snake = key.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (m) => '_${m.group(1)!.toLowerCase()}',
      );
      if (json[snake] != null) return json[snake];
      return null;
    }

    // Try multiple names in order, return the first non-null found.
    dynamic first(List<String> keys) {
      for (final k in keys) {
        final v = g(k);
        if (v != null) return v;
      }
      return null;
    }

    // Specialized helper for macros: prefers non-zero values if available.
    double macro(List<String> keys) {
      for (final k in keys) {
        final v = g(k);
        if (v != null) {
          final d = (v as num).toDouble();
          if (d != 0) return d;
        }
      }
      // If all are zero, return the first found or 0.
      return (first(keys) as num? ?? 0).toDouble();
    }

    return NutritionLog(
      id: first(['id', 'logId', 'log_id']) ?? 0,
      foodId: first(['foodId', 'food_id', 'FoodId']) ?? 0,
      foodName: first(['foodName', 'food_name', 'name', 'foodTitle']) ?? '',
      imageUrl: first(['imageUrl', 'image', 'imageURL', 'foodImageUrl']),
      quantity: (first(['quantity', 'amount', 'servingSize']) ?? 0).toDouble(),
      unitName: first(['unitName', 'unit', 'servingUnit']),
      measurementType: first(['measurementType', 'measurement_type']),
      protein: macro([
        'proteinConsumed',
        'proteinAmount',
        'proteinGrams',
        'protein',
        'totalProtein',
        'protein_consumed',
        'protein_amount',
      ]),
      carbs: macro([
        'carbsConsumed',
        'carbAmount',
        'carbsGrams',
        'carbohydratesConsumed',
        'carbs',
        'carbohydrates',
        'totalCarbs',
        'carbs_consumed',
        'carb_amount',
      ]),
      fats: macro([
        'fatsConsumed',
        'fatAmount',
        'fatsGrams',
        'fats',
        'fat',
        'totalFats',
        'fats_consumed',
        'fat_amount',
      ]),
      calories: macro([
        'caloriesConsumed',
        'energyKcal',
        'calories',
        'totalCalories',
        'calorie',
        'kcal',
        'calories_consumed',
      ]),
      date: first(['date', 'logDate', 'log_date'])?.toString() ?? '',
      // AI sync fields
      originalProteinPer100: (g('originalProteinPer100') as num?)?.toDouble(),
      originalCarbsPer100: (g('originalCarbsPer100') as num?)?.toDouble(),
      originalFatsPer100: (g('originalFatsPer100') as num?)?.toDouble(),
      category: g('category')?.toString(),
      weightPerUnit: (g('weightPerUnit') as num?)?.toDouble(),
      description: g('description')?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unitName': unitName,
      'measurementType': measurementType,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'calories': calories,
      'date': date,
      // AI sync fields (only present for scanned meals)
      if (originalProteinPer100 != null) 'originalProteinPer100': originalProteinPer100,
      if (originalCarbsPer100 != null) 'originalCarbsPer100': originalCarbsPer100,
      if (originalFatsPer100 != null) 'originalFatsPer100': originalFatsPer100,
      if (category != null) 'category': category,
      if (weightPerUnit != null) 'weightPerUnit': weightPerUnit,
      if (description != null) 'description': description,
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Summary
// ─────────────────────────────────────────────────────────────────────────────

/// Response from GET /api/nutrition/daily-summary
class DailySummary {
  final String date;
  final double totalCalories;
  final double calorieGoal;
  final double remainingCalories;
  final double totalProtein;
  final double proteinGoal;
  final double totalCarbs;
  final double carbsGoal;
  final double totalFats;
  final double fatsGoal;
  final List<NutritionLog> logs;

  DailySummary({
    required this.date,
    required this.totalCalories,
    required this.calorieGoal,
    required this.remainingCalories,
    required this.totalProtein,
    required this.proteinGoal,
    required this.totalCarbs,
    required this.carbsGoal,
    required this.totalFats,
    required this.fatsGoal,
    required this.logs,
  });

  /// Protein/carbs/fats as percentages of total macro calories (for ring).
  double get totalMacroCalories =>
      (totalProtein * 4) + (totalCarbs * 4) + (totalFats * 9);

  double get proteinPercent =>
      totalMacroCalories == 0 ? 0 : (totalProtein * 4) / totalMacroCalories;
  double get carbsPercent =>
      totalMacroCalories == 0 ? 0 : (totalCarbs * 4) / totalMacroCalories;
  double get fatsPercent =>
      totalMacroCalories == 0 ? 0 : (totalFats * 9) / totalMacroCalories;

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    // Some backends wrap the whole response in a "data" object
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data']
        : json;

    dynamic get(String key) {
      if (data[key] != null) return data[key];
      final pascal = key[0].toUpperCase() + key.substring(1);
      if (data[pascal] != null) return data[pascal];
      final snake = key.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (m) => '_${m.group(1)!.toLowerCase()}',
      );
      if (data[snake] != null) return data[snake];
      return null;
    }

    // Parse logs first.
    final rawLogs =
        get('loggedFoods') ??
        get('logs') ??
        get('foodLogs') ??
        get('nutritionLogs') ??
        [];
    final logs = (rawLogs as List)
        .map((e) => NutritionLog.fromJson(e as Map<String, dynamic>))
        .toList();

    // Sum macros from logs — reliable even when the API omits aggregate fields.
    final logsProtein = logs.fold(0.0, (s, l) => s + l.protein);
    final logsCarbs = logs.fold(0.0, (s, l) => s + l.carbs);
    final logsFats = logs.fold(0.0, (s, l) => s + l.fats);
    final logsCalories = logs.fold(0.0, (s, l) => s + l.calories);

    // Prefer API top-level totals (including *Consumed variants); fall back to log-computed values.
    double pick(List<String> keys, double fallback) {
      for (final k in keys) {
        final val = get(k);
        if (val != null) {
          double? d;
          if (val is num) d = val.toDouble();
          if (val is String) d = double.tryParse(val);
          if (d != null && d != 0) return d;
        }
      }
      return fallback;
    }

    final totalProtein = pick([
      'totalProteinG',
      'totalProteinConsumed',
      'proteinConsumed',
      'totalProtein',
      'protein',
      'proteins',
      'total_protein_consumed',
      'protein_consumed',
    ], logsProtein);

    final totalCarbs = pick([
      'totalCarbsG',
      'totalCarbohydratesConsumed',
      'carbohydratesConsumed',
      'carbsConsumed',
      'totalCarbs',
      'carbohydrates',
      'totalCarbohydrates',
      'carbs',
      'total_carbohydrates_consumed',
      'carbs_consumed',
    ], logsCarbs);

    final totalFats = pick([
      'totalFatsG',
      'totalFatsConsumed',
      'totalFatConsumed',
      'fatsConsumed',
      'fatConsumed',
      'totalFats',
      'totalFat',
      'fats',
      'fat',
      'total_fats_consumed',
      'fats_consumed',
    ], logsFats);

    final totalCalories = pick([
      'totalCaloriesConsumed',
      'caloriesConsumed',
      'totalCalories',
      'calories',
      'total_calories_consumed',
      'calories_consumed',
    ], logsCalories);

    final calorieGoal = pick([
      'calorieGoal',
      'dailyCalorieGoal',
      'goalCalories',
      'maxCalories',
      'daily_calorie_goal',
    ], 0);

    // Dynamic fallbacks if macros aren't explicitly provided by backend
    // Common split: 25% Protein, 45% Carbs, 30% Fat
    final proteinGoal = pick([
      'proteinGoal',
      'dailyProteinGoal',
      'protein_goal',
    ], (calorieGoal * 0.25) / 4);

    final carbsGoal = pick([
      'carbsGoal',
      'dailyCarbsGoal',
      'carbs_goal',
    ], (calorieGoal * 0.45) / 4);

    final fatsGoal = pick([
      'fatsGoal',
      'dailyFatsGoal',
      'fats_goal',
    ], (calorieGoal * 0.30) / 9);

    final remainingCalories =
        (get('remainingCalories') as num?)?.toDouble() ??
        (calorieGoal - totalCalories);

    return DailySummary(
      date: get('date')?.toString() ?? '',
      totalCalories: totalCalories,
      calorieGoal: calorieGoal,
      remainingCalories: remainingCalories,
      totalProtein: totalProtein,
      proteinGoal: proteinGoal,
      totalCarbs: totalCarbs,
      carbsGoal: carbsGoal,
      totalFats: totalFats,
      fatsGoal: fatsGoal,
      logs: logs,
    );
  }

  /// Empty summary for a given date (no data yet).
  factory DailySummary.empty(String date) => DailySummary(
    date: date,
    totalCalories: 0,
    calorieGoal: 0,
    remainingCalories: 0,
    totalProtein: 0,
    proteinGoal: 0,
    totalCarbs: 0,
    carbsGoal: 0,
    totalFats: 0,
    fatsGoal: 0,
    logs: [],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Monthly Summary
// ─────────────────────────────────────────────────────────────────────────────

/// A single day's entry in the monthly summary.
class DaySummary {
  final String date;
  final double totalCalories;
  final double calorieGoal;
  final double protein;
  final double carbs;
  final double fats;
  final bool goalAchieved;
  final bool hasData;

  DaySummary({
    required this.date,
    required this.totalCalories,
    required this.calorieGoal,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.goalAchieved,
    required this.hasData,
  });

  factory DaySummary.fromJson(Map<String, dynamic> json) {
    dynamic g(String key) {
      if (json[key] != null) return json[key];
      final pascal = key[0].toUpperCase() + key.substring(1);
      if (json[pascal] != null) return json[pascal];
      final snake = key.replaceAllMapped(
        RegExp(r'([A-Z])'),
        (m) => '_${m.group(1)!.toLowerCase()}',
      );
      if (json[snake] != null) return json[snake];
      return null;
    }

    double macro(List<String> keys) {
      for (final k in keys) {
        final v = g(k);
        if (v != null) return (v as num).toDouble();
      }
      return 0.0;
    }

    final goal = macro([
      'calorieGoal',
      'dailyCalorieGoal',
      'goalCalories',
      'maxCalories',
    ]);
    final cal = macro([
      'totalCalories',
      'calories',
      'totalCaloriesConsumed',
      'calories_consumed',
    ]);

    return DaySummary(
      date: g('date')?.toString() ?? '',
      totalCalories: cal,
      calorieGoal: goal,
      protein: macro([
        'totalProtein',
        'protein',
        'totalProteinG',
        'proteinConsumed',
        'protein_consumed',
      ]),
      carbs: macro([
        'totalCarbs',
        'carbs',
        'totalCarbsG',
        'carbohydrates',
        'carbs_consumed',
      ]),
      fats: macro([
        'totalFats',
        'fats',
        'totalFatsG',
        'fatsConsumed',
        'fats_consumed',
      ]),
      goalAchieved:
          g('goalAchieved') ?? g('isGoalAchieved') ?? (goal > 0 && cal >= goal),
      hasData: g('hasData') ?? g('hasLogs') ?? (cal > 0),
    );
  }
}

/// Response from GET /api/nutrition/monthly-summary
class MonthlySummary {
  final List<DaySummary> days;

  MonthlySummary({required this.days});

  factory MonthlySummary.fromJson(dynamic json) {
    if (json is List) {
      return MonthlySummary(
        days: json
            .map((e) => DaySummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    final list = (json['days'] ?? json['data'] ?? json['items'] ?? []) as List;
    return MonthlySummary(
      days: list
          .map((e) => DaySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak Info
// ─────────────────────────────────────────────────────────────────────────────

/// Response from GET /api/nutrition/streak
class StreakInfo {
  final int streakCount;
  final String? lastLogDate;

  StreakInfo({required this.streakCount, this.lastLogDate});

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    return StreakInfo(
      streakCount: (json['streakCount'] ?? json['streak_count'] ?? 0) as int,
      lastLogDate: json['lastLogDate'] ?? json['last_log_date'],
    );
  }
}
