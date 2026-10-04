import 'package:shared_preferences/shared_preferences.dart';

/// يحفظ آخر موضع لمس الآية داخل صفحة المصحف.
/// الإحداثيات مطبّعة بالنسبة إلى مساحة العرض حتى تبقى قابلة لإعادة الاستخدام
/// عبر أحجام الشاشات المختلفة.
class AyahCoordinateService {
  static String _key(int page, int surah, int ayah) =>
      'quran.ayah_coord.$page.$surah.$ayah';

  static Future<void> save({
    required int page,
    required int surah,
    required int ayah,
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    if (width <= 0 || height <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key(page, surah, ayah), [
      (x / width).clamp(0.0, 1.0).toStringAsFixed(6),
      (y / height).clamp(0.0, 1.0).toStringAsFixed(6),
    ]);
  }

  static Future<({double x, double y})?> get({
    required int page,
    required int surah,
    required int ayah,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key(page, surah, ayah));
    if (values == null || values.length != 2) return null;
    final x = double.tryParse(values[0]);
    final y = double.tryParse(values[1]);
    if (x == null || y == null) return null;
    return (x: x, y: y);
  }
}
