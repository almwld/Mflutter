import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryNavy = Color(0xFF1A237E);
  static const Color primaryNavyLight = Color(0xFF283593);
  static const Color primaryNavyDark = Color(0xFF0D164F);
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color primaryGoldLight = Color(0xFFFFE766);
  static const Color primaryGoldDark = Color(0xFFB89B00);
  static const Color gold = primaryGold;
  static const Color textOnPrimary = Colors.white;
  static const Color background = Color(0xFF0A0E27);
  static const Color backgroundLight = Color(0xFFF5F7FF);
  static const Color backgroundDark = Color(0xFF0A0E27);
  static const Color deepBackground = Color(0xFF06091C);
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceLight = Color(0xFF1A1A3E);
  static const Color cardBackground = Color(0xFF16213E);
  static const Color cardBackgroundDark = Color(0xFF111A33);
  static const Color textPrimary = Colors.white;
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color accent = primaryGold;
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
  static const Color elementFire = Color(0xFFE53935);
  static const Color elementWater = Color(0xFF1E88E5);
  static const Color elementEarth = Color(0xFF8D6E63);
  static const LinearGradient navyGoldGradient = LinearGradient(colors: [primaryNavy, primaryGold]);
  static const LinearGradient goldGradient = LinearGradient(colors: [primaryGoldLight, primaryGoldDark]);
  static const LinearGradient deepGradient = LinearGradient(colors: [deepBackground, background, surface]);
}
