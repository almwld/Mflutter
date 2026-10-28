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
  static Future<void>? _loadingAsset;
  static final Map<int, Future<List<MushafVariantLine>>> _pageCache = {};

  static Future<void> ensureLoaded() async {
    if (_asset != null) return;
    final pending = _loadingAsset;
    if (pending != null) {
      await pending;
      return;
    }

    final loading = _loadAsset();
    _loadingAsset = loading;
    try {
      await loading;
      if (identical(_loadingAsset, loading)) _loadingAsset = null;
    } catch (_) {
      if (identical(_loadingAsset, loading)) _loadingAsset = null;
      rethrow;
    }
  }

  static Future<void> _loadAsset() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('مخطط تخطيط صفحات المصحف غير صالح.');
    }
    _asset = decoded.cast<String, dynamic>();
  }

  static Future<List<MushafVariantLine>> page(int pageNumber) {
    final cached = _pageCache[pageNumber];
    if (cached != null) return cached;

    final pending = _loadPage(pageNumber);
    _pageCache[pageNumber] = pending;
    return pending.catchError((Object error, StackTrace stackTrace) {
      // Failed page loads are not pinned in cache; a later request can retry.
      if (identical(_pageCache[pageNumber], pending)) {
        _pageCache.remove(pageNumber);
      }
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  static Future<List<MushafVariantLine>> _loadPage(int pageNumber) async {
    await ensureLoaded();
    final pages = (_asset!['pages'] as Map).cast<String, dynamic>();
    final rawLines = (pages['$pageNumber'] as List?) ?? const [];
    final result = <MushafVariantLine>[];

    for (final raw in rawLines) {
      final map = (raw as Map).cast<String, dynamic>();
      final words = <String>[];
      final markers = <String>[];
      final segments = <String>[];
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
          final marker = '﴿$ayah﴾';
          markers.add(marker);
          segments.add(marker);
        } else if (wordIndex <= verseWords.length) {
          final wordText = verseWords[wordIndex - 1];
          words.add(wordText);
          segments.add(wordText);
        }
      }

      result.add(
        MushafVariantLine(
          type: map['type'] as String? ?? 'text',
          centered: map['centered'] as bool? ?? false,
          surah: map['surah'] as int?,
          words: List.unmodifiable(words),
          markers: List.unmodifiable(markers),
          segments: List.unmodifiable(segments),
        ),
      );
    }

    while (result.length < 15) {
      result.add(const MushafVariantLine(type: 'blank', centered: false, surah: null, words: [], markers: [], segments: []));
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
    required this.segments,
  });

  final String type;
  final bool centered;
  final int? surah;
  final List<String> words;
  final List<String> markers;
  /// Ordered word/ayah-marker sequence from the canonical QCF line metadata.
  final List<String> segments;

  bool get isBlank => type == 'blank';
  bool get isSurahHeader => type == 'surah_name';

  String get text => segments.join(' ');
}
