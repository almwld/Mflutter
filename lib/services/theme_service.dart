import 'package:flutter/material.dart';

class ThemeService {
  static const Map<String, Map<String, Color>> _themes = {
    'default': {
      'primary': Color(0xFF1A237E),
      'secondary': Color(0xFFFFD700),
      'background': Color(0xFF0A0E27),
      'surface': Color(0xFF16213E),
      'lightBackground': Color(0xFFF5F0E8),
      'lightSurface': Color(0xFFFDF9F3),
    },
    'emerald': {
      'primary': Color(0xFF004D40),
      'secondary': Color(0xFF69F0AE),
      'background': Color(0xFF071C18),
      'surface': Color(0xFF12352E),
      'lightBackground': Color(0xFFEDF6F1),
      'lightSurface': Color(0xFFFFFFFF),
    },
    'royal': {
      'primary': Color(0xFF4A148C),
      'secondary': Color(0xFFFFCC80),
      'background': Color(0xFF180C25),
      'surface': Color(0xFF2B193B),
      'lightBackground': Color(0xFFF4EDF9),
      'lightSurface': Color(0xFFFFFFFF),
    },
    'ocean': {
      'primary': Color(0xFF01579B),
      'secondary': Color(0xFF80D8FF),
      'background': Color(0xFF071B2B),
      'surface': Color(0xFF12334A),
      'lightBackground': Color(0xFFEBF5FB),
      'lightSurface': Color(0xFFFFFFFF),
    },
    'sunset': {
      'primary': Color(0xFFBF360C),
      'secondary': Color(0xFFFFD180),
      'background': Color(0xFF24110C),
      'surface': Color(0xFF3D2118),
      'lightBackground': Color(0xFFFFF1E8),
      'lightSurface': Color(0xFFFFFFFF),
    },
  };

  static const Map<String, String> themeLabels = {
    'default': 'ملكي كلاسيكي',
    'emerald': 'زمردي',
    'royal': 'أرجواني ملكي',
    'ocean': 'أزرق محيطي',
    'sunset': 'غروب دافئ',
  };

  static List<String> get themeNames => _themes.keys.toList(growable: false);

  static String labelFor(String name) => themeLabels[name] ?? themeLabels['default']!;

  static Map<String, Color> getTheme(String name) =>
      _themes[name] ?? _themes['default']!;
}
