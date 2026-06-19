class ShareService {
  static String formatForShare(Map<String, dynamic> verse) {
    return '''
🕌 مُدَبِّر الْأَسْرَارِ الْعُلْيَا

📖 ${verse['text']}
📍 سورة ${verse['surah']} - آية ${verse['ayah']}

🔬 العلوم: ${verse['sciences']?.join(', ') ?? 'علوم متعددة'}
🔮 الصفات: ${verse['attributes']?.join(', ') ?? 'الله'}

🔢 الجمل: ${verse['jummal'] ?? 0}
''';
  }

  static String formatDailyInsight(Map<String, String> insight) {
    return '''
🌟 ${insight['title']}

${insight['body']}

📱 من تطبيق مُدَبِّر
''';
  }
}
