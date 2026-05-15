class GazeTrackingService {
  static bool _isWatching = false;
  static String _focusedWord = '';
  static int _focusSeconds = 0;

  static bool get isWatching => _isWatching;
  static String get focusedWord => _focusedWord;

  static void startWatching() => _isWatching = true;
  static void stopWatching() => _isWatching = false;

  static void reportFocus(String word, int seconds) {
    _focusedWord = word;
    _focusSeconds = seconds;
  }

  static bool get shouldShowInsight => _focusSeconds >= 3;
}
