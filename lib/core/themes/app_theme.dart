import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Amiri',
    scaffoldBackgroundColor: const Color(0xFFF5F0E8),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A237E), foregroundColor: Color(0xFFFFD700)),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Amiri',
    scaffoldBackgroundColor: const Color(0xFF0A0E27),
    colorScheme: const ColorScheme.dark(primary: Color(0xFFFFD700)),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A237E), foregroundColor: Color(0xFFFFD700)),
  );
}
