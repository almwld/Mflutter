class WidgetSystemService {
  static final List<Map<String, dynamic>> _widgets = [
    {'id': 'daily_verse', 'name': 'آية اليوم', 'icon': '📖', 'size': 'large', 'active': true},
    {'id': 'quick_abjad', 'name': 'جمل سريع', 'icon': '🔢', 'size': 'medium', 'active': true},
    {'id': 'streak_counter', 'name': 'عداد التتابع', 'icon': '🔥', 'size': 'small', 'active': true},
    {'id': 'prayer_times', 'name': 'مواقيت الصلاة', 'icon': '🕌', 'size': 'medium', 'active': false},
    {'id': 'recent_searches', 'name': 'آخر بحث', 'icon': '🔍', 'size': 'small', 'active': false},
    {'id': 'topic_cloud', 'name': 'سحابة مواضيع', 'icon': '☁️', 'size': 'large', 'active': false},
  ];

  static List<Map<String, dynamic>> get widgets => _widgets;
  static List<Map<String, dynamic>> get activeWidgets => _widgets.where((w) => w['active'] == true).toList();

  static void toggleWidget(String id) {
    final widget = _widgets.firstWhere((w) => w['id'] == id);
    widget['active'] = !widget['active'];
  }

  static void reorderWidgets(List<String> newOrder) {
    _widgets.sort((a, b) => newOrder.indexOf(a['id']).compareTo(newOrder.indexOf(b['id'])));
  }
}
