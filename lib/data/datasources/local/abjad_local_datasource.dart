import '../../../core/utils/abjad_calculator.dart';

/// =============================================================================
/// AbjadLocalDatasource - مصدر بيانات الجُمَّل المحلي
/// =============================================================================

class AbjadLocalDatasource {
  // ═══════════════════════════════════════════════════════════════════════════
  // العمليات
  // ═══════════════════════════════════════════════════════════════════════════

  /// حساب الجمل
  Map<String, dynamic> calculate(String text) {
    final result = AbjadCalculator.calculateAll(text);

    return {
      'text': result.text,
      'kabir': result.kabir,
      'saghir': result.saghir,
      'wasat': result.wasat,
      'element': result.element.name,
      'planet': result.planet.name,
      'zodiac': result.zodiac.name,
      'divineName': result.divineName,
      'frequency': result.frequency,
      'color': result.color,
    };
  }

  /// حساب حرف بحرف
  List<Map<String, dynamic>> calculateLetterByLetter(String text) {
    final results = AbjadCalculator.calculateLetterByLetter(text);

    return results.map((r) => {
      'letter': r.letter,
      'kabir': r.kabir,
      'saghir': r.saghir,
      'wasat': r.wasat,
      'runningTotal': r.runningTotal,
    }).toList();
  }

  /// الحصول على العنصر
  String getElement(int value) {
    final element = (value % 5);
    const elements = ['روح', 'نار', 'ماء', 'تراب', 'هواء'];
    return elements[element];
  }

  /// الحصول على الكوكب
  String getPlanet(int value) {
    final planet = (value % 7);
    const planets = ['زُحل', 'شمس', 'قمر', 'مريخ', 'عطارد', 'زُهرة', 'مشتري'];
    return planets[planet];
  }

  /// الحصول على البرج
  String getZodiac(int value) {
    final zodiac = (value % 12);
    const zodiacs = [
      'الحمل', 'الثور', 'الجوزاء', 'السرطان', 'الأسد', 'العذراء',
      'الميزان', 'العقرب', 'القوس', 'الجدي', 'الدلو', 'الحوت',
    ];
    return zodiacs[zodiac];
  }

  /// الحصول على الاسم الإلهي
  String getDivineName(int value) {
    final index = value % 99;
    return DivineNames.arabicNames[index];
  }

  /// الحصول على اللون
  String getColor(int value) {
    final color = (value % 7);
    const colors = ['أحمر', 'أخضر', 'أزرق', 'أصفر', 'أبيض', 'أسود', 'ذهبي'];
    return colors[color];
  }

  /// تحليل النص
  Map<String, dynamic> analyze(String text) {
    final results = calculateLetterByLetter(text);

    final elementCounts = <String, int>{};
    final planetCounts = <String, int>{};

    for (final result in results) {
      final kabir = result['kabir'] as int;

      final element = getElement(kabir);
      elementCounts[element] = (elementCounts[element] ?? 0) + 1;

      final planet = getPlanet(kabir);
      planetCounts[planet] = (planetCounts[planet] ?? 0) + 1;
    }

    return {
      'totalLetters': results.length,
      'totalKabir': results.isNotEmpty ? results.last['runningTotal'] : 0,
      'elementCounts': elementCounts,
      'planetCounts': planetCounts,
      'letterBreakdown': results,
    };
  }
}