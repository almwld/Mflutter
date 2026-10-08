import 'package:flutter/material.dart';

class AppTheme {
  static const fontFamily = 'Amiri';
  static const gold = Color(0xFFFFD700);
  static const goldDark = Color(0xFFB8860B);
  static const navy = Color(0xFF1A237E);
  static const darkBackground = Color(0xFF0A0E27);
  static const darkSurface = Color(0xFF16213E);
  static const lightBackground = Color(0xFFF5F0E8);
  static const lightSurface = Color(0xFFFDF9F3);

  static ThemeData get darkTheme => _buildTheme(dark: true);
  static ThemeData get lightTheme => _buildTheme(dark: false);

  static ThemeData _buildTheme({required bool dark}) {
    final scheme = dark
        ? const ColorScheme.dark(
            primary: gold,
            onPrimary: navy,
            secondary: navy,
            onSecondary: gold,
            surface: darkSurface,
            onSurface: Color(0xFFF7F4EC),
            error: Color(0xFFFF6B6B),
          )
        : const ColorScheme.light(
            primary: goldDark,
            onPrimary: Colors.white,
            secondary: navy,
            onSecondary: gold,
            surface: lightSurface,
            onSurface: Color(0xFF24202A),
            error: Color(0xFFB3261E),
          );
    final background = dark ? darkBackground : lightBackground;
    final foreground = dark ? const Color(0xFFF7F4EC) : const Color(0xFF24202A);

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: background,
      primaryColor: navy,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? darkSurface : navy,
        foregroundColor: gold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: gold,
          fontSize: 20,
          fontFamily: fontFamily,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: gold),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: foreground.withOpacity(dark ? .08 : .12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(color: foreground.withOpacity(.55)),
        labelStyle: TextStyle(color: foreground.withOpacity(.8)),
        prefixIconColor: scheme.primary,
        suffixIconColor: scheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: foreground.withOpacity(.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: foreground.withOpacity(.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark ? darkSurface : navy,
        selectedItemColor: gold,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withOpacity(.65)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(scheme.primary),
        trackColor: WidgetStateProperty.all(scheme.primary.withOpacity(.3)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        titleTextStyle: TextStyle(color: foreground, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: fontFamily),
        contentTextStyle: TextStyle(color: foreground, fontSize: 16, fontFamily: fontFamily),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? darkSurface : navy,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: fontFamily),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      dividerTheme: DividerThemeData(color: foreground.withOpacity(.12), thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        textColor: foreground,
      ),
    );
  }
}
