class TimeCapsuleService {
  static final List<Map<String, dynamic>> _capsules = [];

  static void sealCapsule(String content, DateTime unlockDate) {
    _capsules.add({'content': content, 'unlockDate': unlockDate, 'sealed': DateTime.now()});
  }

  static List<Map<String, dynamic>> get capsules => _capsules;

  static Map<String, dynamic>? tryUnlock(int index) {
    if (index < _capsules.length && DateTime.now().isAfter(_capsules[index]['unlockDate'])) {
      return _capsules[index];
    }
    return null;
  }
}
