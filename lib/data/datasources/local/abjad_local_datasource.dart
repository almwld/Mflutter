import '../../../core/utils/abjad_calculator.dart';
import '../../../utils/abjad_constants.dart';
import '../../../domain/entities/divine_name.dart';
import '../../../core/constants/app_enums.dart';
import '../../../domain/entities/science.dart';
import '../../../domain/repositories/divine_names_repository.dart';

/// =============================================================================
/// AbjadLocalDatasource - مصدر بيانات الجُمَّل المحلي
/// =============================================================================

class AbjadLocalDatasource {
  // ═══════════════════════════════════════════════════════════════════════════
  // العمليات
  // ═══════════════════════════════════════════════════════════════════════════

  DivineName _divineName(int number) {
    final names = AbjadConstants.divineNames;
    if (number < 1 || names.isEmpty) {
      return const DivineName(
        id: 0,
        arabicName: 'غير محدد',
        transliteration: '',
        meaning: '',
        description: 'رقم خارج نطاق القائمة.',
        type: DivineNameType.names,
        abjadValue: 0,
        color: '#808080',
      );
    }
    final index = (number - 1) % names.length;
    return DivineName(
      id: index + 1,
      arabicName: names[index],
      transliteration: '',
      meaning: '',
      description: '',
      type: DivineNameType.names,
      abjadValue: number,
      color: '#FFD700',
    );
  }

  Future<List<DivineName>> getAllDivineNames() async =>
      List.generate(AbjadConstants.divineNames.length, (i) => _divineName(i + 1));

  Future<DivineName> getDivineName(int number) async => _divineName(number);

  Future<List<DivineName>> searchDivineNames(String query) async {
    final q = query.trim();
    if (q.isEmpty) return getAllDivineNames();
    return (await getAllDivineNames()).where((n) => n.arabicName.contains(q) || n.meaning.contains(q)).toList();
  }

  Future<DivineName> getRandomDivineName() async {
    final values = await getAllDivineNames();
    return values[DateTime.now().millisecondsSinceEpoch % values.length];
  }

  Future<List<DivineName>> getDivineNamesByAttribute(AttributeType attribute) async {
    final type = DivineNameType.values[attribute.index];
    return (await getAllDivineNames()).where((n) => n.type == type).toList();
  }

  Future<List<Letter>> getLetters() async => AbjadCalculator.kabirValues.entries.map((e) => Letter(value: e.key, abjadValue: e.value)).toList();
  Future<List<Number>> getNumbers() async => List.generate(100, (i) => Number(value: i + 1));
  Future<List<Element>> getElements() async => const [Element(name: 'النار'), Element(name: 'الماء'), Element(name: 'التراب'), Element(name: 'الهواء'), Element(name: 'الروح')];
  Future<List<Planet>> getPlanets() async => const [Planet(name: 'الشمس'), Planet(name: 'القمر'), Planet(name: 'المريخ'), Planet(name: 'عطارد'), Planet(name: 'المشتري'), Planet(name: 'الزهرة'), Planet(name: 'زحل')];
  Future<List<ZodiacSign>> getZodiacSigns() async => const [ZodiacSign(name: 'الحمل'), ZodiacSign(name: 'الثور'), ZodiacSign(name: 'الجوزاء'), ZodiacSign(name: 'السرطان'), ZodiacSign(name: 'الأسد'), ZodiacSign(name: 'العذراء'), ZodiacSign(name: 'الميزان'), ZodiacSign(name: 'العقرب'), ZodiacSign(name: 'القوس'), ZodiacSign(name: 'الجدي'), ZodiacSign(name: 'الدلو'), ZodiacSign(name: 'الحوت')];

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
  String getElement(int value) => value < 1
      ? 'غير محدد'
      : AbjadConstants.getElementByNumber(value);

  /// الحصول على ارتباط الكوكب الرمزي حسب الجدول التقليدي.
  String getPlanet(int value) => value < 1
      ? 'غير محدد'
      : AbjadConstants.getPlanetByNumber(value);

  /// الحصول على ارتباط البرج الرمزي حسب الجدول التقليدي.
  String getZodiac(int value) => value < 1
      ? 'غير محدد'
      : AbjadConstants.getZodiacByNumber(value);

  /// الحصول على اسم من القائمة الشائعة بفهرسة تبدأ من 1.
  String getDivineNameValue(int value) => value < 1
      ? 'غير محدد'
      : AbjadConstants.getDivineNameByNumber(value);

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