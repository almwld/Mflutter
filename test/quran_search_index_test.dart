import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_service.dart';
import 'package:mudabbir_al_asrar/services/quran_loader_service.dart';
import 'package:mudabbir_al_asrar/services/quran_source_corrections.dart';
import 'package:mudabbir_al_asrar/services/quran_word_index_service.dart';
import 'package:mudabbir_al_asrar/services/mushaf_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = <String, List<String>>{
    'القردة': ['2:65', '5:60', '7:166'],
    'الذباب': ['22:73'],
    'اليقطين': ['37:146'],
    'الزقوم': ['37:62', '44:43', '56:52'],
    'الضريع': ['88:6'],
    'السعير': ['22:4', '31:21', '34:12', '35:6', '42:7', '67:5', '67:10', '67:11'],
    'الأذن': ['5:45'],
    'الحلم': ['24:58', '24:59'],
    'نفقة': ['2:270', '9:121'],
    'الطلاق': ['2:227', '2:229'],
    'البعوضة': ['2:26'],
  };

  for (final entry in expected.entries) {
    test('Quran index resolves ' + entry.key, () async {
      final results = await QuranWordIndexService.searchWords(entry.key);
      final refs = results.map((v) => v.surahNumber.toString() + ':' + v.ayahNumber.toString()).toSet().toList();
      final verseSearchResults = await QuranService().search(entry.key, limit: 100);
      final verseSearchRefs = verseSearchResults
          .map((verse) => '${verse.surahNumber}:${verse.ayahNumber}')
          .toSet();
      expect(
        verseSearchRefs,
        entry.value.toSet(),
        reason: 'Verse-level search returned incorrect references for ${entry.key}',
      );
      final diagnosticVerse = entry.key == 'الطلاق'
          ? await QuranWordIndexService.wordsForVerse(2, 227)
          : const <QuranWordEntry>[];
      expect(
        refs,
        entry.value,
        reason: entry.key == 'الطلاق'
            ? diagnosticVerse.map((word) => word.text + '=>' + word.normalized).join('|')
            : '',
      );
      if (entry.key == 'الأذن') expect(results, hasLength(2));
      for (final word in results) {
        expect(word.surahNumber, inInclusiveRange(1, 114));
        expect(word.ayahNumber, greaterThanOrEqualTo(1));
        expect(word.wordNumber, greaterThanOrEqualTo(1));
        expect(word.text, isNotEmpty);
        expect(word.pageNumber, inInclusiveRange(1, 604));
      }
    });
  }


  test('display and search Quran sources match verse text after orthographic normalization', () async {
    final indexedAyahs = await QuranLoaderService.loadAllAyahs();
    final displayQuran = await QuranService.loadQuran();

    for (final ayah in indexedAyahs) {
      final displayVerses = displayQuran['${ayah.surahNumber}'] as List<dynamic>;
      final displayVerse = displayVerses[ayah.ayahNumber - 1] as Map;
      final displayText = displayVerse['text'] as String;
      expect(
        QuranService.normalizeSearchText(displayText),
        QuranService.normalizeSearchText(ayah.text),
        reason: 'Text differs between unified_quran.json and quran_full.json at '
            '${ayah.surahNumber}:${ayah.ayahNumber}. '
            'display="$displayText"; index="${ayah.text}"',
      );
    }
  });

  test('known unified-source spelling defects are corrected only at canonical references', () {
    expect(
      QuranSourceCorrections.correctVerseText(2, 227, 'وإن عزموا ٱلطلق فإن ٱلله سميع عليم'),
      'وإن عزموا ٱلطلاق فإن ٱلله سميع عليم',
    );
    expect(
      QuranSourceCorrections.correctVerseText(2, 229, 'فإن طلقها فلا تحل له'),
      'فإن طلقها فلا تحل له',
    );
    expect(
      QuranSourceCorrections.correctVerseText(2, 228, 'الطلق'),
      'الطلق',
    );
  });

  test('search normalization does not invent letters in a distinct spelling', () {
    expect(QuranService.normalizeSearchText('الطلق'), 'الطلق');
    expect(QuranWordIndexService.normalize('الطلق'), 'الطلق');
    // The actual Uthmani spelling still normalizes correctly without a
    // text-rewriting exception.
    expect(QuranService.normalizeSearchText('ٱلطلاق'), 'الطلاق');
    expect(QuranWordIndexService.normalize('ٱلطلاق'), 'الطلاق');
  });

  test('phrase search resolves the exact Al-Fatiha verse across dagger alif', () async {
    final results = await QuranService().search('الحمد لله رب العالمين', limit: 20);
    final fatihaWords = await QuranWordIndexService.wordsForVerse(1, 2);
    expect(
      results.any((verse) => verse.surahNumber == 1 && verse.ayahNumber == 2),
      isTrue,
      reason: fatihaWords
          .map((word) => word.text + '=>' + word.normalized)
          .join('|'),
    );
  });

  test('canonical Al-Talaq spelling is preserved in both exact verses', () async {
    for (final ayahNumber in <int>[227, 229]) {
      final words = await QuranWordIndexService.wordsForVerse(2, ayahNumber);
      expect(
        words.any((word) =>
            word.normalized == 'الطلاق' && word.text.contains('ٱلطلاق')),
        isTrue,
        reason: 'Expected canonical الطلاق token at 2:$ayahNumber; got '
            '${words.map((word) => word.text).join(' ')}',
      );
    }
    final results = await QuranWordIndexService.searchWords('الطلاق');
    expect(
      results
          .where((word) => word.surahNumber == 2)
          .map((word) => word.ayahNumber)
          .toSet(),
      <int>{227, 229},
    );
  });

  test('search results use canonical Mushaf page and juz coordinates', () async {
    final results = await QuranService().search('الطلاق', limit: 20);
    final target = results.where(
      (verse) => verse.surahNumber == 2 &&
          (verse.ayahNumber == 227 || verse.ayahNumber == 229),
    );
    expect(target.length, 2);
    for (final verse in target) {
      final expectedPage = MushafSource.pageForVerse(
        verse.surahNumber,
        verse.ayahNumber,
      );
      expect(verse.pageNumber, expectedPage);
      expect(verse.juzNumber, MushafSource.juzForPage(expectedPage));
      expect(verse.pageNumber, greaterThan(1));
    }
  });

}
