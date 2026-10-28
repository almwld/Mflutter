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
    {'id': 'seven_sciences', 'title': 'موسوعي', 'desc': 'استكشاف ٧ علوم', 'icon': '🔬', 'unlocked': false, 'progress': 0.0, 'tracking': false},
    {'id': 'ten_insights', 'title': 'متدبر', 'desc': '١٠ أسئلة بصيرة', 'icon': '💡', 'unlocked': false, 'progress': 0.0, 'tracking': false},
    {'id': 'night_mode', 'title': 'راهب الليل', 'desc': 'استخدام التطبيق ليلاً', 'icon': '🌙', 'unlocked': false, 'progress': 0.0, 'tracking': false},
    {'id': 'share_verse', 'title': 'ناشر النور', 'desc': 'مشاركة آية', 'icon': '📤', 'unlocked': false, 'progress': 0.0, 'tracking': false},
  ];

  static List<Map<String, dynamic>> get achievements =>
      _achievements.map((item) => Map<String, dynamic>.unmodifiable(item)).toList(growable: false);

  static int get unlockedCount =>
      _achievements.where((item) => item['unlocked'] == true).length;

  static Future<void> refreshFromLocalActivity() async {
    await DailyStreakService.initialize();
    final summary = await const LocalActivitySummaryService().load();
    _setProgress('first_verse', summary.pagesRead > 0 ? 1 : 0);
    _setProgress('ten_verses', summary.bookmarkCount / 10);
    _setProgress('daily_streak_3', DailyStreakService.streak / 3);

    final preferences = await SharedPreferences.getInstance();
    final abjadCalculations =
        preferences.getInt('mudabbir_abjad_calculations') ?? 0;
    _setProgress('first_abjad', abjadCalculations > 0 ? 1 : 0);
  }

  /// Records a real completed calculation, persisting the event locally.
  static Future<void> recordAbjadCalculation() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final previous = preferences.getInt('mudabbir_abjad_calculations') ?? 0;
      await preferences.setInt('mudabbir_abjad_calculations', previous + 1);
      _setProgress('first_abjad', 1);
    } catch (_) {
      // A profile/achievement persistence issue must not block the calculator.
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
