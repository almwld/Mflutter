import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuranPageTheme { paper, black, navy, deepGreen, pearl, amber }

class QuranPageThemeService {
  static const _key = 'quran.page_theme';

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
      case QuranPageTheme.pearl:
        return const Color(0xFFF8F7F2);
      case QuranPageTheme.amber:
        return const Color(0xFF101010);
    }
  }

  static Color text(QuranPageTheme theme) {
    switch (theme) {
      case QuranPageTheme.paper:
        return const Color(0xFF3B2B1C);
      case QuranPageTheme.black:
        return const Color(0xFFF5F2EA);
      case QuranPageTheme.navy:
        return const Color(0xFFF2F5FA);
      case QuranPageTheme.deepGreen:
        return const Color(0xFFEAF4EE);
      case QuranPageTheme.pearl:
        return const Color(0xFF252525);
      case QuranPageTheme.amber:
        return const Color(0xFFF2C879);
    }
  }

  static String label(QuranPageTheme theme) {
    switch (theme) {
      case QuranPageTheme.paper: return 'ورقي';
      case QuranPageTheme.black: return 'أسود';
      case QuranPageTheme.navy: return 'كحلي';
      case QuranPageTheme.deepGreen: return 'أخضر عميق';
      case QuranPageTheme.pearl: return 'أبيض لؤلؤي';
      case QuranPageTheme.amber: return 'عنبر هادئ';
    }
  }
}
