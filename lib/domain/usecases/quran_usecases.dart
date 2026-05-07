import '../entities/verse.dart';
import '../repositories/quran_repository.dart';

class GetAllSurahsUseCase {
  final QuranRepository repository;

  GetAllSurahsUseCase(this.repository);

  Future<List<Surah>> call() async {
    return await repository.getAllSurahs();
  }
}

class GetSurahUseCase {
  final QuranRepository repository;

  GetSurahUseCase(this.repository);

  Future<Surah> call(int number) async {
    return await repository.getSurah(number);
  }
}

class SearchVersesUseCase {
  final QuranRepository repository;

  SearchVersesUseCase(this.repository);

  Future<List<Verse>> call(String query) async {
    return await repository.searchVerses(query);
  }
}

class GetJuzUseCase {
  final QuranRepository repository;

  GetJuzUseCase(this.repository);

  Future<Juz> call(int number) async {
    return await repository.getJuz(number);
  }
}

class GetVersesByJuzUseCase {
  final QuranRepository repository;

  GetVersesByJuzUseCase(this.repository);

  Future<List<Verse>> call(int juzNumber) async {
    return await repository.getVersesByJuz(juzNumber);
  }
}