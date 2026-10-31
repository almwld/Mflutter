import 'dart:convert';

import 'package:qcf_quran_lite/qcf_quran_lite.dart' show getVerse;
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const _key = 'bookmarks';
  static const int _maxBookmarks = 500;
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
              item['text'] is String &&
              _isValidVerseReference(
                (item['surah'] as num).toInt(),
                (item['ayah'] as num).toInt(),
              ) &&
              (item['text'] as String).trim().isNotEmpty)
          .take(_maxBookmarks)
          .toList(growable: true);
    } on FormatException {
      // A corrupted preference must not crash the Quran reader.
      return <Map<String, dynamic>>[];
    } on TypeError {
      return <Map<String, dynamic>>[];
    }
  }

  static bool _isValidVerseReference(int surah, int ayah) {
    if (surah < 1 || surah > 114 || ayah < 1) return false;
    try {
      return getVerse(surah, ayah, verseEndSymbol: false).trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<void> addBookmark(int surah, int ayah, String text) {
    if (!_isValidVerseReference(surah, ayah)) {
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
    if (bookmarks.length >= _maxBookmarks) {
      throw StateError(
        'بلغت العلامات المرجعية الحد الأقصى ($_maxBookmarks). احذف علامة قبل إضافة أخرى.',
      );
    }
    // Store a canonical verse snippet from the bundled Quran source instead
    // of trusting caller-provided display text as scripture.
    final canonicalText = getVerse(surah, ayah, verseEndSymbol: false).trim();
    final preview = canonicalText.length > 100
        ? canonicalText.substring(0, 100)
        : canonicalText;
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
    // This mutation already runs inside the serialized write queue. Calling
    // getBookmarks() here would await the queue entry currently awaiting this
    // function, deadlocking every remove operation.
    final bookmarks = await _readBookmarks();
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
