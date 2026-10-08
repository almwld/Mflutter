import 'package:flutter/services.dart';
import '../domain/models/quran_models.dart';
import '../domain/entities/verse.dart';
import 'quran_loader_service.dart';

class QuranService {
  static Map<String, dynamic>? _cachedQuran;

  static Future<Map<String, dynamic>> loadQuran() async {
    if (_cachedQuran != null) return _cachedQuran!;
    final raw = await rootBundle.loadString('assets/unified_quran.json');
    final decoded = <String, dynamic>{'raw': raw};
    _cachedQuran = decoded;
    return decoded;
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

  static List<Surah> getSurahs() => const [
        Surah(number: 1, nameArabic: 'الفاتحة', nameEnglish: 'Al-Fatiha', verseCount: 7, revelationType: 'مكية', pageNumber: 1),
        Surah(number: 2, nameArabic: 'البقرة', nameEnglish: 'Al-Baqarah', verseCount: 286, revelationType: 'مدنية', pageNumber: 2),
        Surah(number: 3, nameArabic: 'آل عمران', nameEnglish: 'Aal-E-Imran', verseCount: 200, revelationType: 'مدنية', pageNumber: 50),
        Surah(number: 4, nameArabic: 'النساء', nameEnglish: 'An-Nisa', verseCount: 176, revelationType: 'مدنية', pageNumber: 77),
        Surah(number: 5, nameArabic: 'المائدة', nameEnglish: 'Al-Maidah', verseCount: 120, revelationType: 'مدنية', pageNumber: 106),
        Surah(number: 36, nameArabic: 'يس', nameEnglish: 'Ya-Sin', verseCount: 83, revelationType: 'مكية', pageNumber: 440),
        Surah(number: 55, nameArabic: 'الرحمن', nameEnglish: 'Ar-Rahman', verseCount: 78, revelationType: 'مدنية', pageNumber: 531),
        Surah(number: 67, nameArabic: 'الملك', nameEnglish: 'Al-Mulk', verseCount: 30, revelationType: 'مكية', pageNumber: 562),
        Surah(number: 112, nameArabic: 'الإخلاص', nameEnglish: 'Al-Ikhlas', verseCount: 4, revelationType: 'مكية', pageNumber: 604),
        Surah(number: 113, nameArabic: 'الفلق', nameEnglish: 'Al-Falaq', verseCount: 5, revelationType: 'مكية', pageNumber: 604),
        Surah(number: 114, nameArabic: 'الناس', nameEnglish: 'An-Nas', verseCount: 6, revelationType: 'مكية', pageNumber: 604),
      ];
}
