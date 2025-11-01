import 'package:flutter/material.dart';
import '../models/app_theme_model.dart';
import '../services/preferences_service.dart';
import '../core/theme/app_theme.dart';

class AppProvider extends ChangeNotifier {
  String _currentThemeId = 'soft_rose';
  String _currentLanguage = 'en';

  String get currentThemeId => _currentThemeId;
  String get currentLanguage => _currentLanguage;

  ThemeColors get currentThemeColors {
    return AppThemes.allThemes[_currentThemeId] ?? AppThemes.softRose;
  }

  ThemeData get currentThemeData {
    return AppTheme.getThemeData(currentThemeColors);
  }

  AppProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _currentThemeId = PreferencesService.getTheme();
    _currentLanguage = PreferencesService.getLanguage();
    notifyListeners();
  }

  Future<void> setTheme(String themeId) async {
    if (AppThemes.allThemes.containsKey(themeId)) {
      _currentThemeId = themeId;
      await PreferencesService.setTheme(themeId);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await PreferencesService.setLanguage(languageCode);
    notifyListeners();
  }

  String translate(String key) {
    // This will be expanded to use a proper localization system
    return key;
  }
}
