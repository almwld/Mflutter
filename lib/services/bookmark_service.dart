import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const _key = 'bookmarks';

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null || data.trim().isEmpty) return <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(data);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) =>
              item['surah'] is num &&
              item['ayah'] is num &&
              item['text'] is String)
          .toList(growable: true);
    } on FormatException {
      // A corrupted preference must not crash the Quran reader.
      return <Map<String, dynamic>>[];
    } on TypeError {
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> addBookmark(int surah, int ayah, String text) async {
    if (surah < 1 || surah > 114 || ayah < 1) {
      throw ArgumentError('مرجع الآية غير صالح: $surah:$ayah');
    }

    final bookmarks = await getBookmarks();
    bookmarks.removeWhere(
      (item) => (item['surah'] as num).toInt() == surah &&
          (item['ayah'] as num).toInt() == ayah,
    );
    final preview = text.length > 100 ? text.substring(0, 100) : text;
    bookmarks.insert(0, {
      'surah': surah,
      'ayah': ayah,
      'text': preview,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(bookmarks));
  }

  static Future<void> removeBookmark(int surah, int ayah) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere(
      (item) => (item['surah'] as num).toInt() == surah &&
          (item['ayah'] as num).toInt() == ayah,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(bookmarks));
  }

  static Future<bool> isBookmarked(int surah, int ayah) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any(
      (item) => (item['surah'] as num).toInt() == surah &&
          (item['ayah'] as num).toInt() == ayah,
    );
  }
}
