import 'package:flutter/material.dart';

/// 🔤 نظام الخطوط
enum MudabbirFont { amiri, uthmani, musnad, kufi, hieroglyphic }

class FontManager {
  static const Map<MudabbirFont, String> _fontFamilies = {
    MudabbirFont.amiri: 'Amiri',
    MudabbirFont.uthmani: 'Amiri',       // نستخدم Amiri بدل Uthmani
    MudabbirFont.musnad: 'Musnad',
    MudabbirFont.kufi: 'Amiri',          // كوفي مبسط
    MudabbirFont.hieroglyphic: 'Amiri',
  };

  static String getFamily(MudabbirFont font) => _fontFamilies[font] ?? 'Amiri';

  static TextStyle verseStyle({
    MudabbirFont font = MudabbirFont.amiri,
    double fontSize = 20,
    Color color = const Color(0xFF2C1810),
    bool bold = true,
    double height = 2.0,
    double letterSpacing = 0.5,
  }) {
    return TextStyle(
      fontFamily: getFamily(font),
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color,
      height: height,
      letterSpacing: font == MudabbirFont.musnad ? 4.0 : letterSpacing,
    );
  }

  static TextStyle goldStyle({double fontSize = 22}) {
    return TextStyle(
      fontFamily: 'Amiri',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFFFD700),
      height: 2.0,
      letterSpacing: 1.5,
    );
  }

  static TextStyle silverStyle({double fontSize = 22}) {
    return TextStyle(
      fontFamily: 'Amiri',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFC0C0C0),
      height: 2.0,
    );
  }

  static TextStyle emeraldStyle({double fontSize = 22}) {
    return TextStyle(
      fontFamily: 'Amiri',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF50C878),
      height: 2.0,
    );
  }
}
