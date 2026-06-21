import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:test_splash/services/auth_service.dart';
import 'package:test_splash/views/auth/multi_step_signup_page.dart';
import 'package:test_splash/views/home/home_screen.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/widgets/common/healix_primary_button.dart';
import 'package:test_splash/widgets/auth/social_button.dart';
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
      baseUrl: "http://healix26.somee.com/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  final String? clientId =
      '664346993317-p759gclcv2jt2avu18tg0efkdkv28i21.apps.googleusercontent.com';

  Future<void> _handleGoogleSignUp(GoogleSignInAccount googleUser) async {
    setState(() => _loading = true);
    try {
      // Use external-login for both new and existing Google users.
      // The server returns isNewUser=true when it creates a brand-new account.
      final payload = {
        "provider": "Google",
        "externalId": googleUser.id,
        "email": googleUser.email,
        "fullName": googleUser.displayName ?? "Unknown",
        "profilePictureUrl": googleUser.photoUrl ?? "",
      };

      final response = await dio.post(
        '/Auth/external-login',
        data: payload,
        options: Options(
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      if (response.statusCode == 200 && response.data['user'] != null) {
        final userJson = response.data['user'];
        final token =
            response.data['accessToken'] ?? response.data['token'] ?? "";
        final refreshToken = response.data['refreshToken'] ?? "";
        
        UserInfo userObj = UserInfo.fromJson(userJson);
        
        bool isNewUser = response.data['isNewUser'] == true;
        // Fallback: If backend doesn't flag isNewUser, check if essential profile info is missing
        if (!isNewUser && (userObj.userHeight == null || userObj.userHeight == 0 || userObj.userWeight == null || userObj.userWeight == 0)) {
          isNewUser = true;
        }

        await AuthService.saveTokens(token, refreshToken);
        await AuthService.saveUserInfo(userObj);

        if (!mounted) return;

        if (isNewUser) {
          // New account — go to multi-step onboarding with pre-filled fields
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (_) => MultiStepSignUpPage(
                isSocialSignup: true,
                prefillName: googleUser.displayName,
                prefillEmail: googleUser.email,
                prefillProfileUrl: googleUser.photoUrl,
              ),
            ),
          );
        } else {
          // Already has an account — go home
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(user: userObj)),
            (route) => false,
          );
        }
      } else {
        _showCupertinoDialog(
          "Google Sign-Up failed. Status: ${response.statusCode}\n${response.data}",
        );
      }
    } catch (e) {
      _showCupertinoDialog("Google Sign-Up failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
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

  Future<void> _signUpWithApple() async {
    setState(() => _loading = true);
    try {
      final result = await AuthService.signInWithApple();

      if (!mounted) return;

      if (result.isNewUser) {
        // New user — go to onboarding with pre-filled name & email
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (_) => MultiStepSignUpPage(
              appleIdentityToken: result.identityToken,
              prefillName: result.appleFullName,
              prefillEmail: result.appleEmail,
            ),
          ),
        );
      } else {
        // Already has an account — go home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: result.user)),
          (route) => false,
        );
      }
    } catch (e) {
      if (e.toString().contains('AuthorizationErrorCode.canceled') ||
          e.toString().contains('canceled')) {
        return;
      }
      _showCupertinoDialog('Apple Sign Up failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              "Sign Up",
              style: GoogleFonts.inriaSans(
                color: colorScheme.onSurface,
                fontSize: 22 * scale,
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
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
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inriaSans(
                        color: colorScheme.onSurface,
                        fontSize: 24 * scale,
                      ),
                      children: [
                        const TextSpan(text: "Welcome! Let's customize\n HEALI"),
                        TextSpan(
                          text: "X",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: " for your goals."),
                      ],
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
                      color: colorScheme.onSurface,
                      fontSize: 24,
                    ),
                  ),
                  Gap(15 * h),
                  SocialElevatedButton(
                    text: "Sign Up with Google",
                    imagePath: "assets/icons/google.png",
                    size: scale,
                    backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF16313B).withValues(alpha: 0.69) : Colors.white,
                    onPressed: _signUpWithGoogle,
                  ),
                  Gap(15 * h),
                  if (!kIsWeb && Platform.isIOS)
                  SocialElevatedButton(
                    text: "Sign up with Apple",
                    imagePath: "assets/icons/apple.png",
                    size: scale,
                    backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF16313B).withValues(alpha: 0.69) : Colors.black,
                    onPressed: _signUpWithApple,
                  ),
                  Gap(80 * h),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inriaSans(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 15 * scale,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              "We will collect personal information from and about\nyou and use it for various purposes, including to\ncustomize your HEALI",
                        ),
                        TextSpan(
                          text: "X",
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: " experience. Read more\nabout the purposes, our practices, your choices, and\nyour rights in our  ",
                        ),
                        TextSpan(
                          text: "Privacy Policy",
                          style: GoogleFonts.inriaSans(
                            color: colorScheme.primary,
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
            color: colorScheme.surface.withValues(alpha: 0.7),
            child: Center(
              child: CupertinoActivityIndicator(
                color: colorScheme.primary,
                radius: 15,
              ),
            ),
          ),
      ],
    );
  }
}
