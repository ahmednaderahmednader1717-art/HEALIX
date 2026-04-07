import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_splash/services/notification_service.dart';
import 'package:test_splash/services/live_activity_service.dart';
import 'package:test_splash/views/splash/splash_screen.dart';

void main() async {
  // تهيئة Flutter bindings قبل تعيين إعدادات النظام
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.init();
  await LiveActivityService.init();

  // تعيين لون الـ status bar لأبيض على مستوى التطبيق بالكامل
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark, // For iOS
      statusBarIconBrightness: Brightness.light, // For Android
      statusBarColor: Colors.transparent, // For Android
    ),
  );

  runApp(const HealixApp());
}

class HealixApp extends StatelessWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark, // For iOS
        statusBarIconBrightness: Brightness.light, // For Android
        statusBarColor: Colors.transparent, // For Android
      ),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale('en'),
        supportedLocales: [Locale('en'), Locale('ar')],
        home: SplashScreen(),
      ),
    );
  }
}
