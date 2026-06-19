import '../../domain/entities/verse.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/local/quran_local_datasource.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDatasource localDatasource;

  QuranRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Surah>> getAllSurahs() async {
    return await localDatasource.getAllSurahs();
  }

  @override
  Future<Surah> getSurah(int number) async {
    return await localDatasource.getSurah(number);
  }

  @override
  Future<List<Verse>> getVerses(int surahNumber) async {
    return await localDatasource.getVerses(surahNumber);
  }

  @override
  Future<List<Verse>> searchVerses(String query) async {
    return await localDatasource.searchVerses(query);
  }

  @override
  Future<List<Juz>> getAllJuzs() async {
    return await localDatasource.getAllJuzs();
  }

  @override
  Future<Juz> getJuz(int number) async {
    return await localDatasource.getJuz(number);
  }

  @override
  Future<List<Verse>> getVersesByJuz(int juzNumber) async {
    return await localDatasource.getVersesByJuz(juzNumber);
  }
}