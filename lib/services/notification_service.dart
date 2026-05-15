import 'dart:math';

class NotificationService {
  static final List<Map<String, String>> _dailyInsights = [
    {'title': 'آية اليوم', 'body': '﴿وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ وَإِنَّا لَمُوسِعُونَ﴾ - تأمل في توسع الكون.', 'time': '06:00'},
    {'title': 'تأمل الصباح', 'body': '﴿إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ﴾ - آية للعالمين.', 'time': '08:00'},
    {'title': 'حكمة الظهيرة', 'body': '﴿وَفَوْقَ كُلِّ ذِي عِلْمٍ عَلِيمٌ﴾ - اطلب العلم.', 'time': '12:00'},
    {'title': 'تدبر المساء', 'body': '﴿اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ﴾ - نور الله يهدي.', 'time': '18:00'},
    {'title': 'سؤال الليل', 'body': 'ماذا تعلمت اليوم من القرآن؟ تدبر قبل النوم.', 'time': '22:00'},
  ];

  static Map<String, String> getRandomInsight() {
    return _dailyInsights[Random().nextInt(_dailyInsights.length)];
  }

  static List<Map<String, String>> getAllInsights() => _dailyInsights;

  static Map<String, String> getInsightByTime(String time) {
    try {
      return _dailyInsights.firstWhere((i) => i['time'] == time);
    } catch (_) {
      return _dailyInsights[0];
    }
  }
}
