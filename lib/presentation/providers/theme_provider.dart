import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _loaded = false;
  String _fontFamily = 'Amiri';
  double _fontSize = 20;

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get loaded => _loaded;

  ThemeProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('theme.dark') ?? true) ? ThemeMode.dark : ThemeMode.light;
    _fontFamily = prefs.getString('theme.font') ?? 'Amiri';
    _fontSize = prefs.getDouble('theme.font_size') ?? 20;
    _loaded = true;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _persist();
    notifyListeners();
  }

  void setFont(String font) { _fontFamily = font; _persist(); notifyListeners(); }
  void setFontSize(double size) { _fontSize = size.clamp(14, 36); _persist(); notifyListeners(); }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme.dark', _themeMode == ThemeMode.dark);
    await prefs.setString('theme.font', _fontFamily);
    await prefs.setDouble('theme.font_size', _fontSize);
  }
}
