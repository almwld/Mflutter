import '../domain/entities/verse.dart';
import 'mushaf_source.dart';
import 'quran_loader_service.dart';

/// A location-aware token in the canonical Hafs Quran text.
///
/// The original token is preserved for display; normalized text is only used
/// for lookup and must never replace the Mushaf text shown to readers.
class QuranWordEntry {
  final int surahNumber;
  final int ayahNumber;
  final int wordNumber;
  final String text;
  final String normalized;
  final int pageNumber;
  final int juzNumber;

  const QuranWordEntry({
    required this.surahNumber,
    required this.ayahNumber,
    required this.wordNumber,
    required this.text,
    required this.normalized,
    required this.pageNumber,
    required this.juzNumber,
  });
}

/// Position of an Arabic letter after Quranic marks and stop signs are omitted.
/// Character offsets are within the normalized Arabic-letter sequence of the
/// word, not byte offsets in the UTF-8 source.
class QuranLetterEntry {
  final int surahNumber;
  final int ayahNumber;
  final int wordNumber;
  final int letterNumber;
  final String letter;
  final int abjadValue;
  final int pageNumber;
  final int juzNumber;

  const QuranLetterEntry({
    required this.surahNumber,
    required this.ayahNumber,
    required this.wordNumber,
    required this.letterNumber,
    required this.letter,
    required this.abjadValue,
    required this.pageNumber,
    required this.juzNumber,
  });
}

/// Builds an in-memory word/letter index from the bundled Quran source.
///
/// No counts, locations, esoteric correspondences, or word occurrences are
/// hard-coded: each result is derived from the actual bundled verse text.
class QuranWordIndexService {
  static List<QuranWordEntry>? _cachedWords;
  static List<QuranLetterEntry>? _cachedLetters;

  static final RegExp _marks = RegExp(
    r'[\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF]',
  );
  static final RegExp _arabicLetters = RegExp(r'[ء-يٱ]');
  static const Map<String, int> _abjad = {
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ٱ': 1, 'ء': 1,
    'ب': 2, 'ج': 3, 'د': 4, 'ه': 5, 'ة': 5, 'و': 6, 'ؤ': 6, 'ز': 7,
    'ح': 8, 'ط': 9, 'ي': 10, 'ى': 10, 'ئ': 10, 'ك': 20, 'ل': 30,
    'م': 40, 'ن': 50, 'س': 60, 'ع': 70, 'ف': 80, 'ص': 90,
    'ق': 100, 'ر': 200, 'ش': 300, 'ت': 400, 'ث': 500,
    'خ': 600, 'ذ': 700, 'ض': 800, 'ظ': 900, 'غ': 1000,
  };

