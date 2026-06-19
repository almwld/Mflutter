class DreamJournalService {
  static final List<Map<String, dynamic>> _dreams = [];

  static void addDream(String dream, String emotions) {
    _dreams.add({
      'dream': dream,
      'emotions': emotions,
      'date': DateTime.now(),
      'verse': _matchVerse(dream),
    });
  }

  static String _matchVerse(String dream) {
    if (dream.contains('خوف') || dream.contains('فزع')) return 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ (الرعد:28)';
    if (dream.contains('ماء') || dream.contains('بحر')) return 'وَجَعَلْنَا مِنَ الْمَاءِ كُلَّ شَيْءٍ حَيٍّ (الأنبياء:30)';
    if (dream.contains('سماء') || dream.contains('نجم')) return 'وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ (الذاريات:47)';
    return 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ (النور:35)';
  }

  static List<Map<String, dynamic>> get dreams => _dreams;
}
