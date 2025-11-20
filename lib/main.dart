import 'package:flutter/material.dart';
import 'package:test_splash/views/splash/splash_screen.dart';

//test
void main() => runApp(const HealixApp());

class HealixApp extends StatelessWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: SplashScreen(),
    );
  }
}
