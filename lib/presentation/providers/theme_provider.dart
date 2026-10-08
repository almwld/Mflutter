import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _loaded = false;
  String _fontFamily = 'Amiri';
  double _fontSize = 20;
  String _selectedTheme = 'default';

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  String get selectedTheme => _selectedTheme;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get loaded => _loaded;

  ThemeProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = (prefs.getBool('theme.dark') ?? true) ? ThemeMode.dark : ThemeMode.light;
    _fontFamily = prefs.getString('theme.font') ?? 'Amiri';
    _fontSize = (prefs.getDouble('theme.font_size') ?? 20).clamp(14, 36).toDouble();
    final savedTheme = prefs.getString('theme.palette') ?? 'default';
    _selectedTheme = ThemeService.themeNames.contains(savedTheme) ? savedTheme : 'default';
    _loaded = true;
    notifyListeners();
  }

  void toggleTheme() => setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _persist();
    notifyListeners();
  }

  void setTheme(String name) {
    if (!ThemeService.themeNames.contains(name) || _selectedTheme == name) return;
    _selectedTheme = name;
    _persist();
    notifyListeners();
  }

  void setFont(String font) {
    if (font != 'Amiri' && font != 'Musnad') return;
    if (_fontFamily == font) return;
    _fontFamily = font;
    _persist();
    notifyListeners();
  }

  void setFontSize(double size) {
    final next = size.clamp(14, 36).toDouble();
    if (_fontSize == next) return;
    _fontSize = next;
    _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme.dark', isDark);
    await prefs.setString('theme.font', _fontFamily);
    await prefs.setDouble('theme.font_size', _fontSize);
    await prefs.setString('theme.palette', _selectedTheme);
  }
}
