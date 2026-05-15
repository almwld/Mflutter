class CloudSyncService {
  static bool _isSyncing = false;
  static DateTime? _lastSync;
  static String _status = 'غير متزامن';

  static bool get isSyncing => _isSyncing;
  static DateTime? get lastSync => _lastSync;
  static String get status => _status;

  static Future<bool> sync() async {
    _isSyncing = true;
    _status = 'جاري المزامنة...';
    await Future.delayed(Duration(seconds: 2));
    _lastSync = DateTime.now();
    _status = 'تمت المزامنة';
    _isSyncing = false;
    return true;
  }
}
