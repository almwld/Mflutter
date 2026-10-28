import 'package:shared_preferences/shared_preferences.dart';

/// Persistent reading streak based on distinct calendar days with real Quran
/// reading activity. Opening the profile never counts as reading.
class DailyStreakService {
  static const _activeDatesKey = 'reading_streak.active_dates.v1';

  static int _streak = 0;
  static final List<bool> _weekHistory = List<bool>.filled(7, false);
  static Set<String> _activeDates = <String>{};
  static bool _initialized = false;
  static Future<void>? _initializing;

  static int get streak => _streak;
  static List<bool> get weekHistory => List<bool>.unmodifiable(_weekHistory);

  static Future<void> initialize() async {
    if (_initialized) return;
    final pending = _initializing;
    if (pending != null) {
      await pending;
      return;
    }
    final attempt = _load();
    _initializing = attempt;
    try {
      await attempt;
      _initialized = true;
    } finally {
      _initializing = null;
    }
  }

  static Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _activeDates = (prefs.getStringList(_activeDatesKey) ?? const <String>[]).toSet();
    _pruneOldDates();
    _recalculate();
  }

  /// Record at most one activity per local calendar day.
  static Future<void> recordActivity() async {
    await initialize();
    final today = _dateKey(DateTime.now());
    if (_activeDates.contains(today)) return;

    // Persist a candidate snapshot before changing in-memory state. If storage
    // fails, the same day's activity can be retried instead of being lost
    // behind an already-added in-memory date.
    final nextDates = Set<String>.from(_activeDates)..add(today);
    _pruneOldDates(nextDates);
    final prefs = await SharedPreferences.getInstance();
    final sorted = nextDates.toList()..sort();
    await prefs.setStringList(_activeDatesKey, sorted);
    _activeDates = nextDates;
    _recalculate();
  }

  static void _pruneOldDates([Set<String>? dates]) {
    final target = dates ?? _activeDates;
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 365));
    target.removeWhere((key) {
      final parsed = DateTime.tryParse(key);
      return parsed == null || parsed.isBefore(cutoff);
    });
  }

  static void _recalculate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var cursor = _activeDates.contains(_dateKey(today))
        ? today
        : today.subtract(const Duration(days: 1));
    var count = 0;
    while (_activeDates.contains(_dateKey(cursor))) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    _streak = count;

    for (var index = 0; index < 7; index++) {
      final day = today.subtract(Duration(days: 6 - index));
      _weekHistory[index] = _activeDates.contains(_dateKey(day));
    }
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String getStreakEmoji() {
    if (_streak >= 30) return '👑';
    if (_streak >= 14) return '💎';
    if (_streak >= 7) return '🔥';
    if (_streak >= 3) return '⭐';
    return '🌱';
  }
}
