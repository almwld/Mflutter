import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DreamJournalService {
  static const _key = 'mudabbir.dreams';

  static Future<void> addDream(String dream, String emotions) async {
    final prefs = await SharedPreferences.getInstance();
    final dreams = await getDreams();
    dreams.add({
      'dream': dream,
      'emotions': emotions,
      'date': DateTime.now().toIso8601String(),
      'verse': _matchVerse(dream),
    });
    await prefs.setString(_key, jsonEncode(dreams));
  }

  static Future<List<Map<String,dynamic>>> getDreams() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final value = jsonDecode(raw);
    return (value as List).map((e) => Map<String,dynamic>.from(e as Map)).toList();
  }

  static String _matchVerse(String dream) {
    if (dream.contains('خوف') || dream.contains('فزع')) return 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ (الرعد:28)';
    if (dream.contains('ماء') || dream.contains('بحر')) return 'وَجَعَلْنَا مِنَ الْمَاءِ كُلَّ شَيْءٍ حَيٍّ (الأنبياء:30)';
    if (dream.contains('سماء') || dream.contains('نجم')) return 'وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ (الذاريات:47)';
    return 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ (النور:35)';
  }
}
