import 'dart:math';

class BiorhythmService {
  static Map<String, double> calculate(DateTime birthDate) {
    final days = DateTime.now().difference(birthDate).inDays;
    return {
      'physical': sin(2 * pi * days / 23),
      'emotional': sin(2 * pi * days / 28),
      'intellectual': sin(2 * pi * days / 33),
      'spiritual': sin(2 * pi * days / 19), // دورة روحانية (19 = رقم قرآني)
    };
  }

  static String interpretBiorhythm(Map<String, double> rhythms) {
    final spiritual = rhythms['spiritual'] ?? 0;
    if (spiritual > 0.5) return 'ذروة روحية - وقت مثالي للتدبر العميق';
    if (spiritual < -0.5) return 'انخفاض روحي - آيات السكينة تناسبك اليوم';
    return 'حالة روحية متوازنة';
  }
}
