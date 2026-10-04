import '../../domain/entities/verse.dart';
import '../../domain/models/quran_models.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/local/quran_local_datasource.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDatasource localDatasource;
  QuranRepositoryImpl({required this.localDatasource});

  @override Future<List<Surah>> getAllSurahs() => localDatasource.getSurahs();
  @override Future<Surah> getSurah(int number) => localDatasource.getSurah(number);

  @override
  Future<List<Verse>> getVerses(int surahNumber) async =>
      (await localDatasource.getVerses(surahNumber)).map(Ayah.fromJson).toList();

  @override
  Future<List<Verse>> searchVerses(String query) async =>
      (await localDatasource.searchVerses(query)).map(Ayah.fromJson).toList();

  @override Future<List<Juz>> getAllJuzs() => localDatasource.getAllJuzs();
  @override Future<Juz> getJuz(int number) => localDatasource.getJuz(number);

  @override
  Future<List<Verse>> getVersesByJuz(int juzNumber) async =>
      (await localDatasource.getVersesByJuz(juzNumber)).map(Ayah.fromJson).toList();
}
