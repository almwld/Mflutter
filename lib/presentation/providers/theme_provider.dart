import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _loaded = false;
  String _fontFamily = 'Amiri';
  double _fontSize = 20;
  String _selectedTheme = 'default';
  String? _persistenceError;
  Future<void> _persistQueue = Future<void>.value();

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  String get selectedTheme => _selectedTheme;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get loaded => _loaded;
  String? get persistenceError => _persistenceError;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString('theme.mode');
      _themeMode = switch (savedMode) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        'dark' => ThemeMode.dark,
        _ => (prefs.getBool('theme.dark') ?? true)
            ? ThemeMode.dark
            : ThemeMode.light,
      };
      final savedFont = prefs.getString('theme.font') ?? 'Amiri';
      _fontFamily = savedFont == 'Musnad' ? 'Musnad' : 'Amiri';
      _fontSize = (prefs.getDouble('theme.font_size') ?? 20)
          .clamp(14, 36)
          .toDouble();
      final savedTheme = prefs.getString('theme.palette') ?? 'default';
      _selectedTheme = ThemeService.themeNames.contains(savedTheme)
          ? savedTheme
          : 'default';
      _persistenceError = null;
    } catch (error) {
      _persistenceError = 'تعذر تحميل تفضيلات المظهر؛ استُخدمت القيم الافتراضية: $error';
      debugPrint('ThemeProvider: preference load failed: $error');
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  void toggleTheme() =>
      setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);

  void setThemeMode(ThemeMode mode) {
    if (!{ThemeMode.light, ThemeMode.dark, ThemeMode.system}.contains(mode) ||
        _themeMode == mode) {
      return;
    }
    _themeMode = mode;
    _persist();
    notifyListeners();
  }

  void setTheme(String name) {
    if (!ThemeService.themeNames.contains(name) || _selectedTheme == name) {
      return;
    }
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

  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.dark;
    _fontFamily = 'Amiri';
    _fontSize = 20;
    _selectedTheme = 'default';
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final mode = _themeMode;
    final dark = _themeMode != ThemeMode.light;
    final font = _fontFamily;
    final size = _fontSize;
    final palette = _selectedTheme;
    final operation = _persistQueue.catchError((Object _) {}).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = await prefs.setString('theme.mode', switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
        ThemeMode.dark => 'dark',
      });
      final savedLegacyMode = await prefs.setBool('theme.dark', dark);
      final savedFont = await prefs.setString('theme.font', font);
      final savedSize = await prefs.setDouble('theme.font_size', size);
      final savedPalette = await prefs.setString('theme.palette', palette);
      if (!savedMode || !savedLegacyMode || !savedFont || !savedSize || !savedPalette) {
        throw StateError('رفض التخزين المحلي حفظ أحد تفضيلات المظهر.');
      }
    });
    _persistQueue = operation;
    try {
      await operation;
      final hadError = _persistenceError != null;
      _persistenceError = null;
      if (hadError) notifyListeners();
    } catch (error) {
      _persistenceError = 'تعذر حفظ تفضيلات المظهر: $error';
      debugPrint('ThemeProvider: preference save failed: $error');
      notifyListeners();
    }
  }
}
