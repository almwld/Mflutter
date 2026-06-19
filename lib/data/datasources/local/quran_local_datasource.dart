import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class QuranLocalDatasource {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Map<String, List<Map<String, dynamic>>> _versesCache = {};

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
