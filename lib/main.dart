import 'package:flutter/material.dart';
import 'package:test_splash/views/splash/splash_screen.dart';
import 'package:test_splash/views/auth/log_in_screen.dart';
import 'package:test_splash/views/splash/welcome_screen.dart';

void main() => runApp(const HealixApp());

class HealixApp extends StatelessWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

/// SplashScreen مستقلة للوجو
