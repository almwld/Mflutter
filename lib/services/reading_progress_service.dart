import 'package:shared_preferences/shared_preferences.dart';

/// حفظ موضع القراءة وإحصاءات الختمة محلياً.
class ReadingProgressService {
  static const _pageKey = 'quran.last_page';
  static const _pagesReadKey = 'quran.pages_read';
  static const _readingDaysKey = 'quran.reading_days';

  static Future<int> getLastPage({int fallback = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pageKey) ?? fallback;
  }

  static Future<void> saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pageKey, page.clamp(1, 604).toInt());

    final pages = prefs.getStringList(_pagesReadKey) ?? <String>[];
    final value = page.toString();
    if (!pages.contains(value)) {
      pages.add(value);
      await prefs.setStringList(_pagesReadKey, pages);
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
    final pages = prefs.getStringList(_pagesReadKey) ?? const <String>[];
    return (pages.length / 604).clamp(0.0, 1.0);
  }

  static Future<int> getPagesRead() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_pagesReadKey) ?? const <String>[]).length;
  }

  static Future<int> getReadingDays() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_readingDaysKey) ?? const <String>[]).length;
  }

  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final days = (prefs.getStringList(_readingDaysKey) ?? const <String>[]).toSet();
    var cursor = DateTime.now();
    var streak = 0;

    while (days.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

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
