import 'package:shared_preferences/shared_preferences.dart';

/// =============================================================================
/// SettingsLocalDatasource - مصدر بيانات الإعدادات المحلي
/// =============================================================================

class SettingsLocalDatasource {
  SharedPreferences? _prefs;

  // ═══════════════════════════════════════════════════════════════════════════
  // التهيئة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تهيئة
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// التأكد من التهيئة
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // الإعدادات العامة
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب إعداد
  Future<T?> getSetting<T>(String key) async {
    final prefs = await _preferences;
    return prefs.get(key) as T?;
  }

  /// تعيين إعداد
  Future<bool> setSetting<T>(String key, T value) async {
    final prefs = await _preferences;

    if (value is String) {
      return await prefs.setString(key, value);
    } else if (value is int) {
      return await prefs.setInt(key, value);
    } else if (value is double) {
      return await prefs.setDouble(key, value);
    } else if (value is bool) {
      return await prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await prefs.setStringList(key, value);
    }

    return false;
  }

  /// حذف إعداد
  Future<bool> removeSetting(String key) async {
    final prefs = await _preferences;
    return await prefs.remove(key);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إعدادات الثيم
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب الثيم
  Future<String> getTheme() async {
    return await getSetting<String>('theme') ?? 'system';
  }

  /// تعيين الثيم
  Future<bool> setTheme(String theme) async {
    return await setSetting('theme', theme);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إعدادات اللغة
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب اللغة
  Future<String> getLanguage() async {
    return await getSetting<String>('language') ?? 'ar';
  }

  /// تعيين اللغة
  Future<bool> setLanguage(String language) async {
    return await setSetting('language', language);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إعدادات الإشعارات
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب حالة الإشعارات
  Future<bool> getNotificationsEnabled() async {
    return await getSetting<bool>('notifications_enabled') ?? true;
  }

  /// تعيين حالة الإشعارات
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await setSetting('notifications_enabled', enabled);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // إعدادات أخرى
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب حجم الخط
  Future<String> getFontSize() async {
    return await getSetting<String>('font_size') ?? 'medium';
  }

  /// تعيين حجم الخط
  Future<bool> setFontSize(String size) async {
    return await setSetting('font_size', size);
  }

  /// جلب حجم الصوت
  Future<bool> getAutoPlayAudio() async {
    return await getSetting<bool>('auto_play_audio') ?? false;
  }

  /// تعيين حجم الصوت
  Future<bool> setAutoPlayAudio(bool enabled) async {
    return await setSetting('auto_play_audio', enabled);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // مسح ذاكرة التخزين المؤقت
  // ═══════════════════════════════════════════════════════════════════════════

  /// مسح ذاكرة التخزين المؤقت
  Future<void> clearCache() async {
    final prefs = await _preferences;

    final keysToKeep = ['theme', 'language', 'notifications_enabled'];

    for (final key in prefs.getKeys()) {
      if (!keysToKeep.contains(key)) {
        await prefs.remove(key);
      }
    }
  }

  /// مسح كل الإعدادات
  Future<void> clearAll() async {
    final prefs = await _preferences;
    await prefs.clear();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // معلومات إضافية
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب تاريخ آخر استخدام
  Future<DateTime?> getLastUsed() async {
    final timestamp = await getSetting<int>('last_used');
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// تعيين تاريخ آخر استخدام
  Future<bool> setLastUsed() async {
    return await setSetting(
      'last_used',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// جلب عدد مرات الاستخدام
  Future<int> getUsageCount() async {
    return await getSetting<int>('usage_count') ?? 0;
  }

  /// زيادة عدد مرات الاستخدام
  Future<int> incrementUsageCount() async {
    final count = await getUsageCount();
    await setSetting('usage_count', count + 1);
    return count + 1;
  }
}