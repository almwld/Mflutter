import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookmarkService {
  static const _key = 'bookmarks';

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  static Future<void> addBookmark(int surah, int ayah, String text) async {
    final bookmarks = await getBookmarks();
    bookmarks.insert(0, {'surah': surah, 'ayah': ayah, 'text': text.substring(0, 100)});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(bookmarks));
  }

  static Future<void> removeBookmark(int surah, int ayah) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere((b) => b['surah'] == surah && b['ayah'] == ayah);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(bookmarks));
  }

  static Future<bool> isBookmarked(int surah, int ayah) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((b) => b['surah'] == surah && b['ayah'] == ayah);
  }
}
