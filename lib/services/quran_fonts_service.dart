import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/themes/font_manager.dart';

/// Loads the bundled Raqq manuscript-Kufic fonts from their text-encoded
/// assets. A fallback is retained if the optional font assets are unavailable.
class QuranFontsService {
  QuranFontsService._();

  static Future<void>? _loadFuture;
  static bool _raqqLoaded = false;
  static bool _raqqSuraLoaded = false;

  static bool get isRaqqLoaded => _raqqLoaded;
  static bool get isRaqqSuraLoaded => _raqqSuraLoaded;

  static Future<void> load() => _loadFuture ??= _loadFonts();

  static Future<void> _loadFonts() async {
    _raqqLoaded = await _loadFamily(
      family: 'Raqq',
      assetPath: 'assets/fonts/Raqq.ttf.base64',
    );
    _raqqSuraLoaded = await _loadFamily(
      family: 'RaqqSura',
      assetPath: 'assets/fonts/RaqqSura.ttf.base64',
    );
    FontManager.markRaqqFontLoaded(_raqqLoaded);
    FontManager.markRaqqSuraFontLoaded(_raqqSuraLoaded);
  }

  static Future<bool> _loadFamily({
    required String family,
    required String assetPath,
  }) async {
    try {
      final encoded = await rootBundle.loadString(assetPath);
      final bytes = base64Decode(encoded.replaceAll(RegExp(r'\s+'), ''));
      if (bytes.isEmpty) throw const FormatException('Empty font payload');
      final data = ByteData.sublistView(Uint8List.fromList(bytes));
      await (FontLoader(family)..addFont(Future<ByteData>.value(data))).load();
      return true;
    } catch (error) {
      debugPrint('QuranFontsService: could not load $family: $error');
      return false;
    }
  }
}
