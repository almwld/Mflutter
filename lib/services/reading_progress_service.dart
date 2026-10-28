import 'package:shared_preferences/shared_preferences.dart';

/// حفظ موضع القراءة وإحصاءات الختمة محلياً.
class ReadingProgressService {
  static const _pageKey = 'quran.last_page';
  static const _pagesReadKey = 'quran.pages_read';
  static const _readingDaysKey = 'quran.reading_days';
  static const int _firstPage = 1;
  static const int _lastPage = 604;
  static Future<void> _saveQueue = Future<void>.value();

  static Future<int> getLastPage({int fallback = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_pageKey) ?? fallback)
        .clamp(_firstPage, _lastPage)
        .toInt();
  }

  static Future<void> saveLastPage(int page) {
    final normalizedPage = page.clamp(_firstPage, _lastPage).toInt();
    // Serialize all reader writes, not just writes from one PageView instance.
    // This prevents an older slow preference write from replacing a newer page
    // when the user swipes quickly or switches between reader modes.
    _saveQueue = _saveQueue.then((_) => _savePageAndActivity(normalizedPage));
    return _saveQueue;
  }

  static Future<void> _savePageAndActivity(int normalizedPage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pageKey, normalizedPage);

    final pages = _readValidPages(
      prefs.getStringList(_pagesReadKey) ?? const <String>[],
    );
    if (pages.add(normalizedPage)) {
      final sorted = pages.toList()..sort();
      await prefs.setStringList(
        _pagesReadKey,
        sorted.map((value) => value.toString()).toList(growable: false),
      );
    } else {
      // Clean up legacy invalid entries and duplicates while preserving
      // previously recorded valid pages.
      final stored = prefs.getStringList(_pagesReadKey) ?? const <String>[];
      final normalized = pages.toList()..sort();
      final canonical = normalized.map((value) => value.toString()).toList();
      if (!_sameStrings(stored, canonical)) {
        await prefs.setStringList(_pagesReadKey, canonical);
      }
    }

    final days = prefs.getStringList(_readingDaysKey) ?? <String>[];
    final today = _dateKey(DateTime.now());
    if (!days.contains(today)) {
      days.add(today);
      await prefs.setStringList(_readingDaysKey, days);
    }
  }

  static Future<double> getKhatmahProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final pages = _readValidPages(
      prefs.getStringList(_pagesReadKey) ?? const <String>[],
    );
    return (pages.length / _lastPage).clamp(0.0, 1.0).toDouble();
  }

  static Future<int> getPagesRead() async {
    final prefs = await SharedPreferences.getInstance();
    return _readValidPages(
      prefs.getStringList(_pagesReadKey) ?? const <String>[],
    ).length;
  }

  static Set<int> _readValidPages(List<String> values) {
    final pages = <int>{};
    for (final value in values) {
      final page = int.tryParse(value);
      if (page != null && page >= _firstPage && page <= _lastPage) {
        pages.add(page);
      }
    }
    return pages;
  }

  static bool _sameStrings(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }

  static Future<int> getReadingDays() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_readingDaysKey) ?? const <String>[]).length;
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final days = (prefs.getStringList(_readingDaysKey) ?? const <String>[]).toSet();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Keep yesterday's streak alive until the user either reads today or
    // misses a full calendar day, matching the persistent DailyStreakService.
    var cursor = days.contains(_dateKey(today))
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;

    while (days.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Number of distinct reading days in the last seven calendar days.
  static Future<int> getPagesReadInLast7Days() async {
    final prefs = await SharedPreferences.getInstance();
    final days = (prefs.getStringList(_readingDaysKey) ?? const <String>[]).toSet();
    var count = 0;
    for (var i = 0; i < 7; i++) {
      if (days.contains(_dateKey(DateTime.now().subtract(Duration(days: i))))) {
        count++;
      }
    }
    return count;
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
