import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/views/auth/multi_step_signup_page.dart';
import 'package:test_splash/views/home/home_screen.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/widgets/healix_primary_button.dart';
import 'package:test_splash/widgets/social_button.dart';
import 'package:test_splash/src/web_wrapper.dart' as web;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _loading = false;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://healix.somee.com/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  final String? clientId =
      '664346993317-p759gclcv2jt2avu18tg0efkdkv28i21.apps.googleusercontent.com';

  // دالة التسجيل ومعالجة حالة 400 - تعرض الرسالة للمستخدم
  Future<void> _handleGoogleSignUp(GoogleSignInAccount user) async {
    setState(() => _loading = true);
    try {
      // إعداد الـpayload بشكل يلبي متطلبات الـAPI
      final username = user.email.split('@').first;
      final password = "GoogleSignInP@ss1"; // بطول مناسب وشروط قوية
      final fullName =
          (user.displayName != null && user.displayName!.length >= 3)
          ? user.displayName!
          : "Google User";

      final payload = {
        "username": username.length > 50
            ? username.substring(0, 50)
            : username, // بطول مناسب
        "email": user.email,
        "password": password,
        "fullName": fullName,
        "profilePictureUrl": user.photoUrl ?? "",
      };

      final response = await dio.post('/Auth/signup', data: payload);

      if (response.statusCode == 200 && response.data['user'] != null) {
        final userJson = response.data['user'];
        // ✅ الـ API بيرجع accessToken مش token
        final token =
            response.data['accessToken'] ?? response.data['token'] ?? "";
        final refreshToken = response.data['refreshToken'] ?? "";
        await _saveTokens(token, refreshToken);
        UserInfo userObj = UserInfo.fromJson(userJson);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MultiStepSignUpPage(user: userObj)),
        );
      } else {
        _showCupertinoDialog("حدث خطأ غير متوقع أثناء التسجيل.");
      }
    } on DioException catch (dioError) {
      // هنا نطبع رسالة الخطأ للتصحيح على أساسها
      print("RESPONSE ERROR DATA: ${dioError.response?.data}");
      final apiError = dioError.response?.data;
      if (dioError.response?.statusCode == 400 ||
          dioError.response?.statusCode == 409) {
        // غالباً الإيميل مستخدم من قبل - جرب تسجيل الدخول الخارجي بنفس بيانات جوجل
        final externalLoginPayload = {
          "provider": "Google",
          "externalId": user.id,
          "email": user.email,
          "fullName": user.displayName ?? "Unknown",
          "profilePictureUrl": user.photoUrl ?? "",
        };
        final loginResponse = await dio.post(
          '/Auth/external-login',
          data: externalLoginPayload,
        );
        if (loginResponse.statusCode == 200 &&
            loginResponse.data['user'] != null) {
          final userJson = loginResponse.data['user'];
          // ✅ الـ API بيرجع accessToken مش token
          final token =
              loginResponse.data['accessToken'] ??
              loginResponse.data['token'] ??
              "";
          final refreshToken = loginResponse.data['refreshToken'] ?? "";
          await _saveTokens(token, refreshToken);
          UserInfo userObj = UserInfo.fromJson(userJson);
          // يدخل مباشرة للـHome
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(user: userObj)),
          );
        } else {
          _showCupertinoDialog("فشل تسجيل الدخول بحساب جوجل.");
        }
      } else {
        // عرض الرسالة من الرد للـuser أو للمطور
        _showCupertinoDialog("خطأ في التسجيل بحساب جوجل: $apiError");
      }
    } catch (e) {
      _showCupertinoDialog("فشل التسجيل بواسطة جوجل: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _loading = true);
    try {
      GoogleSignInAccount? googleUser;
      if (kIsWeb) {
        googleUser = await web.signInWithGoogle();
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          // إضافة serverClientId للـ iOS
          serverClientId: clientId,
          scopes: ['email', 'profile'],
        );
        googleUser = await googleSignIn.signIn();
      }
      if (googleUser != null) {
        await _handleGoogleSignUp(googleUser);
      } else {
        _showCupertinoDialog("تم إلغاء تسجيل الدخول.");
      }
    } catch (e) {
      _showCupertinoDialog("فشل التسجيل بواسطة جوجل: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveTokens(String token, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("refreshToken", refreshToken);
  }

  void _showCupertinoDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          "Alert",
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ok", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const baseWidth = 430.0;
    const baseHeight = 932.0;
    final w = screenWidth / baseWidth;
    final h = screenHeight / baseHeight;
    final scale = min(w, h);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              "Sign Up",
              style: GoogleFonts.inriaSans(
                color: Colors.white,
                fontSize: 22 * scale,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(180 * h),
                  Text(
                    "Welcome! Let's customize\n HEALIX for your goals.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inriaSans(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Gap(30 * h),
                  HealixPrimaryButton(
                    text: "Continue",
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const MultiStepSignUpPage(),
                        ),
                      );
                    },
                    borderRadius: 10,
                  ),
                  Gap(20 * h),
                  Text(
                    "OR",
                    style: GoogleFonts.inriaSans(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Gap(15 * h),
                  SocialElevatedButton(
                    text: "Sign Up with Google",
                    imagePath: "assets/icons/google.png",
                    size: scale,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    onPressed: _signUpWithGoogle,
                  ),
                  Gap(15 * h),
                  SocialElevatedButton(
                    text: "Sign in with Apple",
                    imagePath: "assets/icons/apple.png",
                    size: scale,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    onPressed: () {
                      // TODO SIGN IN WITH APPLE LOGIC HERE
                    },
                  ),
                  Gap(80 * h),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inriaSans(
                        color: Colors.white,
                        fontSize: 15 * scale,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              "We will collect personal information from and about\nyou and use it for various purposes, including to\ncustomize your HEALIX experience. Read more\nabout the purposes, our practices, your choices, and\nyour rights in our  ",
                        ),
                        TextSpan(
                          text: "Privacy Policy",
                          style: GoogleFonts.inriaSans(
                            color: AppColors.primarayColor,
                            fontSize: 15 * scale,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: handle click, e.g., open privacy policy URL
                            },
                        ),
                      ],
                    ),
                  ),
                  Gap(30 * h),
                ],
              ),
            ),
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(child: CupertinoActivityIndicator(radius: 15)),
          ),
      ],
    );
  }
}
