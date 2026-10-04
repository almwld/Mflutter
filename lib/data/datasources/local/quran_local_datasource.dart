import '../../../domain/models/quran_models.dart';
import 'database_helper.dart';

class QuranLocalDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Map<String, List<Map<String, dynamic>>> _versesCache = {};

  Future<Surah> getSurah(int number) async {
    final values = await getAllSurahs();
    final row = values.cast<Map<String, dynamic>>().firstWhere((item) => (item['surah'] as num?)?.toInt() == number, orElse: () => throw StateError('السورة غير موجودة: $number'));
    final verses = await getVersesBySurah(number);
    return Surah(number: number, nameArabic: (row['surah_name'] ?? '').toString(), nameEnglish: '', verseCount: verses.length, revelationType: '', pageNumber: 0);
  }

  Future<List<Surah>> getSurahs() async {
    final rows = await getAllSurahs();
    final result = <Surah>[];
    for (final row in rows) {
      final number = (row['surah'] as num?)?.toInt() ?? 0;
      if (number <= 0) continue;
      final verses = await getVersesBySurah(number);
      result.add(Surah(number: number, nameArabic: (row['surah_name'] ?? '').toString(), nameEnglish: '', verseCount: verses.length, revelationType: '', pageNumber: 0));
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getVerses(int surahNumber) => getVersesBySurah(surahNumber);

  Future<List<Map<String, dynamic>>> getVersesByJuz(int juzNumber) async {
    final db = await _dbHelper.database;
    try {
      return await db.query('verses', where: 'juz = ?', whereArgs: [juzNumber], orderBy: 'surah ASC, ayah ASC');
    } catch (_) {
      return const [];
    }
  }

  Future<List<Juz>> getAllJuzs() async => const [];
  Future<Juz> getJuz(int number) async => Juz(number: number);

  Future<List<Map<String, dynamic>>> getVersesBySurah(int surahNumber) async {
    final key = surahNumber.toString();
    if (_versesCache.containsKey(key)) {
      return _versesCache[key]!;
    }

    final db = await _dbHelper.database;
    final verses = await db.query(
      'verses',
      where: 'surah = ?',
      whereArgs: [surahNumber],
      orderBy: 'ayah ASC',
    );

    _versesCache[key] = verses;
    return verses;
  }

  Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    final db = await _dbHelper.database;
    return await db.query(
      'verses',
      where: 'text_simple LIKE ?',
      whereArgs: ['%$query%'],
      limit: 50,
    );
  }

  Future<Map<String, dynamic>?> getVerse(int surah, int ayah) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'verses',
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, ayah],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllSurahs() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('SELECT DISTINCT surah, surah_name FROM verses ORDER BY surah');
  }
}
