import 'package:shared_preferences/shared_preferences.dart';

/// حفظ موضع القراءة وإحصاءات الختمة محلياً.
class ReadingProgressService {
  static const _pageKey = 'quran.last_page';
  static const _pagesReadKey = 'quran.pages_read';
  static const _readingDaysKey = 'quran.reading_days';
  static const int _firstPage = 1;
  static const int _lastPage = 604;
  static Future<void> _saveQueue = Future<void>.value();

  static Future<void> _awaitPendingWrites() async {
    await _saveQueue.catchError((Object _) {});
  }

  static Future<int> getLastPage({int fallback = 1}) async {
    await _awaitPendingWrites();
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_pageKey) ?? fallback)
        .clamp(_firstPage, _lastPage)
        .toInt();
  }

  static Future<void> saveLastPage(int page) {
    final normalizedPage = page.clamp(_firstPage, _lastPage).toInt();
    // Serialize reader writes so a delayed older write cannot replace a newer page.
    _saveQueue = _saveQueue
        .catchError((Object _) {})
        .then((_) => _savePageAndActivity(normalizedPage));
    return _saveQueue;
  }

  static Future<void> _savePageAndActivity(int normalizedPage) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setInt(_pageKey, normalizedPage)) {
      throw StateError('تعذر حفظ موضع القراءة محليًا.');
    }

    final storedPages = prefs.getStringList(_pagesReadKey) ?? const <String>[];
    final pages = _readValidPages(storedPages);
    pages.add(normalizedPage);
    final sortedPages = pages.toList()..sort();
    final canonicalPages = sortedPages.map((value) => value.toString()).toList();
    if (!_sameStrings(storedPages, canonicalPages)) {
      if (!await prefs.setStringList(_pagesReadKey, canonicalPages)) {
        throw StateError('تعذر تحديث صفحات القراءة المحفوظة.');
      }
    }

    final storedDays =
        prefs.getStringList(_readingDaysKey) ?? const <String>[];
    final days = _readValidDays(storedDays);
    days.add(_dateKey(DateTime.now()));
    final sortedDays = days.toList()..sort();
    if (!_sameStrings(storedDays, sortedDays)) {
      if (!await prefs.setStringList(_readingDaysKey, sortedDays)) {
        throw StateError('تعذر حفظ يوم القراءة محليًا.');
      }
    }
  }

  static Future<double> getKhatmahProgress() async {
    await _awaitPendingWrites();
    final prefs = await SharedPreferences.getInstance();
    final pages = _readValidPages(
      prefs.getStringList(_pagesReadKey) ?? const <String>[],
    );
    return (pages.length / _lastPage).clamp(0.0, 1.0).toDouble();
  }

  static Future<int> getPagesRead() async {
    await _awaitPendingWrites();
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

  static Set<String> _readValidDays(List<String> values) {
    final days = <String>{};
    for (final value in values) {
      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) continue;
      final parsed = DateTime.tryParse(value);
      if (parsed == null || _dateKey(parsed) != value) continue;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (parsed.isAfter(today)) continue;
      days.add(value);
    }
    return days;
  }

  static bool _sameStrings(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }

  static Future<int> getReadingDays() async {
    await _awaitPendingWrites();
    final prefs = await SharedPreferences.getInstance();
    return _readValidDays(
      prefs.getStringList(_readingDaysKey) ?? const <String>[],
    ).length;
  }

  static Future<int> getCurrentStreak() async {
    await _awaitPendingWrites();
    final prefs = await SharedPreferences.getInstance();
    final days = _readValidDays(
      prefs.getStringList(_readingDaysKey) ?? const <String>[],
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
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
  static Future<int> getReadingDaysInLast7Days() async {
    await _awaitPendingWrites();
    final prefs = await SharedPreferences.getInstance();
    final days = _readValidDays(
      prefs.getStringList(_readingDaysKey) ?? const <String>[],
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var count = 0;
    for (var offset = 0; offset < 7; offset++) {
      if (days.contains(_dateKey(today.subtract(Duration(days: offset))))) {
        count++;
      }
    }
    return count;
  }

  static Future<List<bool>> getReadingWeekHistory() async {
    await _awaitPendingWrites();
    final prefs = await SharedPreferences.getInstance();
    final days = _readValidDays(
      prefs.getStringList(_readingDaysKey) ?? const <String>[],
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List<bool>.unmodifiable(
      List<bool>.generate(
        7,
        (index) => days.contains(
          _dateKey(today.subtract(Duration(days: 6 - index))),
        ),
      ),
    );
  }

  /// Compatibility alias retained for existing callers. The value is a count
  /// of distinct reading days, not pages read.
  @Deprecated('Use getReadingDaysInLast7Days; this returns days, not pages.')
  static Future<int> getPagesReadInLast7Days() =>
      getReadingDaysInLast7Days();

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
