class IoTSanctuaryService {
  static bool _enabled = false;
  static String _mode = 'default';

  static bool get enabled => _enabled;
  static String get mode => _mode;

  static void toggle(bool value) => _enabled = value;

  static Future<bool> syncEnvironment(String themeMode) async {
    _mode = themeMode;
    return true;
  }
}
