class TranslationService {
  static final Map<String, Map<String, String>> _translations = {
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ': {
      'en': 'In the name of Allah, the Most Gracious, the Most Merciful',
      'fr': 'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux',
      'ur': 'اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے',
    },
    'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ': {
      'en': 'All praise is due to Allah, Lord of the worlds',
      'fr': 'Louange à Allah, Seigneur de l\'univers',
      'ur': 'سب تعریف اللہ کے لیے ہے جو تمام جہانوں کا پالنے والا ہے',
    },
  };

  static String translate(String text, String lang) {
    return _translations[text]?[lang] ?? text;
  }

  static List<String> get availableLanguages => ['ar', 'en', 'fr', 'ur'];
}
