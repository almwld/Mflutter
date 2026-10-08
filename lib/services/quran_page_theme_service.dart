import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuranPageTheme { paper, black, navy, deepGreen }

class QuranPageThemeService {
  static const _key = 'quran.page_theme';

  static Future<QuranPageTheme> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    return QuranPageTheme.values[index.clamp(0, QuranPageTheme.values.length - 1)];
  }

  static Future<void> save(QuranPageTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, theme.index);
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
