/// =============================================================================
/// AbjadResult - كيان نتيجة الجمل
/// =============================================================================

class AbjadResultEntity {
  final String text;
  final int kabir;
  final int saghir;
  final int wasat;
  final String element;
  final String planet;
  final String zodiac;
  final String divineName;
  final int frequency;
  final String color;
  final List<LetterBreakdown> letterBreakdown;

  const AbjadResultEntity({
    required this.text,
    required this.kabir,
    required this.saghir,
    required this.wasat,
    required this.element,
    required this.planet,
    required this.zodiac,
    required this.divineName,
    required this.frequency,
    required this.color,
    this.letterBreakdown = const [],
  });

  /// القيمة الكبيرة
  String get kabirFormatted => _formatNumber(kabir);

  /// القيمة الصغيرة
  String get saghirFormatted => _formatNumber(saghir);

  /// القيمة الوسطى
  String get wasatFormatted => _formatNumber(wasat);

  /// وصف العنصر
  String get elementDescription => _getElementDescription(element);

  /// وصف الكوكب
  String get planetDescription => _getPlanetDescription(planet);

  /// وصف البرج
  String get zodiacDescription => _getZodiacDescription(zodiac);

  /// الوصف الكامل
  String get fullDescription =>
      'النص "$text"\n'
      'الجمل الكبير: $kabirFormatted\n'
      'الجمل الصغير: $saghirFormatted\n'
      'الجمل الأوسط: $wasatFormatted\n'
      'العنصر: $element\n'
      'الكوكب: $planet\n'
      'البرج: $zodiac\n'
      'الاسم الإلهي: $divineName';

  String _formatNumber(int num) {
    if (num >= 1000) {
      return '$num (${num ~/ 1000} آلاف)';
    }
    return num.toString();
  }

  String _getElementDescription(String elem) {
    switch (elem) {
      case 'نار':
        return 'نار - الطاقة والحيوية';
      case 'ماء':
        return 'ماء - السكينة والتدفق';
      case 'تراب':
        return 'تراب - الثبات والرسوخ';
      case 'هواء':
        return 'هواء - الحرية والانطلاق';
      case 'روح':
        return 'روح - السمو والتطهر';
      default:
        return elem;
    }
  }

  String _getPlanetDescription(String planet) {
    switch (planet) {
      case 'شمس':
        return 'الشمس - القيادة والنور';
      case 'قمر':
        return 'القمر - العواطف والحدس';
      case 'مريخ':
        return 'المريخ - القوة والشجاعة';
      case 'عطارد':
        return 'عطارد - الذكاء والتواصل';
      case 'زُهرة':
        return 'الزهرة - الجمال والمحبة';
      case 'مشتري':
        return 'المشتري - الحكمة والتوسع';
      case 'زُحل':
        return 'زُحل - الانضباط والصبر';
      default:
        return planet;
    }
  }

  String _getZodiacDescription(String zodiac) {
    switch (zodiac) {
      case 'الحمل':
        return 'الحمل - البذارة والشجاعة';
      case 'الثور':
        return 'الثور - الصبر والاستمرار';
      case 'الجوزاء':
        return 'الجوزاء - التواصل والمرونة';
      case 'السرطان':
        return 'السرطان - الحدس والعاطفة';
      case 'الأسد':
        return 'الأسد - القيادة والكبرياء';
      case 'العذراء':
        return 'العذراء - التحليل والدقة';
      case 'الميزان':
        return 'الميزان - التوازن والعدالة';
      case 'العقرب':
        return 'العقرب - العمق والعزم';
      case 'القوس':
        return 'القوس - التفاؤل والحكمة';
      case 'الجدي':
        return 'الجدي - الطموح والانضباط';
      case 'الدلو':
        return 'الدلو - الابتكار والحرية';
      case 'الحوت':
        return 'الحوت - الحدس والروحانية';
      default:
        return zodiac;
    }
  }
}

/// =============================================================================
/// LetterBreakdown - تفصيل الحرف
/// =============================================================================

class LetterBreakdown {
  final String letter;
  final int position;
  final int kabirValue;
  final int saghirValue;
  final int wasatValue;
  final int runningTotal;

  const LetterBreakdown({
    required this.letter,
    required this.position,
    required this.kabirValue,
    required this.saghirValue,
    required this.wasatValue,
    required this.runningTotal,
  });
}