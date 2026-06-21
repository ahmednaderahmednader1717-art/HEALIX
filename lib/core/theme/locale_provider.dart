import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_splash/core/theme/theme_provider.dart';

/// Maps language name → BCP-47 locale tag.
const Map<String, String> kLanguageToLocale = {
  'English': 'en',
  'العربية': 'ar',
  '中国人': 'zh',
  'हिन्दी': 'hi',
  'Español': 'es',
  'Français': 'fr',
  'Deutsch': 'de',
  'Русский': 'ru',
  'Português': 'pt',
  'Italiano': 'it',
  'Română': 'ro',
  'Azərbaycanca': 'az',
  'Nederlands': 'nl',
  '日本語': 'ja',
  '한국어': 'ko',
};

/// Reverse map: locale tag → language name (for initialising the UI label).
const Map<String, String> kLocaleToLanguage = {
  'en': 'English',
  'ar': 'العربية',
  'zh': '中国人',
  'hi': 'हिन्दी',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',
  'ru': 'Русский',
  'pt': 'Português',
  'it': 'Italiano',
  'ro': 'Română',
  'az': 'Azərbaycanca',
  'nl': 'Nederlands',
  'ja': '日本語',
  'ko': '한국어',
};

class LocaleNotifier extends Notifier<Locale> {
  static const _localeKey = 'app_locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final tag = prefs.getString(_localeKey) ?? 'en';
    return Locale(tag);
  }

  void setLocale(String languageName) {
    final tag = kLanguageToLocale[languageName] ?? 'en';
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_localeKey, tag);
    state = Locale(tag);
  }

  /// Returns the display name for the current locale (e.g. "English").
  String get currentLanguageName =>
      kLocaleToLanguage[state.languageCode] ?? 'English';
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
