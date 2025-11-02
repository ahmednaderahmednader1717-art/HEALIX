import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/views/home/home_screen.dart';
import 'package:test_splash/widgets/healix_text_field.dart';
import 'package:test_splash/widgets/social_button.dart';
import 'package:test_splash/widgets/healix_primary_button.dart';
import 'package:test_splash/views/auth/sign_up_screen.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/src/web_wrapper.dart' as web;

// ===== LogInScreen =====
class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  String? _usernameError;
  String? _passwordError;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://healix.somee.com/api",
      headers: {"Content-Type": "application/json"},
    ),
  );

  final String? clientId =
      '664346993317-p759gclcv2jt2avu18tg0efkdkv28i21.apps.googleusercontent.com';

  bool _validateFields() {
    bool valid = true;
    setState(() {
      _usernameError = null;
      _passwordError = null;
    });

    if (_userNameController.text.trim().isEmpty) {
      setState(() => _usernameError = "Username is required");
      valid = false;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() => _passwordError = "Password is required");
      valid = false;
    }

    return valid;
  }

  Future<void> login() async {
    if (!_validateFields()) return;

    setState(() => _loading = true);
    try {
      final response = await dio.post(
        "/Auth/signin",
        data: {
          "username": _userNameController.text.trim(),
          "password": _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final userJson = response.data['user'];
        if (userJson != null) {
          UserInfo user = UserInfo.fromJson(userJson);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
          );
        } else {
          _showCupertinoDialog("User data not found in response");
        }
      } else {
        _showCupertinoDialog("Login failed. Status: ${response.statusCode}");
      }
    } catch (e) {
      _showCupertinoDialog("Wrong username or password");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn(GoogleSignInAccount user) async {
    setState(() => _loading = true);
    try {
      final payload = {
        "provider": "Google",
        "externalId": user.id,
        "email": user.email,
        "fullName": user.displayName ?? "Unknown",
        "profilePictureUrl": user.photoUrl ?? "",
      };

      final response = await dio.post('/Auth/external-login', data: payload);

      if (response.statusCode == 200 && response.data['user'] != null) {
        final userJson = response.data['user'];
        final token = response.data['token'] ?? "";
        final refreshToken = response.data['refreshToken'] ?? "";

        await _saveTokens(token, refreshToken);

        // حمّل المستخدم من الرد
        UserInfo userObj = UserInfo.fromJson(userJson);

        // إذا كانت صورة Google متاحة وليست محلية، قم بتحميلها ورفعها للسيرفر
        if (userObj.profilePictureUrl != null &&
            userObj.profilePictureUrl!.startsWith(
              'https://lh3.googleusercontent.com',
            )) {
          final file = await UserInfo.downloadProfileImage(
            userObj.profilePictureUrl!,
          );

          if (file != null && file.existsSync()) {
            // ارفعها للسيرفر الخاص بك وسيتم تعيين الرابط الجديد في كائن userObj
            final newUrl = await userObj.uploadProfilePicture(
              file,
              token: token,
            );

            // خزنه محلي إذا أردت استخدامه لاحقاً
            final prefs = await SharedPreferences.getInstance();
            if (newUrl != null) {
              await prefs.setString('profilePictureUrl', newUrl);
            }
          }
        }

        // انتقل للواجهة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: userObj)),
        );
      } else {
        _showCupertinoDialog(
          "Google Sign-In failed. Status: ${response.statusCode}\nResponse: ${response.data}",
        );
      }
    } catch (e) {
      _showCupertinoDialog("Google Sign-In failed: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    print("Google Sign-In button pressed");
    setState(() => _loading = true);

    try {
      GoogleSignInAccount? googleUser;
      print("Platform check: kIsWeb = $kIsWeb");

      if (kIsWeb) {
        // For web platform, use the web-specific implementation
        print("Using web implementation");
        googleUser = await web.signInWithGoogle();
        print("Web sign-in result: $googleUser");
      } else {
        // For mobile platforms, create a GoogleSignIn instance and use signIn
        print("Using mobile implementation");
        final GoogleSignIn googleSignIn = GoogleSignIn();
        print("GoogleSignIn instance created");

        try {
          googleUser = await googleSignIn.signIn();
          print("Google Sign-In completed, user: ${googleUser?.email}");
        } catch (signInError) {
          print("Sign-in error details: $signInError");
          rethrow;
        }
      }

      if (googleUser != null) {
        print("User signed in successfully: ${googleUser.email}");
        await _handleGoogleSignIn(googleUser);
      } else {
        print("User cancelled sign-in - googleUser is null");
        _showCupertinoDialog("تم إلغاء تسجيل الدخول");
      }
    } catch (e) {
      print("Google Sign-In error: $e");
      _showCupertinoDialog("فشل تسجيل الدخول مع جوجل: $e");
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
        title: const Text("Attention"),
        content: Text(message),
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
            title: SvgPicture.asset(
              "assets/logo/HEALIX.svg",
              width: 60 * w,
              height: 40 * h,
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30 * w),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60 * h),
                  Text(
                    "Log In",
                    style: GoogleFonts.inriaSans(
                      color: Colors.white,
                      fontSize: 40 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(40 * h),
                  Text(
                    "Enter Your Username",
                    style: GoogleFonts.inriaSans(
                      fontSize: 17 * scale,
                      color: const Color.fromARGB(255, 169, 169, 169),
                    ),
                  ),
                  Gap(10 * h),
                  HealixTextField(
                    controller: _userNameController,
                    hint: "Username",
                    errorText: _usernameError,
                  ),
                  Gap(25 * h),
                  Text(
                    "Enter Your Password",
                    style: GoogleFonts.inriaSans(
                      fontSize: 17 * scale,
                      color: const Color.fromARGB(255, 169, 169, 169),
                    ),
                  ),
                  Gap(10 * h),
                  HealixTextField(
                    controller: _passwordController,
                    hint: "Password",
                    isPassword: true,
                    errorText: _passwordError,
                  ),
                  Gap(10 * h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.inriaSans(
                          fontSize: 17 * scale,
                          color: const Color.fromARGB(255, 169, 169, 169),
                        ),
                      ),
                    ),
                  ),
                  Gap(50 * h),
                  HealixPrimaryButton(
                    text: _loading ? "Logging In..." : "Log In",
                    onPressed: login,
                    height: 60 * h,
                    fontSize: 20 * scale,
                    borderRadius: 80 * scale,
                  ),
                  Gap(30 * h),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.white24, thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10 * w),
                        child: Text(
                          "Or continue with",
                          style: GoogleFonts.inriaSans(
                            color: Colors.white54,
                            fontSize: 14 * scale,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Colors.white24, thickness: 1),
                      ),
                    ],
                  ),
                  Gap(25 * h),
                  SocialElevatedButton(
                    text: "Sign in with Google",
                    imagePath: "assets/icons/google.png",
                    size: scale,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    onPressed: _signInWithGoogle,
                  ),
                  Gap(15 * h),
                  SocialElevatedButton(
                    text: "Sign in with Apple",
                    imagePath: "assets/icons/apple.png",
                    size: scale,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    onPressed: () {},
                  ),
                  Gap(40 * h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: GoogleFonts.inriaSans(
                          fontSize: 16 * scale,
                          color: Colors.white70,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.inriaSans(
                            fontSize: 16 * scale,
                            color: AppColors.primarayColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(40 * h),
                ],
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_loading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(child: CupertinoActivityIndicator(radius: 15)),
          ),
      ],
    );
  }
}
