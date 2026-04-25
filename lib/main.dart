import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_splash/services/notification_service.dart';
import 'package:test_splash/services/live_activity_service.dart';
import 'package:test_splash/views/splash/splash_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/core/theme/app_theme.dart';
import 'package:test_splash/core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.init();
  await LiveActivityService.init();
  
  final prefs = await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark, // For iOS
      statusBarIconBrightness: Brightness.light, // For Android
      statusBarColor: Colors.transparent, // For Android
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const HealixApp(),
    ),
  );
}

class HealixApp extends ConsumerWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark, // For iOS
        statusBarIconBrightness: Brightness.light, // For Android
        statusBarColor: Colors.transparent, // For Android
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const SplashScreen(),
      ),
    );
  }
}
