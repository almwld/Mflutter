import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuranPageTheme { paper, black, navy, deepGreen }

class QuranPageThemeService {
  static const _key = 'quran.page_theme';
  static const _fontColorKey = 'quran.page_font_color';

  static Future<Color?> loadFontColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getInt(_fontColorKey);
      return value == null ? null : Color(value);
    } catch (error) {
      debugPrint('QuranPageThemeService: could not load font color: $error');
      return null;
    }
  }

  static Future<void> saveFontColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setInt(_fontColorKey, color.value);
    if (!saved) throw StateError('تعذر حفظ لون خط المصحف محليًا.');
  }

  static Future<void> clearFontColor() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fontColorKey);
  }

  static Future<QuranPageTheme> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_key) ?? 0;
      return QuranPageTheme.values[
          index.clamp(0, QuranPageTheme.values.length - 1).toInt()];
    } catch (error) {
      debugPrint('QuranPageThemeService: could not load page theme: $error');
      return QuranPageTheme.paper;
    }
  }

  static Future<void> save(QuranPageTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setInt(_key, theme.index);
    if (!saved) {
      throw StateError('تعذر حفظ مظهر صفحات المصحف محليًا.');
    }
  }

  static Color background(QuranPageTheme theme) {
    switch (theme) {
      case QuranPageTheme.paper:
        return const Color(0xFFF8F1E4);
      case QuranPageTheme.black:
        return const Color(0xFF050505);
      case QuranPageTheme.navy:
        return const Color(0xFF071329);
      case QuranPageTheme.deepGreen:
        return const Color(0xFF071914);
    }
  }

  static Color text(QuranPageTheme theme) {
    switch (theme) {
      case QuranPageTheme.paper:
        return const Color(0xFFD49A16);
      case QuranPageTheme.black:
      case QuranPageTheme.navy:
      case QuranPageTheme.deepGreen:
        return const Color(0xFFFFD45A);
    }
  }

  static String label(QuranPageTheme theme) {
    switch (theme) {
      case QuranPageTheme.paper: return 'ورقي';
      case QuranPageTheme.black: return 'أسود';
      case QuranPageTheme.navy: return 'كحلي';
      case QuranPageTheme.deepGreen: return 'أخضر عميق';
    }
  }
}
