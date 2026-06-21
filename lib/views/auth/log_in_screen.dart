import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/views/home/home_screen.dart';
import 'package:test_splash/widgets/common/healix_text_field.dart';
import 'package:test_splash/widgets/auth/social_button.dart';
import 'package:test_splash/widgets/common/healix_primary_button.dart';
import 'package:test_splash/views/auth/sign_up_screen.dart';
import 'package:test_splash/views/auth/multi_step_signup_page.dart';
import 'package:test_splash/models/user_info_model.dart';
import 'package:test_splash/src/web_wrapper.dart' as web;
import 'package:test_splash/services/auth_service.dart';

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
      baseUrl: "http://healix26.somee.com/api",
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

      print("🔍 Login Response Status: ${response.statusCode}");
      print("📦 Full Response Data: ${response.data}");

      if (response.statusCode == 200) {
        final userJson = response.data['user'];
        // ✅ الـ API بيرجع accessToken مش token
        final token =
            response.data['accessToken'] ?? response.data['token'] ?? "";
        final refreshToken = response.data['refreshToken'] ?? "";

        print("👤 User Data exists: ${userJson != null}");
        print(
          "🔑 Token from API: '${token.isEmpty ? 'EMPTY' : token.substring(0, token.length > 20 ? 20 : token.length)}...'",
        );
        print("📏 Token length: ${token.length}");
        print(
          "🔄 RefreshToken: '${refreshToken.isEmpty ? 'EMPTY' : 'EXISTS'}'",
        );

        // حفظ التوكن والمعلومات
        await AuthService.saveTokens(token, refreshToken);

        if (userJson != null) {
          UserInfo user = UserInfo.fromJson(userJson);
          
          // Fetch FULL User Profile to ensure fields like profilePictureUrl are included
          try {
            final profileResponse = await dio.get(
              '/User/profile',
              options: Options(headers: {'Authorization': 'Bearer $token'}),
            );
            if (profileResponse.statusCode == 200) {
              user = UserInfo.fromJson(profileResponse.data);
              print("✅ Successfully fetched full user profile after login.");
            }
          } catch (profileError) {
            print("⚠️ Failed to fetch full profile after login: $profileError");
          }

          await AuthService.saveUserInfo(user);

          // تحقق من الحفظ
          final savedToken = (await SharedPreferences.getInstance()).getString(
            "token",
          );
          print(
            "💾 Token saved successfully: ${savedToken?.isNotEmpty ?? false}",
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
            (route) => false,
          );
        } else {
          _showCupertinoDialog("User data not found in response");
        }
      } else {
        _showCupertinoDialog("Login failed. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Login Error: $e");
      _showCupertinoDialog("Wrong username or password");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    setState(() => _loading = true);
    try {
      final payload = {
        "provider": "Google",
        "externalId": googleUser.id,
        "email": googleUser.email,
        "fullName": googleUser.displayName ?? "Unknown",
        "profilePictureUrl": googleUser.photoUrl ?? "",
      };

      final response = await dio.post('/Auth/external-login', data: payload);

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
          // New account — send to multi-step onboarding with pre-filled fields
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(
              builder: (_) => MultiStepSignUpPage(
                isSocialSignup: true,
                prefillName: googleUser.displayName,
                prefillEmail: googleUser.email,
                prefillProfileUrl: googleUser.photoUrl,
              ),
            ),
            (route) => false,
          );
        } else {
          // Existing account — upload Google photo if needed, then go home
          if (userObj.profilePictureUrl != null &&
              userObj.profilePictureUrl!.startsWith(
                'https://lh3.googleusercontent.com',
              )) {
            try {
              final file = await UserInfo.downloadProfileImage(
                userObj.profilePictureUrl!,
              );
              if (file != null && file.existsSync()) {
                final newUrl = await userObj.uploadProfilePicture(
                  file,
                  token: token,
                );
                if (newUrl != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('profilePictureUrl', newUrl);
                  await AuthService.saveUserInfo(userObj);
                }
              }
            } catch (_) {}
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(user: userObj)),
            (route) => false,
          );
        }
      } else {
        _showCupertinoDialog(
          "Google Sign-In failed. Status: ${response.statusCode}\nResponse: ${response.data}",
        );
      }
    } catch (e) {
      _showCupertinoDialog("Google Sign-In failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
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
        final GoogleSignIn googleSignIn = GoogleSignIn(
          // إضافة serverClientId للـ iOS
          serverClientId: clientId,
          scopes: ['email', 'profile'],
        );
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

  Future<void> _signInWithApple() async {
    setState(() => _loading = true);
    try {
      final result = await AuthService.signInWithApple();

      if (!mounted) return;

      if (result.isNewUser) {
        // New account — send to multi-step onboarding with pre-filled fields
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (_) => MultiStepSignUpPage(
              appleIdentityToken: result.identityToken,
              prefillName: result.appleFullName,
              prefillEmail: result.appleEmail,
            ),
          ),
          (route) => false,
        );
      } else {
        // Existing account — go straight home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(user: result.user)),
          (route) => false,
        );
      }
    } catch (e) {
      if (e.toString().contains('AuthorizationErrorCode.canceled') ||
          e.toString().contains('canceled')) {
        // User dismissed the sheet — silently ignore
        return;
      }
      _showCupertinoDialog('Apple Sign In failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            title: RichText(
              text: TextSpan(
                style: GoogleFonts.inriaSans(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: 1.2,
                ),
                children: [
                  const TextSpan(text: "HEALI"),
                  TextSpan(
                    text: "X",
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
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
                  SizedBox(height: 20 * h),
                  Text(
                    "Log In",
                    style: GoogleFonts.inriaSans(
                      color: colorScheme.onSurface,
                      fontSize: 40 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(30 * h),
                  Text(
                    "Enter Your Username",
                    style: GoogleFonts.inriaSans(
                      fontSize: 17 * scale,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Gap(10 * h),
                  HealixTextField(
                    controller: _userNameController,
                    hint: "Username",
                    errorText: _usernameError,
                  ),
                  Gap(15 * h),
                  Text(
                    "Enter Your Password",
                    style: GoogleFonts.inriaSans(
                      fontSize: 17 * scale,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Gap(10 * h),
                  HealixTextField(
                    controller: _passwordController,
                    hint: "Password",
                    isPassword: true,
                    errorText: _passwordError,
                  ),

                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.inriaSans(
                          fontSize: 17 * scale,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  Gap(20 * h),
                  HealixPrimaryButton(
                    text: "Log In",
                    isLoading: _loading,
                    onPressed: login,
                    height: 60 * h,
                    fontSize: 20 * scale,
                    borderRadius: 80 * scale,
                  ),
                  Gap(25 * h),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: theme.brightness == Brightness.dark ? Colors.white24 : colorScheme.outlineVariant, thickness: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10 * w),
                        child: Text(
                          "Or continue with",
                          style: GoogleFonts.inriaSans(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14 * scale,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: theme.brightness == Brightness.dark ? Colors.white24 : colorScheme.outlineVariant, thickness: 1),
                      ),
                    ],
                  ),
                  Gap(25 * h),
                  SocialElevatedButton(
                    text: "Sign in with Google",
                    imagePath: "assets/icons/google.png",
                    size: scale,
                    backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF16313B).withValues(alpha: 0.69) : Colors.white,
                    onPressed: _signInWithGoogle,
                  ),
                  Gap(15 * h),
                  if (!kIsWeb && Platform.isIOS)
                  SocialElevatedButton(
                    text: "Sign in with Apple",
                    imagePath: "assets/icons/apple.png",
                    size: scale,
                    backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF16313B).withValues(alpha: 0.69) : Colors.black,
                    onPressed: _signInWithApple,
                  ),
                  Gap(30 * h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: GoogleFonts.inriaSans(
                          fontSize: 16 * scale,
                          color: colorScheme.onSurfaceVariant,
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
                            color: colorScheme.primary,
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
