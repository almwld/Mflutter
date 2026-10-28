import 'package:shared_preferences/shared_preferences.dart';

import 'daily_streak_service.dart';
import 'local_activity_summary_service.dart';

/// Achievement state is derived from observable local activity. Features that
/// do not yet emit measurable events remain explicitly untracked instead of
/// displaying fabricated progress or unlocked badges.
class AchievementsService {
  static final List<Map<String, dynamic>> _achievements = <Map<String, dynamic>>[
    {'id': 'first_verse', 'title': 'أول صفحة', 'desc': 'فتح صفحة من المصحف', 'icon': '📖', 'unlocked': false, 'progress': 0.0, 'tracking': true},
    {'id': 'ten_verses', 'title': 'حافظ الآيات', 'desc': 'حفظ 10 آيات في المفضلة', 'icon': '📚', 'unlocked': false, 'progress': 0.0, 'tracking': true},
    {'id': 'first_abjad', 'title': 'حاسب الجمل', 'desc': 'استخدام حاسبة الجمل', 'icon': '🔢', 'unlocked': false, 'progress': 0.0, 'tracking': true},
    {'id': 'daily_streak_3', 'title': 'متعهد', 'desc': '٣ أيام قراءة متتالية', 'icon': '🔥', 'unlocked': false, 'progress': 0.0, 'tracking': true},
    {'id': 'seven_sciences', 'title': 'موسوعي', 'desc': 'استكشاف ٧ علوم', 'icon': '🔬', 'unlocked': false, 'progress': 0.0, 'tracking': true},
    {'id': 'ten_insights', 'title': 'متدبر', 'desc': '١٠ أسئلة بصيرة', 'icon': '💡', 'unlocked': false, 'progress': 0.0, 'tracking': true},
    {'id': 'night_mode', 'title': 'راهب الليل', 'desc': 'فتح التطبيق بين 20:00 و04:59 بالتوقيت المحلي', 'icon': '🌙', 'unlocked': false, 'progress': 0.0, 'tracking': true},
    {'id': 'share_verse', 'title': 'ناشر النور', 'desc': 'مشاركة آية', 'icon': '📤', 'unlocked': false, 'progress': 0.0, 'tracking': true},
  ];

  static List<Map<String, dynamic>> get achievements =>
      _achievements.map((item) => Map<String, dynamic>.unmodifiable(item)).toList(growable: false);

  static int get unlockedCount =>
      _achievements.where((item) => item['unlocked'] == true).length;

  static Future<void> refreshFromLocalActivity() async {
    try {
      await DailyStreakService.initialize();
    } catch (_) {
      // Other local activity metrics remain useful if the streak store fails.
    }
    final summary = await const LocalActivitySummaryService().load();
    _setProgress('first_verse', summary.pagesRead > 0 ? 1 : 0);
    _setProgress('ten_verses', summary.bookmarkCount / 10);
    _setProgress('daily_streak_3', DailyStreakService.streak / 3);

    try {
      final preferences = await SharedPreferences.getInstance();
      final abjadCalculations =
          preferences.getInt('mudabbir_abjad_calculations') ?? 0;
      _setProgress('first_abjad', abjadCalculations > 0 ? 1 : 0);
      final completedInsights =
          preferences.getInt('mudabbir_completed_insights') ?? 0;
      _setProgress('ten_insights', completedInsights / 10);
      final exploredSciences =
          preferences.getStringList('mudabbir_explored_sciences') ?? const [];
      _setProgress('seven_sciences', exploredSciences.toSet().length / 7);
      _setProgress(
        'share_verse',
        preferences.getBool('mudabbir_shared_verse') == true ? 1 : 0,
      );
      _setProgress(
        'night_mode',
        preferences.getBool('mudabbir_night_use') == true ? 1 : 0,
      );
    } catch (_) {
      // Keep previously loaded achievement state if preference reads fail.
    }
  }

  /// Records app startup during the device's local night window (20:00–04:59).
  static Future<void> recordNightUseIfApplicable() async {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 20) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!await preferences.setBool('mudabbir_night_use', true)) return;
      _setProgress('night_mode', 1);
    } catch (_) {
      // App startup must not be blocked by achievement persistence.
    }
  }

  /// Records a real completed calculation, persisting the event locally.
  static Future<void> recordAbjadCalculation() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final previous = preferences.getInt('mudabbir_abjad_calculations') ?? 0;
      if (!await preferences.setInt('mudabbir_abjad_calculations', previous + 1)) return;
      _setProgress('first_abjad', 1);
    } catch (_) {
      // A profile/achievement persistence issue must not block the calculator.
    }
  }

  /// Records a verse share only after the platform reports a successful share.
  static Future<void> recordVerseShared() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!await preferences.setBool('mudabbir_shared_verse', true)) return;
      _setProgress('share_verse', 1);
    } catch (_) {
      // Sharing itself must not fail because achievement storage is unavailable.
    }
  }

  /// Counts distinct science topics whose detail view the user opened.
  static Future<void> recordScienceExplored(String scienceId) async {
    final normalizedId = scienceId.trim();
    if (normalizedId.isEmpty) return;
    try {
      final preferences = await SharedPreferences.getInstance();
      final explored = (preferences.getStringList('mudabbir_explored_sciences') ??
              const <String>[])
          .toSet();
      explored.add(normalizedId);
      if (!await preferences.setStringList(
        'mudabbir_explored_sciences',
        explored.toList(growable: false),
      )) return;
      _setProgress('seven_sciences', explored.length / 7);
    } catch (_) {
      // Science browsing remains available if achievement persistence fails.
    }
  }

  /// Counts a successfully completed local agent task, not a submitted prompt.
  static Future<void> recordCompletedInsight() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final previous = preferences.getInt('mudabbir_completed_insights') ?? 0;
      final next = previous + 1;
      if (!await preferences.setInt('mudabbir_completed_insights', next)) return;
      _setProgress('ten_insights', next / 10);
    } catch (_) {
      // The agent's answer remains successful if achievement persistence fails.
    }
  }

  static void _setProgress(String id, double value) {
    final achievement = _achievements.firstWhere((item) => item['id'] == id);
    final progress = value.clamp(0.0, 1.0).toDouble();
    achievement['progress'] = progress;
    achievement['unlocked'] = progress >= 1.0;
  }

  static void unlock(String id) {
    final index = _achievements.indexWhere((item) => item['id'] == id);
    if (index < 0 || _achievements[index]['tracking'] != true) return;
    _setProgress(id, 1);
  }

  static void updateProgress(String id, double progress) {
    final index = _achievements.indexWhere((item) => item['id'] == id);
    if (index < 0 || _achievements[index]['tracking'] != true) return;
    _setProgress(id, progress);
  }
}
