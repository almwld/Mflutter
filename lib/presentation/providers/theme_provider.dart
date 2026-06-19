import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  String _fontFamily = 'Amiri';
  double _fontSize = 20;

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setFont(String font) { _fontFamily = font; notifyListeners(); }
  void setFontSize(double size) { _fontSize = size.clamp(14, 36); notifyListeners(); }
}
