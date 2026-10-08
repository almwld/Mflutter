import 'package:shared_preferences/shared_preferences.dart';

/// Persists a local checkpoint only.
///
/// This service intentionally does not claim to perform cloud synchronization:
/// there is no remote sync backend configured in this app.
class CloudSyncService {
  static bool _isSyncing = false;
  static DateTime? _lastSync;
  static String _status = 'غير محفوظ';

  static bool get isSyncing => _isSyncing;
  static DateTime? get lastSync => _lastSync;
  static String get status => _status;

  /// Saves the current checkpoint locally. No network request is made.
  static Future<bool> sync() async {
    if (_isSyncing) return false;
    _isSyncing = true;
    _status = 'جارٍ الحفظ محلياً...';
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      await prefs.setString('last_local_checkpoint', now.toIso8601String());
      _lastSync = now;
      _status = 'محفوظ محلياً';
      return true;
    } catch (_) {
      _status = 'تعذر الحفظ المحلي';
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('last_local_checkpoint');
    _lastSync = DateTime.tryParse(value ?? '');
    if (_lastSync != null) _status = 'محفوظ محلياً';
  }
}
