import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const _key = 'bookmarks';
  static Future<void> _writeQueue = Future<void>.value();

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    // Public reads wait for pending mutations so a new bookmark is visible
    // immediately when the user opens favorites after saving it.
    await _writeQueue.catchError((Object _) {});
    return _readBookmarks();
  }

  static Future<List<Map<String, dynamic>>> _readBookmarks() async {
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

  static Future<void> addBookmark(int surah, int ayah, String text) {
    if (surah < 1 || surah > 114 || ayah < 1) {
      throw ArgumentError('مرجع الآية غير صالح: $surah:$ayah');
    }
    if (text.trim().isEmpty) {
      throw ArgumentError('لا يمكن حفظ علامة مرجعية دون نص آية.');
    }
    return _enqueueWrite(() => _addBookmark(surah, ayah, text));
  }

  static Future<void> _addBookmark(int surah, int ayah, String text) async {
    final bookmarks = await _readBookmarks();
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
    if (!await prefs.setString(_key, jsonEncode(bookmarks))) {
      throw StateError('تعذر حفظ العلامات المرجعية محليًا.');
    }
  }

  static Future<void> removeBookmark(int surah, int ayah) =>
      _enqueueWrite(() => _removeBookmark(surah, ayah));

  static Future<void> _removeBookmark(int surah, int ayah) async {
    final bookmarks = await getBookmarks();
    bookmarks.removeWhere(
      (item) => (item['surah'] as num).toInt() == surah &&
          (item['ayah'] as num).toInt() == ayah,
    );
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_key, jsonEncode(bookmarks))) {
      throw StateError('تعذر تحديث العلامات المرجعية محليًا.');
    }
  }

  static Future<void> _enqueueWrite(Future<void> Function() operation) {
    _writeQueue = _writeQueue
        .catchError((Object _) {})
        .then((_) => operation());
    return _writeQueue;
  }

  static Future<bool> isBookmarked(int surah, int ayah) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any(
      (item) => (item['surah'] as num).toInt() == surah &&
          (item['ayah'] as num).toInt() == ayah,
    );
  }
}
