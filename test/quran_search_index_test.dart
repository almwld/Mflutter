import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/quran_service.dart';
import 'package:mudabbir_al_asrar/services/quran_word_index_service.dart';
import 'package:mudabbir_al_asrar/services/mushaf_source.dart';
import 'package:mudabbir_al_asrar/services/quranic_search_engine.dart';

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
    expect(
      results.map((verse) => '${verse.surahNumber}:${verse.ayahNumber}').toSet(),
      <String>{'2:227', '2:229'},
      reason: 'Verse text matches must take priority over the surah title.',
    );
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

  test('surah-title lookup is used only when verse text has no match', () async {
    final results = await QuranService().search('الفاتحة', limit: 20);
    expect(results, hasLength(7));
    expect(results.every((verse) => verse.surahNumber == 1), isTrue);
  });


  test('Quranic search index rebuilds when canonical verse content changes', () {
    QuranicSearchEngine.indexVerses(const [
      {'id': '1', 'surah': 'الفاتحة', 'ayah': '1', 'text': 'النور'},
    ]);
    expect(QuranicSearchEngine.search('النور'), isNotEmpty);

    QuranicSearchEngine.indexVerses(const [
      {'id': '1', 'surah': 'الفاتحة', 'ayah': '1', 'text': 'الرحمة'},
    ]);
    expect(QuranicSearchEngine.search('النور'), isEmpty);
    expect(QuranicSearchEngine.search('الرحمة'), isNotEmpty);
  });

  test('exact word counts report real occurrences and unique numeric verse references', () {
    QuranicSearchEngine.indexVerses(const [
      {
        'id': '1',
        'surah': 'الفاتحة',
        'surah_number': '1',
        'ayah': '1',
        'text': 'نور نور منير',
      },
      {
        'id': '2',
        'surah': 'البقرة',
        'surah_number': '2',
        'ayah': '3',
        'text': 'نور',
      },
    ]);

    final result = QuranicSearchEngine.countExactWord('نور');
    expect(result, isNotNull);
    expect(result!.occurrenceCount, 3);
    expect(result.ayahReferences, <String>['1:1', '2:3']);
    expect(QuranicSearchEngine.countExactWord('منور')!.occurrenceCount, 0);
    expect(QuranicSearchEngine.countExactWord('نور نور'), isNull);
  });

  test('search normalization removes Quranic tashkeel without changing source text', () {
    const source = 'الرَّحْمَٰنِ';
    QuranicSearchEngine.indexVerses(const [
      {'id': '1', 'surah': 'الفاتحة', 'ayah': '1', 'text': source},
    ]);

    expect(QuranicSearchEngine.normalize(source), 'الرحمن');
    final results = QuranicSearchEngine.search('الرحمن');
    expect(results, hasLength(1));
    expect(results.single['text'], source);
  });

  test('search uses cached unique verses and root search preserves verse order', () {
    QuranicSearchEngine.indexVerses(const [
      {'id': '1', 'surah': 'البقرة', 'ayah': '1', 'text': 'نور ورحمة'},
      {'id': '2', 'surah': 'البقرة', 'ayah': '2', 'text': 'نور وهدى'},
      {'id': '2', 'surah': 'البقرة', 'ayah': '2', 'text': 'نور وهدى'},
    ]);

    expect(QuranicSearchEngine.search('نور'), hasLength(2));
    expect(
      QuranicSearchEngine.searchByRoot('هدى').map((verse) => verse['ayah']),
      ['2'],
    );
  });

  test('Mushaf source uses canonical 604-page, 30-juz, 60-hizb metadata', () {
    expect(MushafSource.totalPages, 604);
    expect(MushafSource.totalJuz, 30);
    expect(MushafSource.totalHizb, 60);
    expect(MushafSource.totalSurahs, 114);
    expect(MushafSource.normalizePage(0), 1);
    expect(MushafSource.normalizePage(605), 604);
    expect(MushafSource.pageForVerse(1, 1), 1);
    expect(MushafSource.pageForVerse(114, 6), 604);
  });
}
