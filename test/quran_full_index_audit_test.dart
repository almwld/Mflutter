import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/domain/entities/verse.dart';
import 'package:mudabbir_al_asrar/services/mushaf_source.dart';
import 'package:mudabbir_al_asrar/services/quran_loader_service.dart';
import 'package:mudabbir_al_asrar/services/quran_service.dart';
import 'package:mudabbir_al_asrar/services/quran_word_index_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => QuranWordIndexService.clearCacheForTesting());

  group('Full Quran word-index audit', () {
    test('unified Quran display source has the canonical count for each surah', () async {
      const expectedCounts = <int>[
        7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52,
        99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88,
        69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59,
        37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
        14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31,
        50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21,
        11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4,
        5, 6,
      ];
      final quran = await QuranService.loadQuran();
      expect(quran.keys, containsAll(List<String>.generate(114, (i) => '${i + 1}')));
      for (var surah = 1; surah <= 114; surah++) {
        final verses = quran['$surah'] as List<dynamic>;
        expect(
          verses,
          hasLength(expectedCounts[surah - 1]),
          reason: 'Wrong canonical verse count in unified_quran.json surah $surah',
        );
      }
    });

    test('bundled source follows the canonical 114-surah verse counts and order', () async {
      const expectedCounts = <int>[
        7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52,
        99, 128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88,
        69, 60, 34, 30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59,
        37, 35, 38, 29, 18, 45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13,
        14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20, 56, 40, 31,
        50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21,
        11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3, 6, 3, 5, 4,
        5, 6,
      ];
      final ayahs = await QuranLoaderService.loadAllAyahs();
      expect(expectedCounts, hasLength(114));
      expect(expectedCounts.reduce((sum, count) => sum + count), 6236);
      expect(ayahs, hasLength(6236));

      var sourceIndex = 0;
      for (var surah = 1; surah <= 114; surah++) {
        for (var ayah = 1; ayah <= expectedCounts[surah - 1]; ayah++) {
          final actual = ayahs[sourceIndex++];
          expect(
            '${actual.surahNumber}:${actual.ayahNumber}',
            '$surah:$ayah',
            reason: 'Canonical source order mismatch at row $sourceIndex',
          );
        }
      }
      expect(sourceIndex, ayahs.length);
    });

    test('every canonical verse has indexed words with matching coordinates', () async {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      final words = await QuranWordIndexService.loadWords();

      expect(ayahs, hasLength(6236));
      expect(words, isNotEmpty);

      final verseRefs = ayahs
          .map((Ayah ayah) => '${ayah.surahNumber}:${ayah.ayahNumber}')
          .toSet();
      final indexedRefs = words
          .map((word) => '${word.surahNumber}:${word.ayahNumber}')
          .toSet();

      expect(indexedRefs, verseRefs,
          reason: 'The word index must cover every canonical verse and no unknown verse.');

      for (final word in words) {
        expect(word.surahNumber, inInclusiveRange(1, 114));
        expect(word.ayahNumber, greaterThan(0));
        expect(word.wordNumber, greaterThan(0));
        expect(word.text.trim(), isNotEmpty);
        expect(word.normalized, QuranWordIndexService.normalize(word.text));
        expect(word.pageNumber,
            MushafSource.pageForVerse(word.surahNumber, word.ayahNumber));
        expect(word.juzNumber, MushafSource.juzForPage(word.pageNumber));
      }
    });

    test('word positions are consecutive and preserve source token order', () async {
      final ayahs = await QuranLoaderService.loadAllAyahs();

      for (final ayah in ayahs) {
        final sourceTokens = ayah.text
            .split(RegExp(r'\s+'))
            .map((token) => token.trim())
            .where((token) => RegExp(r'[ء-يٱ]').hasMatch(
                token.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF]'), '')
                    .replaceAll('ـ', '')))
            .toList(growable: false);
        final indexed = await QuranWordIndexService.wordsForVerse(
            ayah.surahNumber, ayah.ayahNumber);

        expect(indexed.map((word) => word.wordNumber).toList(),
            List<int>.generate(indexed.length, (index) => index + 1),
            reason: 'Non-consecutive word positions at ${ayah.surahNumber}:${ayah.ayahNumber}');
        expect(indexed.map((word) => word.text).toList(), sourceTokens,
            reason: 'Indexed word text/order differs from source at ${ayah.surahNumber}:${ayah.ayahNumber}');
      }
    });

    test('letter index positions restart per word and have valid Abjad values', () async {
      final letters = await QuranWordIndexService.loadLetters();
      expect(letters, isNotEmpty);

      final grouped = <String, List<dynamic>>{};
      for (final letter in letters) {
        final key = '${letter.surahNumber}:${letter.ayahNumber}:${letter.wordNumber}';
        grouped.putIfAbsent(key, () => <dynamic>[]).add(letter);
        expect(letter.letterNumber, greaterThan(0));
        expect(letter.letter, isNotEmpty);
        expect(letter.abjadValue, inInclusiveRange(1, 1000),
            reason: 'Missing Abjad mapping for ${letter.letter} at ${letter.surahNumber}:${letter.ayahNumber}');
        expect(letter.pageNumber, inInclusiveRange(1, 604));
        expect(letter.juzNumber, inInclusiveRange(1, 30));
      }

      for (final entries in grouped.values) {
        expect(entries.map((entry) => entry.letterNumber).toList(),
            List<int>.generate(entries.length, (index) => index + 1));
      }
    });
  });
}
