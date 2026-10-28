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
    final lines = <String>['مُدَبِّر الأسرار العليا'];
    final text = verse['text'];
    if (text is String && text.trim().isNotEmpty) {
      lines
        ..add('')
        ..add('الآية: $text');
    }

    final surah = verse['surah'];
    final ayah = verse['ayah'];
    if (surah != null && ayah != null) {
      lines.add('المرجع: سورة $surah — الآية $ayah');
    }

    final sciences = verse['sciences'];
    if (sciences is List) {
      final labels = sciences
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      if (labels.isNotEmpty) lines.add('العلوم: ${labels.join(', ')}');
    }

    final attributes = verse['attributes'];
    if (attributes is List) {
      final labels = attributes
          .whereType<String>()
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      if (labels.isNotEmpty) lines.add('الصفات: ${labels.join(', ')}');
    }

    final jummal = verse['jummal'];
    if (jummal is num) lines.add('قيمة الجمل المسجلة: $jummal');
    return lines.join('\n');
  }

  static String formatDailyInsight(Map<String, String> insight) {
    return '''
🌟 ${insight['title']}

${insight['body']}

📱 من تطبيق مُدَبِّر
''';
  }
}
