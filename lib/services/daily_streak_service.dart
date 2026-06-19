class DailyStreakService {
  static int _streak = 0;
  static DateTime? _lastActive;
  static final List<bool> _weekHistory = [false, false, false, false, false, false, false];

  static int get streak => _streak;
  static List<bool> get weekHistory => _weekHistory;

  static void recordActivity() {
    final now = DateTime.now();
    if (_lastActive != null) {
      final diff = now.difference(_lastActive!).inHours;
      if (diff <= 36) {
        _streak++;
      } else {
        _streak = 1;
      }
    } else {
      _streak = 1;
    }
    _lastActive = now;
    _weekHistory[now.weekday % 7] = true;
  }

  static String getStreakEmoji() {
    if (_streak >= 30) return '👑';
    if (_streak >= 14) return '💎';
    if (_streak >= 7) return '🔥';
    if (_streak >= 3) return '⭐';
    return '🌱';
  }
}
