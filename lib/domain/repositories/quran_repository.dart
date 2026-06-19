import '../entities/verse.dart';

abstract class QuranRepository {
  Future<List<Surah>> getAllSurahs();
  Future<Surah> getSurah(int number);
  Future<List<Verse>> getVerses(int surahNumber);
  Future<List<Verse>> searchVerses(String query);
  Future<List<Juz>> getAllJuzs();
  Future<Juz> getJuz(int number);
  Future<List<Verse>> getVersesByJuz(int juzNumber);
}