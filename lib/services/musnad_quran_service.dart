import 'dart:convert';

import 'package:flutter/services.dart';

/// Standalone Hafs Musnad Quran dataset loader.
///
/// The dataset contains all 6,236 ayahs independently from
/// [assets/unified_quran.json], so Musnad mode does not generate text at runtime.
class MusnadQuranService {
  static const String assetPath = 'assets/musnad_quran.json';

  static Map<String, List<Map<String, dynamic>>>? _cache;

  static Future<Map<String, List<Map<String, dynamic>>>> load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['surahs'] is! Map) {
      throw const FormatException('Invalid standalone Musnad Quran dataset');
    }

    final source = decoded['surahs'] as Map;
    final result = <String, List<Map<String, dynamic>>>{};
    var count = 0;

    for (final entry in source.entries) {
      final value = entry.value;
      if (value is! List) {
        throw const FormatException('Invalid Musnad surah');
      }

      result[entry.key.toString()] =
          value.map<Map<String, dynamic>>((item) {
        if (item is! Map || item['ayah'] == null || item['musnad'] is! String) {
          throw const FormatException('Invalid Musnad ayah');
        }
        count++;
        return Map<String, dynamic>.from(item);
      }).toList(growable: false);
    }

    if (count != 6236) {
      throw FormatException('Expected 6236 ayahs, got $count');
    }

    _cache = result;
    return result;
  }

  static Future<List<Map<String, dynamic>>> loadSurah(int surah) async {
    final all = await load();
    return all['$surah'] ?? const <Map<String, dynamic>>[];
  }
}
