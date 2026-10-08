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
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ٱ': 1,
    'ب': 2, 'ج': 3, 'د': 4, 'ه': 5, 'ة': 5, 'و': 6, 'ز': 7,
    'ح': 8, 'ط': 9, 'ي': 10, 'ى': 10, 'ك': 20, 'ل': 30,
    'م': 40, 'ن': 50, 'س': 60, 'ع': 70, 'ف': 80, 'ص': 90,
    'ق': 100, 'ر': 200, 'ش': 300, 'ت': 400, 'ث': 500,
    'خ': 600, 'ذ': 700, 'ض': 800, 'ظ': 900, 'غ': 1000,
  };

  static String normalize(String value) => value
      .replaceAll(_marks, '')
      .replaceAll('ـ', '')
      .replaceAll(RegExp(r'[۞۩﴿﴾]'), '')
      .replaceAll('ٱ', 'ا')
      .replaceAll(RegExp(r'[أإآ]'), 'ا')
      .replaceAll('ى', 'ي')
      .trim();

  static List<String> _lettersIn(String value) => normalize(value)
      .split('')
      .where((character) => _arabicLetters.hasMatch(character))
      .toList(growable: false);

  static Future<List<QuranWordEntry>> loadWords() async {
    final cached = _cachedWords;
    if (cached != null) return cached;

    final ayahs = await QuranLoaderService.loadAllAyahs();
    final words = <QuranWordEntry>[];
    for (final Ayah ayah in ayahs) {
      final page = MushafSource.pageForVerse(ayah.surahNumber, ayah.ayahNumber);
      final juz = MushafSource.juzForPage(page);
      final tokens = ayah.text
          .split(RegExp(r'\s+'))
          .map((token) => token.trim())
          .where((token) => _lettersIn(token).isNotEmpty)
          .toList(growable: false);

      for (var index = 0; index < tokens.length; index++) {
        final token = tokens[index];
        words.add(QuranWordEntry(
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
          wordNumber: index + 1,
          text: token,
          normalized: normalize(token),
          pageNumber: page,
          juzNumber: juz,
        ));
      }
    }

    _cachedWords = List<QuranWordEntry>.unmodifiable(words);
    return _cachedWords!;
  }

  static Future<List<QuranWordEntry>> searchWords(String query) async {
    final needle = normalize(query);
    if (needle.isEmpty) return const <QuranWordEntry>[];
    final words = await loadWords();
    return words.where((word) => word.normalized == needle).toList(
          growable: false,
        );
  }

  static Future<List<QuranWordEntry>> wordsForVerse(
    int surahNumber,
    int ayahNumber,
  ) async {
    final words = await loadWords();
    return words
        .where((word) =>
            word.surahNumber == surahNumber && word.ayahNumber == ayahNumber)
        .toList(growable: false);
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
    final letters = await loadLetters();
    return letters
        .where((letter) =>
            letter.surahNumber == surahNumber &&
            letter.ayahNumber == ayahNumber)
        .toList(growable: false);
  }

  /// Test and diagnostic hook for deterministic index rebuilding.
  static void clearCacheForTesting() {
    _cachedWords = null;
    _cachedLetters = null;
  }
}
