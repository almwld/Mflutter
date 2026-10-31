import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SmartNotificationsService {
  static const _enabledKey = 'mudabbir_in_app_insights_enabled_v1';
  static final List<Map<String, dynamic>> _scheduled = [];
  static bool _enabled = true;
  static bool get enabled => _enabled;

  static Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
  }

  static void scheduleDaily(String time, String title, String body) {
    _scheduled.removeWhere((item) => item['time'] == time);
    _scheduled.add({'time': time, 'title': title, 'body': body, 'active': true});
  }

  static List<Map<String, dynamic>> get scheduled =>
      _scheduled.map((item) => Map<String, dynamic>.from(item)).toList(growable: false);

  static Map<String, String> getCurrentInsight() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 8) return {'title': 'آية الفجر', 'body': 'وَالصُّبْحِ إِذَا تَنَفَّسَ (التكوير:18)'};
    if (hour >= 8 && hour < 12) return {'title': 'آية الضحى', 'body': 'وَالشَّمْسِ وَضُحَاهَا (الشمس:1)'};
    if (hour >= 12 && hour < 17) return {'title': 'تدبر الظهيرة', 'body': 'أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ (النساء:82)'};
    if (hour >= 17 && hour < 20) return {'title': 'آية الغروب', 'body': 'فَلَا أُقْسِمُ بِالشَّفَقِ (الانشقاق:16)'};
    return {'title': 'آية الليل', 'body': 'وَاللَّيْلِ إِذَا سَجَى (الضحى:2)'};
  }

  static void toggle(bool value) {
    _enabled = value;
    unawaited(_persistEnabled(value));
  }

  static Future<void> _persistEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }
}
