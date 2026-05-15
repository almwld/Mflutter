import 'package:flutter/material.dart';

class ThemeService {
  static const Map<String, Map<String, Color>> _themes = {
    'default': {
      'primary': Color(0xFF1A237E),
      'secondary': Color(0xFFFFD700),
      'background': Color(0xFF0A0E27),
      'surface': Color(0xFF16213E),
    },
    'emerald': {
      'primary': Color(0xFF004D40),
      'secondary': Color(0xFF00E676),
      'background': Color(0xFF0A1A0A),
      'surface': Color(0xFF1A2A1A),
    },
    'royal': {
      'primary': Color(0xFF4A148C),
      'secondary': Color(0xFFFFAB40),
      'background': Color(0xFF1A0A2E),
      'surface': Color(0xFF2A1A3E),
    },
    'ocean': {
      'primary': Color(0xFF01579B),
      'secondary': Color(0xFF40C4FF),
      'background': Color(0xFF0A1A2E),
      'surface': Color(0xFF1A2A3E),
    },
    'sunset': {
      'primary': Color(0xFFBF360C),
      'secondary': Color(0xFFFFD740),
      'background': Color(0xFF2E0A0A),
      'surface': Color(0xFF3E1A1A),
    },
  };

  static List<String> get themeNames => _themes.keys.toList();

  static Map<String, Color> getTheme(String name) {
    return _themes[name] ?? _themes['default']!;
  }
}
