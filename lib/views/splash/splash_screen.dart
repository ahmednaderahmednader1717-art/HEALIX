import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test_splash/services/auth_service.dart';
import 'package:test_splash/views/home/home_screen.dart';
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

    if (!mounted) return;

    if (userInfo != null) {
      // Fire and forget: refresh token silently in the background
      // This prevents the splash screen from hanging if the backend is slow
      AuthService().refreshToken();

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "HEALI",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              HealixLogo(
                size: 55,
                color: colorScheme.primary,
                duration: const Duration(seconds: 3),
                strokeWidth: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// تم نقل الرسام إلى lib/widgets/healix_logo.dart
