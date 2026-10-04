import 'package:shared_preferences/shared_preferences.dart';

/// حفظ واسترجاع موضع القراءة والتقدم في الختمة.
class ReadingProgressService {
  static const _pageKey = 'quran.last_page';
  static const _pagesReadKey = 'quran.pages_read';

  static Future<int> getLastPage({int fallback = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pageKey) ?? fallback;
  }

  static Future<void> saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pageKey, page);
    final pages = prefs.getStringList(_pagesReadKey) ?? <String>[];
    final value = page.toString();
    if (!pages.contains(value)) {
      pages.add(value);
      await prefs.setStringList(_pagesReadKey, pages);
    }
  }

  static Future<double> getKhatmahProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final pages = prefs.getStringList(_pagesReadKey) ?? const <String>[];
    return (pages.length / 604).clamp(0.0, 1.0);
  }
}
