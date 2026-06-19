class AIPersonalityService {
  static String _activePersonality = 'mudabbir';
  static final Map<String, Map<String, String>> _personalities = {
    'mudabbir': {
      'name': 'مُدَبِّر',
      'style': 'بليغ وعميق',
      'greeting': 'السلام عليكم، أنا مُدَبِّر. كيف يمكنني مساعدتك في رحلة التدبر؟',
      'tone': 'formal',
    },
    'sage': {
      'name': 'الحكيم',
      'style': 'موجز وحكيم',
      'greeting': 'بسم الله. ما الذي تبحث عنه اليوم؟',
      'tone': 'concise',
    },
    'scholar': {
      'name': 'العالم',
      'style': 'أكاديمي ومفصل',
      'greeting': 'أهلاً بك. دعنا نغوص في أعماق المعرفة القرآنية.',
      'tone': 'academic',
    },
    'companion': {
      'name': 'الرفيق',
      'style': 'ودود وداعم',
      'greeting': 'مرحباً! أنا هنا لأرافقك في رحلتك الروحية.',
      'tone': 'friendly',
    },
  };

  static String get activePersonality => _activePersonality;
  static List<String> get personalityNames => _personalities.keys.toList();

  // دالة عامة للوصول إلى إعدادات الشخصية
  static Map<String, String> getPersonalityConfig(String name) {
    return _personalities[name] ?? _personalities['mudabbir']!;
  }

  static Map<String, String> get activeConfig => _personalities[_activePersonality]!;

  static void switchPersonality(String name) => _activePersonality = name;

  static String formatResponse(String response) {
    final config = activeConfig;
    if (config['tone'] == 'concise') return '💡 $response';
    if (config['tone'] == 'friendly') return '🌟 $response';
    if (config['tone'] == 'academic') return '📚 $response';
    return '🕌 $response';
  }
}
