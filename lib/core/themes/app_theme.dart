import 'package:flutter/material.dart';

class AppTheme {
  // الخطوط المتاحة
  static const _fontFamily = 'Amiri';
  static const _gold = Color(0xFFFFD700);
  static const _goldDark = Color(0xFFB8860B);
  static const _navy = Color(0xFF1A237E);
  static const _bg = Color(0xFF0A0E27);

  // ═══════════════════════════════════════
  // الثيم الذهبي الداكن (الرئيسي)
  // ═══════════════════════════════════════
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        fontFamily: _fontFamily,
        scaffoldBackgroundColor: _bg,
        primaryColor: _navy,
        colorScheme: const ColorScheme.dark(
          primary: _gold,
          secondary: _navy,
          surface: _navy,
          onPrimary: Color(0xFF1A237E),
          onSecondary: _gold,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _navy,
          foregroundColor: _gold,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: _gold, fontSize: 20, fontFamily: _fontFamily, fontWeight: FontWeight.bold),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _navy,
          selectedItemColor: _gold,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          color: _navy.withOpacity(0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _gold,
            foregroundColor: _navy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.all(_gold), trackColor: WidgetStateProperty.all(_gold.withOpacity(0.3))),
      );

  // ═══════════════════════════════════════
  // الثيم الفاتح
  // ═══════════════════════════════════════
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        fontFamily: _fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        primaryColor: _navy,
        colorScheme: const ColorScheme.light(
          primary: _goldDark,
          secondary: _navy,
          surface: Color(0xFFFDF9F3),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _navy,
          foregroundColor: _gold,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _navy,
          selectedItemColor: _gold,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
