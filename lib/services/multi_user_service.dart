class MultiUserService {
  static final List<Map<String, dynamic>> _profiles = [
    {'name': 'الملف الرئيسي', 'avatar': '🌟', 'level': 5, 'xp': 1250, 'createdAt': DateTime.now()},
  ];
  static int _activeProfile = 0;

  static Map<String, dynamic> get activeProfile => _profiles[_activeProfile];
  static List<Map<String, dynamic>> get profiles => _profiles;

  static void addProfile(String name, String avatar) {
    _profiles.add({'name': name, 'avatar': avatar, 'level': 1, 'xp': 0, 'createdAt': DateTime.now()});
  }

  static void switchProfile(int index) => _activeProfile = index;

  static void addXP(int amount) {
    _profiles[_activeProfile]['xp'] += amount;
    final newLevel = (_profiles[_activeProfile]['xp'] / 250).floor() + 1;
    if (newLevel > _profiles[_activeProfile]['level']) {
      _profiles[_activeProfile]['level'] = newLevel;
    }
  }
}
