import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart' show getSurahNameArabic, getPageNumber;
import '../domain/models/quran_models.dart';
import '../domain/entities/verse.dart';
import 'quran_loader_service.dart';
import 'quran_source_corrections.dart';

class QuranService {
  static Map<String, dynamic>? _cachedQuran;
  static Future<Map<String, dynamic>>? _loadingQuran;

  static Future<Map<String, dynamic>> loadQuran() {
    final cached = _cachedQuran;
    if (cached != null) return Future<Map<String, dynamic>>.value(cached);
    final pending = _loadingQuran;
    if (pending != null) return pending;

    final loading = _loadQuranOnce();
    _loadingQuran = loading;
    return loading.then<Map<String, dynamic>>(
      (quran) => quran,
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_loadingQuran, loading)) _loadingQuran = null;
        Error.throwWithStackTrace(error, stackTrace);
      },
    );
  }

  static Future<Map<String, dynamic>> _loadQuranOnce() async {
    final raw = await rootBundle.loadString('assets/unified_quran.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('صيغة unified_quran.json غير صحيحة: المتوقع كائن السور');
    }

    final quran = QuranSourceCorrections.correctQuranMap(
      Map<String, dynamic>.from(decoded),
    );
    if (quran.length != 114) {
      throw FormatException(
        'يجب أن يحتوي unified_quran.json على 114 سورة بالضبط؛ الموجود ${quran.length}.',
      );
    }
    var verseCount = 0;
    for (var surah = 1; surah <= 114; surah++) {
      final verses = quran['$surah'];
      final expectedCount = QuranLoaderService.canonicalSurahAyahCounts[surah - 1];
      if (verses is! List || verses.length != expectedCount) {
        throw FormatException(
          'عدد آيات السورة $surah غير مطابق للمصحف: المتوقع $expectedCount، '
          'والموجود ${verses is List ? verses.length : 0}.',
        );
      }
      for (var index = 0; index < verses.length; index++) {
        final verse = verses[index];
        if (verse is! Map ||
            verse['text'] is! String ||
            (verse['text'] as String).trim().isEmpty) {
          throw FormatException(
            'نص الآية $surah:${index + 1} مفقود أو غير صالح',
          );
        }
        verseCount++;
      }
    }

    if (verseCount != QuranLoaderService.expectedAyahCount) {
      throw FormatException(
        'عدد الآيات في unified_quran.json غير صحيح: المتوقع '
        '${QuranLoaderService.expectedAyahCount}، والموجود $verseCount',
      );
    }

    _cachedQuran = Map<String, dynamic>.unmodifiable({
      for (var surah = 1; surah <= 114; surah++)
        '$surah': List<Map<String, dynamic>>.unmodifiable(
          (quran['$surah'] as List).map(
            (verse) => Map<String, dynamic>.unmodifiable(
              Map<String, dynamic>.from(verse as Map),
            ),
          ),
        ),
    });
    return _cachedQuran!;
  }

  /// Normalizes common Arabic orthographic variants without relying on a
  /// String.normalize API that Dart does not provide.
  static String normalizeSearchText(String value) {
    return value
        // Uthmani dagger alif represents an alif in common orthography.
        .replaceAll('ٰ', 'ا')
        .replaceAll(
          RegExp(r'[ًٌٍَُِّْۖۗۘۙۚۛۜ۞ۣ۟۠ۡۢۤۥۦۧۨ۩۪ۭ۫۬]'),
          '',
        )
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[ٱأإآٲٳٵٶٷ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        // quran_full.json omits the dagger alif in this canonical token.
        .replaceAll('العلمين', 'العالمين')
        .toLowerCase()
        .trim();
  }

  static String _normalizeSearchToken(String value) => value
      .replaceAll(
        RegExp(r'[ًٌٍَُِّْٰۖۗۘۙۚۛۜ۞ۣ۟۠ۡۢۤۥۦۧۨ۩۪ۭ۫۬]'),
        '',
      )
      .replaceAll('ـ', '')
      // Keep أ and إ distinct: collapsing them makes الأذن match بإذن.
      .replaceAll('ٱ', 'ا')
      .replaceAll('ى', 'ي')
      .trim();

  static String _stripAttachedArticlePrefix(String token) {
    if (token.startsWith('لل') && token.length > 2) {
      return 'ال${token.substring(2)}';
    }
    if (token.length > 3 &&
        const ['و', 'ف', 'ب', 'ك', 'ل'].any((prefix) =>
            token.startsWith(prefix) && token.substring(1).startsWith('ال'))) {
      return token.substring(1);
    }
    return token;
  }

  static bool _matchesSearch(String text, String query) {
    final rawQuery = query.trim();
    if (rawQuery.isEmpty) return false;

    // Keep phrase search flexible; single-word searches use token boundaries
    // so a substring such as حلم does not match أحلام or حليم.
    if (rawQuery.contains(RegExp(r'\s'))) {
      final queryTokens = normalizeSearchText(rawQuery)
          .split(RegExp(r'[^ء-يٱ]+'))
          .where((token) => token.isNotEmpty)
          .toList(growable: false);
      final textTokens = normalizeSearchText(text)
          .split(RegExp(r'[^ء-يٱ]+'))
          .where((token) => token.isNotEmpty)
          .toList(growable: false);
      if (queryTokens.isEmpty || queryTokens.length > textTokens.length) {
        return false;
      }
      for (var start = 0; start <= textTokens.length - queryTokens.length; start++) {
        var matches = true;
        for (var offset = 0; offset < queryTokens.length; offset++) {
          if (textTokens[start + offset] != queryTokens[offset]) {
            matches = false;
            break;
          }
        }
        if (matches) return true;
      }
      return false;
    }

    final needle = _normalizeSearchToken(rawQuery);
    if (needle.isEmpty) return false;
    final withoutArticle =
        needle.startsWith('ال') && needle.length > 2 ? needle.substring(2) : needle;
    final tokens = _normalizeSearchToken(text)
        .split(RegExp(r'[^ء-يٱ]+'))
        .where((token) => token.isNotEmpty);

    for (final token in tokens) {
      final lexical = _stripAttachedArticlePrefix(token);
      if (lexical == needle || lexical == withoutArticle) return true;
      if (lexical.startsWith('ال') && lexical.substring(2) == needle) return true;
    }
    return false;
  }

  Future<List<Verse>> search(String query, {int limit = 20}) async {
    final needle = query.trim();
    if (needle.isEmpty || limit <= 0) return const <Verse>[];

    final ayahs = await QuranLoaderService.loadAllAyahs();

    // Prefer actual verse-text matches. Matching the surah title in the same
    // predicate used to return every ayah of a surah when only one or two
    // verses contained the requested word (for example, "الطلاق").
    final textMatches = ayahs
        .where((ayah) => _matchesSearch(ayah.text, needle))
        .toList(growable: false);
    if (textMatches.isNotEmpty) {
      return textMatches.take(limit).toList(growable: false);
    }

    // Preserve title-based navigation as a fallback for queries that do not
    // occur in any verse text.
    return ayahs
        .where((ayah) => _matchesSearch(ayah.surahName, needle))
        .take(limit)
        .toList(growable: false);
  }

  static const List<int> _verseCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6
  ];

  /// Complete 114-surah index. Names and page starts come from the same
  /// QCF source used by the canonical 604-page Mushaf.
  static List<Surah> getSurahs() => List<Surah>.generate(114, (index) {
    final number = index + 1;
    return Surah(
      number: number,
      nameArabic: getSurahNameArabic(number),
      nameEnglish: '',
      verseCount: _verseCounts[index],
      revelationType: '',
      pageNumber: getPageNumber(number, 1).clamp(1, 604).toInt(),
    );
  }, growable: false);
}
