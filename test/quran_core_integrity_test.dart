import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudabbir_al_asrar/services/bookmark_service.dart';
import 'package:mudabbir_al_asrar/data/datasources/local/quran_local_datasource.dart';
import 'package:mudabbir_al_asrar/data/repositories/repositories_impl.dart';
import 'package:mudabbir_al_asrar/services/quran_loader_service.dart';
import 'package:mudabbir_al_asrar/services/quran_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quran core data integrity', () {
    test('loads exactly 6,236 unique verses across all 114 surahs', () async {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      expect(ayahs, hasLength(6236));

      final refs = ayahs.map((a) => '${a.surahNumber}:${a.ayahNumber}').toSet();
      expect(refs, hasLength(6236));
      expect(ayahs.map((a) => a.surahNumber).toSet(), hasLength(114));
      expect(ayahs.every((a) => a.text.trim().isNotEmpty), isTrue);

      final bySurah = await QuranLoaderService.loadBySurah();
      expect(bySurah.keys.toSet(), Set<int>.from(List<int>.generate(114, (i) => i + 1)));
      expect(bySurah.values.fold<int>(0, (sum, verses) => sum + verses.length), 6236);
    });

    test('repository data source works without an external database file', () async {
      final source = QuranLocalDatasource();
      final surahs = await source.getSurahs();
      expect(surahs, hasLength(114));

      final firstSurah = await source.getSurah(1);
      expect(firstSurah.verseCount, 7);
      final verses = await source.getVersesBySurah(1);
      expect(verses, hasLength(7));
      expect(verses.first['surah'], 1);
      expect(verses.first['ayah'], 1);
      expect(verses.first['text'], isA<String>());

      final juzs = await source.getAllJuzs();
      expect(juzs, hasLength(30));
      expect((await source.getJuz(30)).number, 30);
      expect(await source.getVerse(1, 1), isNotNull);
      expect(await source.getVerse(1, 999), isNull);
      expect(await source.searchVerses('بسم الله'), isNotEmpty);
    });

    test('random and daily verse use the complete bundled index', () async {
      final repository = QuranRepositoryImpl();
      final dailyOne = await repository.getDailyVerse();
      final dailyTwo = await repository.getDailyVerse();
      expect('${dailyOne.surahNumber}:${dailyOne.ayahNumber}',
          '${dailyTwo.surahNumber}:${dailyTwo.ayahNumber}');
      expect(dailyOne.text, isNotEmpty);

      final randomVerse = await repository.getRandomVerse();
      expect(randomVerse.surahNumber, inInclusiveRange(1, 114));
      expect(randomVerse.ayahNumber, greaterThan(0));
      expect(randomVerse.text, isNotEmpty);
    });

    test('unified Quran dataset and surah index are complete', () async {
      final quran = await QuranService.loadQuran();
      expect(quran.keys, containsAll(List<String>.generate(114, (i) => '${i + 1}')));
      expect(
        quran.values.whereType<List<dynamic>>().fold<int>(0, (int sum, List<dynamic> verses) => sum + verses.length),
        6236,
      );

      final surahs = QuranService.getSurahs();
      expect(surahs, hasLength(114));
      expect(surahs.first.nameArabic, isNotEmpty);
      expect(surahs.last.nameArabic, isNotEmpty);
      expect(surahs.fold<int>(0, (sum, surah) => sum + surah.verseCount), 6236);
      expect(surahs.every((surah) => surah.pageNumber >= 1 && surah.pageNumber <= 604), isTrue);
    });
  });

  group('Bookmark persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('accepts short verse text and does not duplicate a reference', () async {
      await BookmarkService.addBookmark(1, 1, 'بسم الله');
      await BookmarkService.addBookmark(1, 1, 'بسم الله الرحمن الرحيم');

      final bookmarks = await BookmarkService.getBookmarks();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single['surah'], 1);
      expect(bookmarks.single['ayah'], 1);
      expect(bookmarks.single['text'], 'بسم الله الرحمن الرحيم');
      expect(await BookmarkService.isBookmarked(1, 1), isTrue);
    });

    test('recovers from malformed stored JSON without crashing', () async {
      SharedPreferences.setMockInitialValues({'bookmarks': '{bad json'});
      expect(await BookmarkService.getBookmarks(), isEmpty);
    });
  });
}
