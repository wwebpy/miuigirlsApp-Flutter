import 'package:hive_flutter/hive_flutter.dart';

class PreferencesService {
  static const String _prefsBox = 'preferences';
  static const String _themeKey = 'selected_theme';
  static const String _languageKey = 'selected_language';
  static const String _onboardingKey = 'onboarding_completed';

  static Box get _prefs => Hive.box(_prefsBox);

  static Future<void> init() async {
    await Hive.openBox(_prefsBox);
  }

  // Theme
  static String getTheme() {
    return _prefs.get(_themeKey, defaultValue: 'soft_rose') as String;
  }

  static Future<void> setTheme(String themeId) async {
    await _prefs.put(_themeKey, themeId);
  }

  // Language
  static String getLanguage() {
    return _prefs.get(_languageKey, defaultValue: 'en') as String;
  }

  static Future<void> setLanguage(String languageCode) async {
    await _prefs.put(_languageKey, languageCode);
  }

  // Onboarding
  static bool isOnboardingCompleted() {
    return _prefs.get(_onboardingKey, defaultValue: false) as bool;
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.put(_onboardingKey, completed);
  }
}
