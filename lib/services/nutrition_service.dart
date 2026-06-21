import 'dart:developer';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/models/nutrition_models.dart';

class NutritionService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://healix26.somee.com/api'));

  /// Incremented every time a food is successfully logged.
  /// Widgets can listen to this to auto-refresh nutrition data.
  static final ValueNotifier<int> foodLogged = ValueNotifier(0);

  static final Set<int> _syncingLogs = {};

  // ─── Auth header helper ───────────────────────────────────────────────────

  Future<Options> _authOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  // ─── Daily Summary ────────────────────────────────────────────────────────

  /// Returns today's summary when [date] is null, otherwise the summary for
  /// the given date (format: 'yyyy-MM-dd').
  Future<DailySummary?> getDailySummary({String? date}) async {
    final effectiveDate = date ?? DateTime.now().toString().split(' ')[0];
    
    try {
      final options = await _authOptions();
      final params = <String, dynamic>{};
      if (date != null) params['date'] = date;

      DailySummary? summary;

      try {
        final response = await _dio.get(
          '/nutrition/daily-summary',
          queryParameters: params.isEmpty ? null : params,
          options: options,
        );

        if (response.statusCode == 200) {
          log('DailySummary: ${response.data}');
          summary = DailySummary.fromJson(response.data as Map<String, dynamic>);
        }
      } catch (dioError) {
        log('Error fetching from backend: $dioError');
      }

      summary ??= DailySummary.empty(effectiveDate);

      // ── Merge Local Logs ──
      final prefs = await SharedPreferences.getInstance();
      final key = 'local_logs_$effectiveDate';
      final localRaw = prefs.getStringList(key) ?? [];

      if (localRaw.isNotEmpty) {
        final localLogs = localRaw.map((e) => NutritionLog.fromJson(jsonDecode(e))).toList();
        final allLogs = List<NutritionLog>.from(summary.logs)..addAll(localLogs);

        final totalLocalCals = localLogs.fold(0.0, (s, l) => s + l.calories);
        final totalLocalProtein = localLogs.fold(0.0, (s, l) => s + l.protein);
        final totalLocalCarbs = localLogs.fold(0.0, (s, l) => s + l.carbs);
        final totalLocalFats = localLogs.fold(0.0, (s, l) => s + l.fats);

        summary = DailySummary(
          date: summary.date.isNotEmpty ? summary.date : effectiveDate,
          totalCalories: summary.totalCalories + totalLocalCals,
          calorieGoal: summary.calorieGoal,
          remainingCalories: summary.remainingCalories - totalLocalCals,
          totalProtein: summary.totalProtein + totalLocalProtein,
          proteinGoal: summary.proteinGoal,
          totalCarbs: summary.totalCarbs + totalLocalCarbs,
          carbsGoal: summary.carbsGoal,
          totalFats: summary.totalFats + totalLocalFats,
          fatsGoal: summary.fatsGoal,
          logs: allLogs,
        );
      }

      return summary;

    } catch (e) {
      log('Error getting combined daily summary: $e');
    }
    return null;
  }

  // ─── Local Log (AI Cache) ─────────────────────────────────────────────────

  Future<void> saveLocalLog(NutritionLog logItem, String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'local_logs_$date';
      final existing = prefs.getStringList(key) ?? [];
      existing.add(jsonEncode(logItem.toJson()));
      await prefs.setStringList(key, existing);
      NutritionService.foodLogged.value++;
    } catch (e) {
      log('Error saving local log: $e');
    }
  }

  Future<void> removeLocalLog(int logId, String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'local_logs_$date';
      final existing = prefs.getStringList(key) ?? [];
      
      final updatedList = existing.where((raw) {
        try {
           final item = NutritionLog.fromJson(jsonDecode(raw));
           return item.id != logId;
        } catch (_) { return true; }
      }).toList();
      
      await prefs.setStringList(key, updatedList);
      NutritionService.foodLogged.value++;
    } catch (e) {
      log('Error removing local log: $e');
    }
  }

  Future<void> syncLocalLogToServer(NutritionLog logItem, String date) async {
    if (_syncingLogs.contains(logItem.id)) return;
    _syncingLogs.add(logItem.id);
    try {
      final serverLog = await logFood(
        foodId: logItem.foodId,
        quantity: logItem.quantity,
        date: date,
      );
      if (serverLog != null) {
        await removeLocalLog(logItem.id, date);
      }
    } catch (e) {
      log('Background sync failed: $e');
    } finally {
      _syncingLogs.remove(logItem.id);
    }
  }

  Future<void> syncPendingLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      
      // Look back 7 days for pending local logs
      for (int i = 0; i < 7; i++) {
        final d = today.subtract(Duration(days: i));
        final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final key = 'local_logs_$dateStr';
        
        final localRaw = prefs.getStringList(key) ?? [];
        for (final raw in localRaw) {
          try {
            final logItem = NutritionLog.fromJson(jsonDecode(raw));
            if (logItem.foodId > 0) {
              // Standard DB food — sync via existing flow
              await syncLocalLogToServer(logItem, dateStr);
            } else {
              // AI custom food (negative foodId) — create food on server first, then log
              await _syncAIMealToServer(logItem, dateStr);
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      log('Error syncing pending logs: $e');
    }
  }

  /// Syncs an AI-scanned meal to the server by creating the food entry first,
  /// then logging it. On success, removes from local storage.
  Future<void> _syncAIMealToServer(NutritionLog logItem, String date) async {
    if (_syncingLogs.contains(logItem.id)) return;
    _syncingLogs.add(logItem.id);
    try {
      final serverLog = await logCustomMeal(
        foodName: logItem.foodName,
        description: logItem.description,
        proteinPer100: logItem.originalProteinPer100 ?? logItem.protein,
        carbsPer100: logItem.originalCarbsPer100 ?? logItem.carbs,
        fatsPer100: logItem.originalFatsPer100 ?? logItem.fats,
        quantity: logItem.quantity,
        unitName: logItem.unitName ?? 'g',
        category: logItem.category ?? 'Snacks',
        weightPerUnit: logItem.weightPerUnit,
        date: date,
      );
      if (serverLog != null) {
        await removeLocalLog(logItem.id, date);
      }
    } catch (e) {
      log('AI meal sync failed: $e');
    } finally {
      _syncingLogs.remove(logItem.id);
    }
  }

  // ─── Create Custom Food (for AI meals) ──────────────────────────────────────

  /// Creates a custom food on the server via POST /api/admin/foods.
  /// Returns the server-assigned food ID on success, or null on failure.
  Future<int?> createCustomFood({
    required String name,
    String? description,
    required double protein,
    required double carbs,
    required double fats,
    String category = 'Snacks',
    String unitName = 'g',
    String measurementType = 'Weight',
    double? weightPerUnit,
  }) async {
    try {
      final options = await _authOptions();
      options.contentType = 'multipart/form-data';

      final formData = FormData.fromMap({
        'Name': name,
        'Description': description ?? 'AI scanned meal',
        'Categories': [category],
        'DietType': 'Standard',
        'MeasurementType': measurementType,
        'UnitName': unitName,
        'Protein': protein,
        'Carbs': carbs,
        'Fats': fats,
        if (weightPerUnit != null) 'WeightPerUnit': weightPerUnit,
      });

      final response = await _dio.post(
        '/admin/foods',
        data: formData,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('CreateCustomFood response: ${response.data}');
        final data = response.data;
        // Try to extract the food ID from the response
        if (data is Map<String, dynamic>) {
          return data['id'] ?? data['Id'] ?? data['foodId'];
        }
      }
    } catch (e) {
      log('Error creating custom food: $e');
    }
    return null;
  }

  // ─── Log Custom Meal (two-step: create food + log it) ───────────────────────

  /// Creates a custom food on the server, then logs it.
  /// Returns the server-created NutritionLog on success, or null on failure.
  Future<NutritionLog?> logCustomMeal({
    required String foodName,
    String? description,
    required double proteinPer100,
    required double carbsPer100,
    required double fatsPer100,
    required double quantity,
    String unitName = 'g',
    String category = 'Snacks',
    double? weightPerUnit,
    String? date,
  }) async {
    // Step 1: Create the food on the server
    String measurementType = 'Weight';
    if (unitName == 'ml') {
      measurementType = 'Liquid';
    } else if (unitName == 'piece') {
      measurementType = 'Unit';
    }

    final foodId = await createCustomFood(
      name: foodName,
      description: description,
      protein: proteinPer100,
      carbs: carbsPer100,
      fats: fatsPer100,
      category: category,
      unitName: unitName,
      measurementType: measurementType,
      weightPerUnit: weightPerUnit,
    );

    if (foodId == null) {
      log('Failed to create custom food on server');
      return null;
    }

    // Step 2: Log it with the server-assigned foodId
    return await logFood(
      foodId: foodId,
      quantity: quantity,
      date: date,
    );
  }

  /// Returns up to the past 14 days of local AI scan logs that have a valid image
  Future<List<NutritionLog>> getRecentLocalLogs() async {
    final prefs = await SharedPreferences.getInstance();
    List<NutritionLog> allLocalLogs = [];
    final today = DateTime.now();

    for (int i = 0; i < 14; i++) {
      final d = today.subtract(Duration(days: i));
      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final key = 'local_logs_$dateStr';
      final localRaw = prefs.getStringList(key) ?? [];
      for (final raw in localRaw) {
        try {
          final logItem = NutritionLog.fromJson(jsonDecode(raw));
          if (logItem.imageUrl != null && logItem.imageUrl!.isNotEmpty) {
            allLocalLogs.add(logItem);
          }
        } catch (_) {}
      }
    }
    return allLocalLogs.reversed.toList();
  }

  // ─── Monthly Summary ──────────────────────────────────────────────────────

  /// Returns a 28-day (or [days]-day) summary starting from [startDate]
  /// (format: 'yyyy-MM-dd'). If [startDate] is null the server uses today
  /// minus [days] by default.
  Future<MonthlySummary?> getMonthlySummary({
    String? startDate,
    int days = 28,
  }) async {
    try {
      final options = await _authOptions();
      final params = <String, dynamic>{'days': days};
      if (startDate != null) params['startDate'] = startDate;

      final response = await _dio.get(
        '/nutrition/monthly-summary',
        queryParameters: params,
        options: options,
      );

      if (response.statusCode == 200) {
        log('MonthlySummary: ${response.data}');
        return MonthlySummary.fromJson(response.data);
      }
    } catch (e) {
      log('Error fetching monthly summary: $e');
    }
    return null;
  }

  // ─── Log Food ─────────────────────────────────────────────────────────────

  /// Logs a food entry. [date] is optional (format: 'yyyy-MM-dd'); the server
  /// defaults to today. [quantity] is in grams, ml, or units depending on
  /// the food's measurementType.
  Future<NutritionLog?> logFood({
    required int foodId,
    required double quantity,
    String? date,
  }) async {
    try {
      final options = await _authOptions();
      final body = <String, dynamic>{
        'foodId': foodId,
        'quantity': quantity,
        if (date != null) 'date': date,
      };

      final response = await _dio.post(
        '/nutrition/log',
        data: body,
        options: options,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('LogFood response: ${response.data}');

        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        final Map<String, dynamic> logMap =
            (responseData['data'] is Map<String, dynamic>)
            ? responseData['data']
            : responseData;

        final logged = NutritionLog.fromJson(logMap);

        // Notify listeners (e.g. HomeTab chart) that a new meal was logged
        NutritionService.foodLogged.value++;
        return logged;
      }
    } catch (e) {
      log('Error logging food: $e');
    }
    return null;
  }

  // ─── Delete Log ───────────────────────────────────────────────────────────

  /// Deletes a log entry by its [logId]. Returns true on success.
  Future<bool> deleteLog(int logId) async {
    try {
      final options = await _authOptions();
      final response = await _dio.delete(
        '/nutrition/log/$logId',
        options: options,
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      log('Error deleting log $logId: $e');
      return false;
    }
  }

  // ─── Update Log Quantity ──────────────────────────────────────────────────

  /// Updates the quantity of an existing log entry. Returns the updated log
  /// on success, or null on failure.
  Future<NutritionLog?> updateLog({
    required int logId,
    required double quantity,
  }) async {
    try {
      final options = await _authOptions();
      final response = await _dio.put(
        '/nutrition/log/$logId',
        data: {'quantity': quantity},
        options: options,
      );

      if (response.statusCode == 200) {
        log('UpdateLog response: ${response.data}');

        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>;
        final Map<String, dynamic> logMap =
            (responseData['data'] is Map<String, dynamic>)
            ? responseData['data']
            : responseData;

        return NutritionLog.fromJson(logMap);
      }
    } catch (e) {
      log('Error updating log $logId: $e');
    }
    return null;
  }

  // ─── Streak ───────────────────────────────────────────────────────────────

  /// Returns the current nutrition streak count and last log date.
  Future<StreakInfo?> getStreak() async {
    try {
      final options = await _authOptions();
      final response = await _dio.get('/nutrition/streak', options: options);

      if (response.statusCode == 200) {
        log('StreakInfo: ${response.data}');
        final serverStreak = StreakInfo.fromJson(response.data as Map<String, dynamic>);
        return await _computeEffectiveStreak(serverStreak);
      }
    } catch (e) {
      log('Error fetching streak: $e');
    }
    return null;
  }

  Future<StreakInfo> _computeEffectiveStreak(StreakInfo server) async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    final prefs = await SharedPreferences.getInstance();
    final todayLocal = prefs.getStringList('local_logs_$todayStr') ?? [];

    if (todayLocal.isNotEmpty) {
      if (server.lastLogDate == yesterdayStr) {
        return StreakInfo(streakCount: server.streakCount + 1, lastLogDate: todayStr);
      } else if (server.lastLogDate != todayStr) {
        // If they didn't log yesterday on server, but logged locally today, reset to 1
        return StreakInfo(streakCount: 1, lastLogDate: todayStr);
      }
    }

    return server;
  }
}
