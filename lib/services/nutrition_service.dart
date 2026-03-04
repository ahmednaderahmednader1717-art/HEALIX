import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/models/nutrition_models.dart';

class NutritionService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://healix26.somee.com/api'));

  /// Incremented every time a food is successfully logged.
  /// Widgets can listen to this to auto-refresh nutrition data.
  static final ValueNotifier<int> foodLogged = ValueNotifier(0);

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
    try {
      final options = await _authOptions();
      final params = <String, dynamic>{};
      if (date != null) params['date'] = date;

      final response = await _dio.get(
        '/nutrition/daily-summary',
        queryParameters: params.isEmpty ? null : params,
        options: options,
      );

      if (response.statusCode == 200) {
        log('DailySummary: ${response.data}');
        return DailySummary.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      log('Error fetching daily summary: $e');
    }
    return null;
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
}
