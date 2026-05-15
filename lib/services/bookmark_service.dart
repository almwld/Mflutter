class BookmarkService {
  static final List<Map<String, dynamic>> _bookmarks = [];

  static void addBookmark(Map<String, dynamic> verse) {
    if (!_bookmarks.any((b) => b['surah'] == verse['surah'] && b['ayah'] == verse['ayah'])) {
      _bookmarks.add(verse);
    }
  }

  static void removeBookmark(int surah, int ayah) {
    _bookmarks.removeWhere((b) => b['surah'] == surah && b['ayah'] == ayah);
  }

  static bool isBookmarked(int surah, int ayah) {
    return _bookmarks.any((b) => b['surah'] == surah && b['ayah'] == ayah);
  }

  static List<Map<String, dynamic>> getBookmarks() => List.from(_bookmarks);

  static String exportBookmarks() {
    return _bookmarks.map((b) => '${b['surah']}:${b['ayah']} - ${b['text']}').join('\n');
  }
}
