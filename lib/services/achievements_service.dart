class AchievementsService {
  static final List<Map<String, dynamic>> _achievements = [
    {'id': 'first_verse', 'title': 'أول آية', 'desc': 'قراءة أول آية', 'icon': '📖', 'unlocked': false, 'progress': 1.0},
    {'id': 'ten_verses', 'title': 'قارئ مجتهد', 'desc': 'قراءة 10 آيات', 'icon': '📚', 'unlocked': false, 'progress': 0.0},
    {'id': 'first_abjad', 'title': 'حاسب الجمل', 'desc': 'استخدام حاسبة الجمل', 'icon': '🔢', 'unlocked': true, 'progress': 1.0},
    {'id': 'daily_streak_3', 'title': 'متعهد', 'desc': '٣ أيام متتالية', 'icon': '🔥', 'unlocked': false, 'progress': 0.33},
    {'id': 'seven_sciences', 'title': 'موسوعي', 'desc': 'استكشاف ٧ علوم', 'icon': '🔬', 'unlocked': false, 'progress': 0.14},
    {'id': 'ten_insights', 'title': 'متدبر', 'desc': '١٠ أسئلة بصيرة', 'icon': '💡', 'unlocked': false, 'progress': 0.0},
    {'id': 'night_mode', 'title': 'راهب الليل', 'desc': 'استخدام التطبيق ليلاً', 'icon': '🌙', 'unlocked': true, 'progress': 1.0},
    {'id': 'share_verse', 'title': 'ناشر النور', 'desc': 'مشاركة آية', 'icon': '📤', 'unlocked': false, 'progress': 0.0},
  ];

  static List<Map<String, dynamic>> get achievements => _achievements;
  static int get unlockedCount => _achievements.where((a) => a['unlocked'] == true).length;

  static void unlock(String id) {
    final achievement = _achievements.firstWhere((a) => a['id'] == id, orElse: () => {'unlocked': false});
    achievement['unlocked'] = true;
    achievement['progress'] = 1.0;
  }

  static void updateProgress(String id, double progress) {
    final achievement = _achievements.firstWhere((a) => a['id'] == id, orElse: () => {'unlocked': false, 'progress': 0.0});
    achievement['progress'] = progress;
    if (progress >= 1.0) achievement['unlocked'] = true;
  }
}
