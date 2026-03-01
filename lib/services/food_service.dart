import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/models/food_model.dart';
import 'dart:developer';

class FoodService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://healix26.somee.com/api"));

  Future<List<Food>> getFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        '/foods',
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        log('Raw food data: ${response.data}');
        List<dynamic> data = response.data;
        return data.map((json) => Food.fromJson(json)).toList();
      } else {
        log('Failed to load foods, status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching foods: $e');
      return [];
    }
  }
}
