import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';

/// Fixed physical line layout for the Madinah QCF/Hafs Mushaf.
///
/// The line boundaries come from the 15-line QCF page metadata.  Experimental
/// scripts may replace glyphs inside these already-fixed line slots, but they
/// never reflow the Quran into new lines.
class MushafVariantLayoutService {
  MushafVariantLayoutService._();

  static const assetPath = 'assets/mushaf_layout.json';
  static Map<String, dynamic>? _asset;

  static Future<void> ensureLoaded() async {
    if (_asset != null) return;
    final raw = await rootBundle.loadString(assetPath);
    _asset = jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<List<MushafVariantLine>> page(int pageNumber) async {
    await ensureLoaded();
    final pages = (_asset!['pages'] as Map).cast<String, dynamic>();
    final rawLines = (pages['$pageNumber'] as List?) ?? const [];
    final result = <MushafVariantLine>[];

    for (final raw in rawLines) {
      final map = (raw as Map).cast<String, dynamic>();
      final words = <String>[];
      final markers = <String>[];
      final rawWords = (map['words'] as List?) ?? const [];

      for (final rawWord in rawWords) {
        final word = (rawWord as Map).cast<String, dynamic>();
        final kind = word['kind'] as String? ?? 'word';
        final location = word['location'] as String?;
        if (location == null) continue;
        final parts = location.split(':');
        if (parts.length < 3) continue;

        final surah = int.tryParse(parts[0]);
        final ayah = int.tryParse(parts[1]);
        final wordIndex = int.tryParse(parts[2]);
        if (surah == null || ayah == null || wordIndex == null) continue;

        final verse = getVerse(surah, ayah, verseEndSymbol: false);
        final verseWords = verse
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();

        if (kind == 'marker') {
          markers.add('﴿$ayah﴾');
        } else if (wordIndex <= verseWords.length) {
          words.add(verseWords[wordIndex - 1]);
        }
      }

      result.add(
        MushafVariantLine(
          type: map['type'] as String? ?? 'text',
          centered: map['centered'] as bool? ?? false,
          surah: map['surah'] as int?,
          words: List.unmodifiable(words),
          markers: List.unmodifiable(markers),
        ),
      );
    }

    while (result.length < 15) {
      result.add(const MushafVariantLine(type: 'blank', centered: false, surah: null, words: [], markers: []));
    }
    return result.take(15).toList(growable: false);
  }
}

class MushafVariantLine {
  const MushafVariantLine({
    required this.type,
    required this.centered,
    required this.surah,
    required this.words,
    required this.markers,
  });

  final String type;
  final bool centered;
  final int? surah;
  final List<String> words;
  final List<String> markers;

  bool get isBlank => type == 'blank';
  bool get isSurahHeader => type == 'surah_name';

  String get text => [...words, ...markers].join(' ');
}
