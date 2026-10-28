import 'dart:convert';

import 'package:flutter/services.dart';

/// Reproducible word counts over the Quran text asset bundled with the app.
///
/// This service reports literal counts under a documented normalization rule.
/// It does not classify numerical patterns as miracles or make theological
/// conclusions from the resulting counts.
class QuranNumericalAnalysisService {
  QuranNumericalAnalysisService({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  static const String sourceAsset = 'assets/unified_quran.json';

  Future<QuranWordAnalysis> analyzeAsset() async {
    final jsonText = await (_bundle ?? rootBundle).loadString(sourceAsset);
    return analyzeJson(jsonText);
  }

  /// Parses the project's current data shape: { "surahNumber": [verse, ...] }.
  /// Verse objects must contain a string `text` field to contribute to counts.
  static QuranWordAnalysis analyzeJson(String jsonText) {
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map) {
      throw const FormatException('يجب أن تكون بيانات القرآن كائن JSON.');
    }

    final counts = <String, int>{};
    final locations = <String, List<QuranWordOccurrence>>{};
    var verseCount = 0;
    var wordCount = 0;
    var surahCount = 0;

    for (final entry in decoded.entries) {
      final surahNumber = int.tryParse(entry.key.toString());
      final verses = entry.value;
      if (surahNumber == null || surahNumber < 1 || surahNumber > 114 ||
          verses is! List) {
        continue;
      }
      if (verses.isNotEmpty) surahCount++;

      for (var index = 0; index < verses.length; index++) {
        final verse = verses[index];
        if (verse is! Map) continue;
        final text = verse['text'];
        if (text is! String || text.trim().isEmpty) continue;
        verseCount++;

        final verseCounts = <String, int>{};
        for (final token in tokenize(text)) {
          counts.update(token, (count) => count + 1, ifAbsent: () => 1);
          verseCounts.update(token, (count) => count + 1, ifAbsent: () => 1);
          wordCount++;
        }
        for (final occurrence in verseCounts.entries) {
          locations.putIfAbsent(occurrence.key, () => <QuranWordOccurrence>[])
              .add(QuranWordOccurrence(
                surahNumber: surahNumber,
                ayahNumber: index + 1,
                count: occurrence.value,
              ));
        }
      }
    }

    if (verseCount == 0 || wordCount == 0) {
      throw const FormatException(
        'لم يتم العثور على آيات قابلة للتحليل في ملف القرآن.',
      );
    }

    return QuranWordAnalysis._(
      counts: counts,
      occurrences: locations,
      verseCount: verseCount,
      wordCount: wordCount,
      surahCount: surahCount,
      source: sourceAsset,
    );
  }

  /// Normalizes Arabic orthographic variants and removes Arabic diacritics
  /// before splitting on non-Arabic letters.
  ///
  /// Counts are therefore reproducible for this rule, but may differ from
  /// counts based on a different Uthmani spelling or tokenization convention.
  static String normalizeArabic(String input) {
    var value = input
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي');
    return value;
  }

  static List<String> tokenize(String input) {
    final normalized = normalizeArabic(input);
    return RegExp(r'[\u0621-\u064A\u0671]+')
        .allMatches(normalized)
        .map((match) => match.group(0)!)
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
  }
}

class QuranWordOccurrence {
  const QuranWordOccurrence({
    required this.surahNumber,
    required this.ayahNumber,
    required this.count,
  });

  final int surahNumber;
  final int ayahNumber;
  final int count;
}

class QuranWordAnalysis {
  QuranWordAnalysis._({
    required Map<String, int> counts,
    required Map<String, List<QuranWordOccurrence>> occurrences,
    required this.verseCount,
    required this.wordCount,
    required this.surahCount,
    required this.source,
  })  : wordCounts = Map<String, int>.unmodifiable(counts),
        wordOccurrences = Map<String, List<QuranWordOccurrence>>.unmodifiable(
          occurrences.map((word, items) {
            final ordered = List<QuranWordOccurrence>.from(items)
              ..sort((a, b) {
                final bySurah = a.surahNumber.compareTo(b.surahNumber);
                return bySurah != 0
                    ? bySurah
                    : a.ayahNumber.compareTo(b.ayahNumber);
              });
            return MapEntry(
              word,
              List<QuranWordOccurrence>.unmodifiable(ordered),
            );
          }),
        );

  final Map<String, int> wordCounts;
  final Map<String, List<QuranWordOccurrence>> wordOccurrences;

  List<QuranWordOccurrence> occurrencesFor(String input) {
    final tokens = QuranNumericalAnalysisService.tokenize(input);
    if (tokens.length != 1) return const <QuranWordOccurrence>[];
    return wordOccurrences[tokens.single] ?? const <QuranWordOccurrence>[];
  }
  final int verseCount;
  final int wordCount;
  final int surahCount;
  final String source;

  int countWord(String input) {
    final tokens = QuranNumericalAnalysisService.tokenize(input);
    if (tokens.length != 1) return 0;
    return wordCounts[tokens.single] ?? 0;
  }

  List<MapEntry<String, int>> countsFor(List<String> words) {
    return words
        .map((word) => MapEntry(word, countWord(word)))
        .toList(growable: false);
  }
}
