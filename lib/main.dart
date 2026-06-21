import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:test_splash/l10n/app_localizations.dart';
import 'package:test_splash/services/notification_service.dart';
import 'package:test_splash/services/live_activity_service.dart';
import 'package:test_splash/views/splash/splash_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_splash/core/theme/app_theme.dart';
import 'package:test_splash/core/theme/theme_provider.dart';
import 'package:test_splash/core/theme/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.init();
  await LiveActivityService.init();
  
  final prefs = await SharedPreferences.getInstance();



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
    final locale = ref.watch(localeNotifierProvider);

    final brightness = themeMode == ThemeMode.system
        ? PlatformDispatcher.instance.platformBrightness
        : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
    final isDark = brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Android
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) return const Locale('en');
          // Check if the current locale is supported
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          // If the locale is not supported, fallback to English
          return const Locale('en');
        },
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const SplashScreen(),
      ),
    );
  }
}
