import 'package:flutter/material.dart';

class AppTheme {
  // ═══════════════════════════════════════
  // الثيم الداكن (الافتراضي)
  // ═══════════════════════════════════════
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Amiri',
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        primaryColor: const Color(0xFF1A237E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFF1A237E),
          surface: Color(0xFF1A237E),
          onPrimary: Color(0xFF1A237E),
          onSecondary: Color(0xFFFFD700),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Color(0xFFFFD700),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 20,
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A237E),
          selectedItemColor: Color(0xFFFFD700),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A237E).withOpacity(0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  // ═══════════════════════════════════════
  // الثيم الفاتح
  // ═══════════════════════════════════════
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Amiri',
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        primaryColor: const Color(0xFF1A237E),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFB8860B),
          secondary: Color(0xFF1A237E),
          surface: Color(0xFFFDF9F3),
          onPrimary: Colors.white,
          onSecondary: Color(0xFFFFD700),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Color(0xFFFFD700),
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A237E),
          selectedItemColor: Color(0xFFFFD700),
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
