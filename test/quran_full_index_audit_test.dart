import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/domain/entities/verse.dart';
import 'package:mudabbir_al_asrar/services/mushaf_source.dart';
import 'package:mudabbir_al_asrar/services/quran_loader_service.dart';
import 'package:mudabbir_al_asrar/services/quran_word_index_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => QuranWordIndexService.clearCacheForTesting());

  group('Full Quran word-index audit', () {
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
        expect(letter.abjadValue, inInclusiveRange(0, 1000));
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
