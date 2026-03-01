import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://healix26.somee.com/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString("refreshToken");

      if (refreshToken == null || refreshToken.isEmpty) {
        log('No refresh token found');
        return false;
      }

      final response = await _dio.post(
        '/Auth/refresh',
        data: {"refreshToken": refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken =
            response.data['accessToken'] ?? response.data['token'] ?? "";
        final newRefreshToken = response.data['refreshToken'] ?? "";

        if (newToken.isNotEmpty) {
          await prefs.setString("token", newToken);
          if (newRefreshToken.isNotEmpty) {
            await prefs.setString("refreshToken", newRefreshToken);
          }
          log('Token refreshed successfully');
          return true;
        }
      }
      log('Failed to refresh token: ${response.statusCode}');
      return false;
    } catch (e) {
      log('Error refreshing token: $e');
      return false;
    }
  }
}
