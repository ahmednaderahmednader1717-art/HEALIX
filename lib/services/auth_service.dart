import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:test_splash/models/user_info_model.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://healix26.somee.com/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  static Future<void> saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("refreshToken", refreshToken);
  }

  static Future<void> saveUserInfo(UserInfo user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_data", jsonEncode(user.toJson()));
  }

  static Future<UserInfo?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString("user_data");
    if (userData != null) {
      try {
        return UserInfo.fromJson(jsonDecode(userData));
      } catch (e) {
        log('Error decoding user info: $e');
      }
    }
    return null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("refreshToken");
    await prefs.remove("user_data");
  }

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