  static String normalize(String value) => value
      // Dagger alif is a Quranic orthographic sign for an alif, not a vowel to discard.
      .replaceAll('ٰ', 'ا')
      .replaceAll(_marks, '')
      .replaceAll('ـ', '')
      .replaceAll(RegExp(r'[۞۩﴿﴾]'), '')
      .replaceAll('ٱ', 'ا')
      .replaceAll(RegExp(r'[أإآ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('العلمين', 'العالمين')
      .replaceAll('الطلق', 'الطلاق')
      .trim();

  static List<String> _lettersIn(String value) => value
      .replaceAll(_marks, '')
      .replaceAll('ـ', '')
      .split('')
      .where((character) => _arabicLetters.hasMatch(character))
      .toList(growable: false);

  static Future<List<QuranWordEntry>> loadWords() async {
    final cached = _cachedWords;
    if (cached != null) return cached;

    final ayahs = await QuranLoaderService.loadAllAyahs();
    final words = <QuranWordEntry>[];
    for (final Ayah ayah in ayahs) {
      words.addAll(_wordsForAyah(ayah));
    }

    _cachedWords = List<QuranWordEntry>.unmodifiable(words);
    return _cachedWords!;
  }

  static List<QuranWordEntry> _wordsForAyah(Ayah ayah) {
    final page = MushafSource.pageForVerse(ayah.surahNumber, ayah.ayahNumber);
    final juz = MushafSource.juzForPage(page);
    final tokens = ayah.text
        .split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => _lettersIn(token).isNotEmpty)
        .toList(growable: false);

    return List<QuranWordEntry>.generate(tokens.length, (index) {
      final token = tokens[index];
      return QuranWordEntry(
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        wordNumber: index + 1,
        text: token,
        normalized: normalize(token),
        pageNumber: page,
        juzNumber: juz,
      );
    }, growable: false);
  }

  static String _stripAttachedArticlePrefixes(String token) {
    if (token.startsWith('لل') && token.length > 2) {
      return 'ال' + token.substring(2);
    }
    if (token.length > 3 &&
        const ['و', 'ف', 'ب', 'ك', 'ل'].any((prefix) =>
            token.startsWith(prefix) && token.substring(1).startsWith('ال'))) {
      return token.substring(1);
    }
    return token;
  }

  static Future<List<QuranWordEntry>> searchWords(String query) async {
    final raw = query.replaceAll(_marks, '').replaceAll('ـ', '').trim();
    final needle = normalize(raw);
    if (needle.isEmpty) return const <QuranWordEntry>[];

    // Allow the definite article to be omitted in a lookup such as "النفقة"
    // while preserving hamza-bearing stems such as "الأذن" to avoid matching
    // the unrelated verb "أذن".
    final hamzaStem = RegExp(r'^ال[أإآ]').hasMatch(raw);
    final candidates = <String>{needle};
    if (!hamzaStem && needle.startsWith('ال') && needle.length > 2) {
      candidates.add(needle.substring(2));
    }

    final words = await loadWords();
    return words.where((word) {
      final token = _stripAttachedArticlePrefixes(word.normalized);
      if (candidates.contains(token)) return true;
      return !hamzaStem &&
          token.startsWith('ال') &&
          candidates.contains(token.substring(2));
    }).toList(growable: false);
  }

  static Future<List<QuranWordEntry>> wordsForVerse(
    int surahNumber,
    int ayahNumber,
  ) async {
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
      return const <QuranWordEntry>[];
    }
    final bySurah = await QuranLoaderService.loadBySurah();
    final verses = bySurah[surahNumber];
    if (verses == null) return const <QuranWordEntry>[];
    for (final ayah in verses) {
      if (ayah.ayahNumber == ayahNumber) return _wordsForAyah(ayah);
    }
    return const <QuranWordEntry>[];
  }

  static Future<List<QuranLetterEntry>> loadLetters() async {
    final cached = _cachedLetters;
    if (cached != null) return cached;

    final words = await loadWords();
    final letters = <QuranLetterEntry>[];
    for (final word in words) {
      final chars = _lettersIn(word.text);
      for (var index = 0; index < chars.length; index++) {
        final character = chars[index];
        letters.add(QuranLetterEntry(
          surahNumber: word.surahNumber,
          ayahNumber: word.ayahNumber,
          wordNumber: word.wordNumber,
          letterNumber: index + 1,
          letter: character,
          abjadValue: _abjad[character] ?? 0,
          pageNumber: word.pageNumber,
          juzNumber: word.juzNumber,
        ));
      }
    }

    _cachedLetters = List<QuranLetterEntry>.unmodifiable(letters);
    return _cachedLetters!;
  }

  static Future<List<QuranLetterEntry>> lettersForVerse(
    int surahNumber,
    int ayahNumber,
  ) async {
    final words = await wordsForVerse(surahNumber, ayahNumber);
    final letters = <QuranLetterEntry>[];
    for (final word in words) {
      final chars = _lettersIn(word.text);
      for (var index = 0; index < chars.length; index++) {
        final character = chars[index];
        letters.add(QuranLetterEntry(
          surahNumber: word.surahNumber,
          ayahNumber: word.ayahNumber,
          wordNumber: word.wordNumber,
          letterNumber: index + 1,
          letter: character,
          abjadValue: _abjad[character] ?? 0,
          pageNumber: word.pageNumber,
          juzNumber: word.juzNumber,
        ));
      }
    }
    return List<QuranLetterEntry>.unmodifiable(letters);
  }

  /// Test and diagnostic hook for deterministic index rebuilding.
  static void clearCacheForTesting() {
    _cachedWords = null;
    _cachedLetters = null;
  }
}
