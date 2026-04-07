import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test_splash/services/auth_service.dart';
import 'package:test_splash/views/home/home_screen.dart';
import 'package:test_splash/core/app_colors.dart';
import 'package:test_splash/widgets/common/healix_logo.dart';
import 'package:test_splash/views/splash/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Wait for the animation to finish (at least partially)
    await Future.delayed(const Duration(milliseconds: 3000));

    final userInfo = await AuthService.getUserInfo();
    bool loggedIn = false;

    if (userInfo != null) {
      // Attempt to refresh token to see if session is still valid
      loggedIn = await AuthService().refreshToken();
    }

    if (!mounted) return;

    if (loggedIn && userInfo != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: userInfo)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "HEALI",
              style: TextStyle(
                color: Colors.white,
                fontSize: 55,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            HealixLogo(
              size: 55,
              color: AppColors.primarayColor,
              duration: const Duration(seconds: 3),
              strokeWidth: 6,
            ),
          ],
        ),
      ),
    );
  }
}

// تم نقل الرسام إلى lib/widgets/healix_logo.dart
