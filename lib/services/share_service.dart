import 'package:share_plus/share_plus.dart';

import 'achievements_service.dart';

class ShareService {
  /// Shares canonical verse text and records the milestone only when the
  /// platform reports a successful share, not merely a dismissed share sheet.
  static Future<bool> shareVerse({
    required String text,
    required int surahNumber,
    required int ayahNumber,
    String? surahName,
  }) async {
    final surahLabel = surahName == null || surahName.trim().isEmpty
        ? 'رقم $surahNumber'
        : surahName;
    final payload = '$text\n\nسورة $surahLabel — الآية $ayahNumber\n'
        'من مُدَبِّر الأسرار العليا';
    final result = await Share.share(
      payload,
      subject: 'آية من القرآن الكريم',
    );
    final succeeded = result.status == ShareResultStatus.success;
    if (succeeded) await AchievementsService.recordVerseShared();
    return succeeded;
  }

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
