import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/models/food_model.dart';
import 'dart:developer';

class FoodService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://healix26.somee.com/api"));

  Future<List<Food>> getFoods() async {
    return _fetchFromUrl('/foods');
  }

  Future<List<Food>> searchFoods(String name) async {
    return _fetchFromUrl('/foods/search', queryParameters: {'name': name});
  }

  Future<List<Food>> getFoodsByDiet(String dietType) async {
    return _fetchFromUrl('/foods/by-diet/$dietType');
  }

  Future<List<Food>> getFoodsByCategory(String category) async {
    return _fetchFromUrl('/foods/by-category/$category');
  }

  Future<List<Food>> _fetchFromUrl(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        log('Raw food data from $url: ${response.data}');
        List<dynamic> data = response.data;
        return data.map((json) => Food.fromJson(json)).toList();
      } else {
        log(
          'Failed to load foods from $url, status code: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      log('Error fetching foods from $url: $e');
      return [];
    }
  }
}
