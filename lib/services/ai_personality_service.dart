import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AIPersonalityService {
  static const _storageKey = 'mudabbir_active_personality_v1';
  static String _activePersonality = 'mudabbir';
  static final Map<String, Map<String, String>> _personalities = {
    'mudabbir': {'name': 'مُدَبِّر', 'style': 'بليغ وعميق', 'greeting': 'السلام عليكم، أنا مُدَبِّر. كيف يمكنني مساعدتك في رحلة التدبر؟', 'tone': 'formal'},
    'sage': {'name': 'الحكيم', 'style': 'موجز وحكيم', 'greeting': 'بسم الله. ما الذي تبحث عنه اليوم؟', 'tone': 'concise'},
    'scholar': {'name': 'العالم', 'style': 'أكاديمي ومفصل', 'greeting': 'أهلاً بك. دعنا نغوص في أعماق المعرفة القرآنية.', 'tone': 'academic'},
    'companion': {'name': 'الرفيق', 'style': 'ودود وداعم', 'greeting': 'مرحباً! أنا هنا لأرافقك في رحلتك الروحية.', 'tone': 'friendly'},
  };

  static String get activePersonality => _activePersonality;
  static List<String> get personalityNames => _personalities.keys.toList(growable: false);

  static Future<void> loadSavedPersonality() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null && _personalities.containsKey(saved)) _activePersonality = saved;
  }

  static Map<String, String> getPersonalityConfig(String name) =>
      _personalities[name] ?? _personalities['mudabbir']!;
  static Map<String, String> get activeConfig => getPersonalityConfig(_activePersonality);

  static void switchPersonality(String name) {
    if (!_personalities.containsKey(name)) return;
    _activePersonality = name;
    unawaited(_persistPersonality(name));
  }

  static Future<void> _persistPersonality(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, name);
  }

  static String formatResponse(String response) {
    final tone = activeConfig['tone'];
    if (tone == 'concise') return '💡 $response';
    if (tone == 'friendly') return '🌟 $response';
    if (tone == 'academic') return '📚 $response';
    return '🕌 $response';
  }
}
