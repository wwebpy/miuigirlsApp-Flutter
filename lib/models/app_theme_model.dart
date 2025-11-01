import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'app_theme_model.g.dart';

@HiveType(typeId: 4)
class AppThemeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int primaryColor;

  @HiveField(3)
  final int secondaryColor;

  @HiveField(4)
  final int accentColor;

  @HiveField(5)
  final int backgroundColor;

  @HiveField(6)
  final int surfaceColor;

  AppThemeModel({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
  });
}

class ThemeColors {
  final Color primary;
  final Color primaryLight;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;
  final Color success;
  final Color warning;
  final Color shadow;
  final Color accentGold;
  final Color moodTerrible;
  final Color moodBad;
  final Color moodOkay;
  final Color moodGood;
  final Color moodAmazing;

  ThemeColors({
    required this.primary,
    required this.primaryLight,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
    required this.success,
    required this.warning,
    required this.shadow,
    required this.accentGold,
    required this.moodTerrible,
    required this.moodBad,
    required this.moodOkay,
    required this.moodGood,
    required this.moodAmazing,
  });
}

// Predefined Themes
class AppThemes {
  // 1. Soft Rose (Original)
  static final softRose = ThemeColors(
    primary: const Color(0xFFE8B4D0),
    primaryLight: const Color(0xFFF5D5E5),
    secondary: const Color(0xFFB8A9D4),
    accent: const Color(0xFFFFC9D9),
    background: const Color(0xFFFFFBFE),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFF8F4F9),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFFFFD700),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFFFFD700),
  );

  // 2. Lavender Dreams
  static final lavenderDreams = ThemeColors(
    primary: const Color(0xFFB8A9D4),
    primaryLight: const Color(0xFFD4C9E5),
    secondary: const Color(0xFF9B8FC9),
    accent: const Color(0xFFE0D5F5),
    background: const Color(0xFFFBF9FF),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFF5F2FA),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFFB794F6),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFFB794F6),
  );

  // 3. Peachy Sunset
  static final peachySunset = ThemeColors(
    primary: const Color(0xFFFFB5A7),
    primaryLight: const Color(0xFFFFD4C9),
    secondary: const Color(0xFFFFCC99),
    accent: const Color(0xFFFFF4E6),
    background: const Color(0xFFFFFBF9),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFFFF5F0),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFFFFCC99),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFFFFCC99),
  );

  // 4. Mint Fresh
  static final mintFresh = ThemeColors(
    primary: const Color(0xFFA8E6CF),
    primaryLight: const Color(0xFFC8F2DC),
    secondary: const Color(0xFF88D8B0),
    accent: const Color(0xFFE0F9F0),
    background: const Color(0xFFF9FFFE),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFF0FAF5),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFF88D8B0),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFF88D8B0),
  );

  // 5. Coral Blush
  static final coralBlush = ThemeColors(
    primary: const Color(0xFFFF9999),
    primaryLight: const Color(0xFFFFB8B8),
    secondary: const Color(0xFFFFB5B5),
    accent: const Color(0xFFFFDDDD),
    background: const Color(0xFFFFFAFA),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFFFF0F0),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFFFFB5B5),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFFFFB5B5),
  );

  // 6. Cherry Blossom
  static final cherryBlossom = ThemeColors(
    primary: const Color(0xFFFFB7D5),
    primaryLight: const Color(0xFFFFD6E8),
    secondary: const Color(0xFFFFADD2),
    accent: const Color(0xFFFFF0F7),
    background: const Color(0xFFFFFBFD),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFFFF5F9),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFFFFADD2),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFFFFADD2),
  );

  // 7. Pride Rainbow
  static final prideRainbow = ThemeColors(
    primary: const Color(0xFFE040FB),
    primaryLight: const Color(0xFFF3B3FF),
    secondary: const Color(0xFF00BCD4),
    accent: const Color(0xFFFF4081),
    background: const Color(0xFFFFFBFF),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFFFF0FA),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFFFFD740),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFFE040FB),
  );

  // 8. Ocean Breeze (Neutral)
  static final oceanBreeze = ThemeColors(
    primary: const Color(0xFF64B5F6),
    primaryLight: const Color(0xFF90CAF9),
    secondary: const Color(0xFF4FC3F7),
    accent: const Color(0xFFB3E5FC),
    background: const Color(0xFFFAFCFF),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFF0F7FF),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFF4FC3F7),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFF4FC3F7),
  );

  // 9. Forest Green (Neutral)
  static final forestGreen = ThemeColors(
    primary: const Color(0xFF66BB6A),
    primaryLight: const Color(0xFF81C784),
    secondary: const Color(0xFF4CAF50),
    accent: const Color(0xFFC8E6C9),
    background: const Color(0xFFFAFFFB),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFF1F8F2),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFF81C784),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFF81C784),
  );

  // 10. Sunset Gradient (Neutral/Funky)
  static final sunsetGradient = ThemeColors(
    primary: const Color(0xFFFF6F61),
    primaryLight: const Color(0xFFFF8F84),
    secondary: const Color(0xFFFFB74D),
    accent: const Color(0xFFFFF9C4),
    background: const Color(0xFFFFFBF8),
    surface: const Color(0xFFFFFFFF),
    surfaceVariant: const Color(0xFFFFF5F0),
    textPrimary: const Color(0xFF1C1B1F),
    textSecondary: const Color(0xFF625B71),
    error: const Color(0xFFBA1A1A),
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFF9800),
    shadow: const Color(0x1A000000),
    accentGold: const Color(0xFFFFB74D),
    moodTerrible: const Color(0xFFFF6B6B),
    moodBad: const Color(0xFFFFB347),
    moodOkay: const Color(0xFFFFE66D),
    moodGood: const Color(0xFFB8E994),
    moodAmazing: const Color(0xFFFFB74D),
  );

  static final Map<String, ThemeColors> allThemes = {
    'soft_rose': softRose,
    'lavender_dreams': lavenderDreams,
    'peachy_sunset': peachySunset,
    'mint_fresh': mintFresh,
    'coral_blush': coralBlush,
    'cherry_blossom': cherryBlossom,
    'pride_rainbow': prideRainbow,
    'ocean_breeze': oceanBreeze,
    'forest_green': forestGreen,
    'sunset_gradient': sunsetGradient,
  };

  static final Map<String, String> themeNames = {
    'soft_rose': 'Soft Rose',
    'lavender_dreams': 'Lavender Dreams',
    'peachy_sunset': 'Peachy Sunset',
    'mint_fresh': 'Mint Fresh',
    'coral_blush': 'Coral Blush',
    'cherry_blossom': 'Cherry Blossom',
    'pride_rainbow': 'Pride Rainbow',
    'ocean_breeze': 'Ocean Breeze',
    'forest_green': 'Forest Green',
    'sunset_gradient': 'Sunset Gradient',
  };

  static final Map<String, String> themeCategories = {
    'soft_rose': 'Feminine',
    'lavender_dreams': 'Feminine',
    'peachy_sunset': 'Feminine',
    'mint_fresh': 'Feminine',
    'coral_blush': 'Feminine',
    'cherry_blossom': 'Feminine',
    'pride_rainbow': 'Pride',
    'ocean_breeze': 'Neutral',
    'forest_green': 'Neutral',
    'sunset_gradient': 'Vibrant',
  };
}
