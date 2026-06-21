import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:test_splash/models/user_info_model.dart';

// ─── Result type returned from signInWithApple ───────────────────────────────
class AppleAuthResult {
  final String accessToken;
  final String refreshToken;
  final UserInfo user;
  /// true if the backend created a brand-new account (first Apple sign-in)
  final bool isNewUser;
  // Raw Apple credential fields — forwarded to MultiStepSignUpPage for pre-fill
  final String? appleEmail;
  final String? appleFullName;
  final String identityToken;

  const AppleAuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.isNewUser,
    required this.identityToken,
    this.appleEmail,
    this.appleFullName,
  });
}

class AuthService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://healix26.somee.com/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  // ─── Token / session helpers ────────────────────────────────────────────────

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

  // ─── Apple Sign In ──────────────────────────────────────────────────────────

  /// Returns an [AppleAuthResult] on success.
  /// Throws an exception (string message) on failure so the caller can show it.
  static Future<AppleAuthResult> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw 'Apple Sign In is only supported on iOS/macOS.';
    }

    // 1. Get Apple ID credential from the OS
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null || identityToken.isEmpty) {
      throw 'Apple Sign In failed: no identity token returned.';
    }

    // Build a display name from the credential (only present on first sign-in)
    final givenName = credential.givenName ?? '';
    final familyName = credential.familyName ?? '';
    final fullName = '${givenName.trim()} ${familyName.trim()}'.trim();
    final email = credential.email;

    log('🍎 Apple credential received. email=$email, fullName=$fullName');

    // 2. Call backend
    final response = await _dio.post(
      '/Auth/apple-login',
      data: {
        'identityToken': identityToken,
        if (email != null && email.isNotEmpty) 'email': email,
        if (fullName.isNotEmpty) 'fullName': fullName,
      },
      options: Options(
        validateStatus: (status) => status != null && status < 600,
      ),
    );

    log('🍎 Apple-login response: ${response.statusCode} — ${response.data}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final msg = (response.data is Map)
          ? (response.data['message'] ?? response.data['error'] ?? 'Apple sign-in failed')
          : 'Apple sign-in failed (${response.statusCode})';
      throw msg.toString();
    }

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] ?? data['token'] ?? '';
    final refreshToken = data['refreshToken'] ?? '';
    final isNewUser = data['isNewUser'] == true;

    if (accessToken.isEmpty) {
      throw 'Apple sign-in failed: no access token in response.';
    }

    await saveTokens(accessToken, refreshToken);

    // Build UserInfo — the user object may be nested under 'user' key
    final userJson = data['user'] ?? data;
    final user = UserInfo.fromJson(userJson is Map<String, dynamic> ? userJson : {});
    await saveUserInfo(user);

    return AppleAuthResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
      isNewUser: isNewUser,
      identityToken: identityToken,
      appleEmail: email,
      appleFullName: fullName.isEmpty ? null : fullName,
    );
  }

  // ─── Token refresh ──────────────────────────────────────────────────────────

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
