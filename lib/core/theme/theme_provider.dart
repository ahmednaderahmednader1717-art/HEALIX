import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize with SharedPreferences instance');
});

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isDark = prefs.getBool(_themeKey);
    
    // Default to dark mode since the user mentioned the app is currently in dark mode
    if (isDark == null) return ThemeMode.dark;
    
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final isDark = state == ThemeMode.dark || 
        (state == ThemeMode.system && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    setTheme(newMode);
  }

  void setTheme(ThemeMode mode) {
    final prefs = ref.read(sharedPreferencesProvider);
    state = mode;
    prefs.setBool(_themeKey, mode == ThemeMode.dark);
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
