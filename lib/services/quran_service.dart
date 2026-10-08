import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart' show getSurahNameArabic, getPageNumber;
import '../domain/models/quran_models.dart';
import '../domain/entities/verse.dart';
import 'quran_loader_service.dart';

class QuranService {
  static Map<String, dynamic>? _cachedQuran;

  static Future<Map<String, dynamic>> loadQuran() async {
    final cached = _cachedQuran;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/unified_quran.json');
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('صيغة unified_quran.json غير صحيحة: المتوقع كائن السور');
    }

    final quran = Map<String, dynamic>.from(decoded);
    var verseCount = 0;
    for (var surah = 1; surah <= 114; surah++) {
      final verses = quran['$surah'];
      if (verses is! List || verses.isEmpty) {
        throw FormatException('بيانات السورة $surah مفقودة أو فارغة في unified_quran.json');
      }
      for (var index = 0; index < verses.length; index++) {
        final verse = verses[index];
        if (verse is! Map || verse['text'] is! String || (verse['text'] as String).trim().isEmpty) {
          throw FormatException('نص الآية $surah:${index + 1} مفقود أو غير صالح');
        }
        verseCount++;
      }
    }

    if (verseCount != 6236) {
      throw FormatException(
        'عدد الآيات في unified_quran.json غير صحيح: المتوقع 6236، والموجود $verseCount',
      );
    }

    _cachedQuran = quran;
    return quran;
  }

  /// Normalizes common Arabic orthographic variants without relying on a
  /// String.normalize API that Dart does not provide.
  static String normalizeSearchText(String value) {
    return value
        .replaceAll(
          RegExp(r'[ًٌٍَُِّْٰۖۗۘۙۚۛۜ۞ۣ۟۠ۡۢۤۥۦۧۨ۩۪ۭ۫۬]'),
          '',
        )
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[ٱأإآٲٳٵٶٷ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .toLowerCase()
        .trim();
  }

  static bool _matchesSearch(String text, String query) {
    final haystack = normalizeSearchText(text);
    final needle = normalizeSearchText(query);
    if (needle.isEmpty) return false;
    if (haystack.contains(needle)) return true;

    // Arabic search should tolerate an optional definite article.
    if (needle.startsWith('ال') && needle.length > 2) {
      return haystack.contains(needle.substring(2));
    }
    return haystack.contains('ال$needle');
  }

  Future<List<Verse>> search(String query, {int limit = 20}) async {
    final needle = query.trim();
    if (needle.isEmpty || limit <= 0) return const <Verse>[];

    final ayahs = await QuranLoaderService.loadAllAyahs();
    return ayahs
        .where((a) =>
            _matchesSearch(a.text, needle) ||
            _matchesSearch(a.surahName, needle))
        .take(limit)
        .toList();
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
