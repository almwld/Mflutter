import '../models/abjad_result.dart';
import '../utils/abjad_constants.dart';

/// =============================================================================
/// AbjadService - خدمة حساب الجمل
/// =============================================================================

class AbjadService {
  static final AbjadService _instance = AbjadService._internal();
  factory AbjadService() => _instance;
  AbjadService._internal();

  /// حساب الجمل للنص
  AbjadResult calculate(String text) {
    final letters = _normalizeArabic(text);
    final letterResults = <LetterResult>[];
    int totalKabir = 0;
    int totalSaghir = 0;
    int totalWasat = 0;

    for (final letter in letters.split('')) {
      final value = AbjadConstants.getValue(letter);
      if (value > 0) {
        letterResults.add(LetterResult(letter: letter, value: value));
        totalKabir += value;
      }
    }

    // حساب الصغير (المجموع مقسوم على عدد الحروف)
    totalSaghir = letterResults.isEmpty ? 0 :
        (totalKabir / letterResults.length).round();

    // حساب الوسط (المجموع مقسوم على 2)
    totalWasat = (totalKabir / 2).round();

    // These are traditional symbolic mappings, not scientific measurements.
    final hasLetters = letterResults.isNotEmpty;
    final element = hasLetters ? _getElement(totalKabir) : 'غير محدد';
    final planet = hasLetters ? _getPlanet(totalKabir) : 'غير محدد';
    final zodiac = hasLetters ? _getZodiac(totalKabir) : 'غير محدد';
    final divineName = hasLetters ? _getDivineName(totalKabir) : 'غير محدد';

    // No physical frequency or energy measurement is derived from letters.
    // The legacy field remains zero for data-model compatibility.

    // تحديد اللون
    final color = _getColor(totalKabir);

    return AbjadResult(
      major: totalKabir,
      minor: totalSaghir,
      middle: totalWasat,
      element: element,
      planet: planet,
      zodiac: zodiac,
      divineName: divineName,
      frequency: 0,
      color: color,
      letterResults: letterResults,
    );
  }

  /// حساب حرف بحرف
  List<LetterResult> calculateLetterByLetter(String text) {
    final letters = _normalizeArabic(text);
    final results = <LetterResult>[];

    for (final letter in letters.split('')) {
      final value = AbjadConstants.getValue(letter);
      results.add(LetterResult(letter: letter, value: value));
    }

    return results;
  }

  /// ارتباطات رمزية وفق الجداول المشتركة، وليست نتائج علمية.
  String _getElement(int value) => value < 1
      ? 'غير محدد'
      : AbjadConstants.getElementByNumber(value);

  String _getPlanet(int value) => value < 1
      ? 'غير محدد'
      : AbjadConstants.getPlanetByNumber(value);

  String _getZodiac(int value) => value < 1
      ? 'غير محدد'
      : AbjadConstants.getZodiacByNumber(value);

  /// الحصول على الاسم الإلهي
  String _getDivineName(int value) {
    if (value < 1 || AbjadConstants.divineNames.isEmpty) return 'غير محدد';
    final index = (value - 1) % AbjadConstants.divineNames.length;
    return AbjadConstants.divineNames[index];
  }

  /// الحصول على اللون
  int _getColor(int value) {
    if (value < 1) return 0xFF808080;
    const colors = [
      0xFF1A237E,
      0xFF0D47A1,
      0xFF1565C0,
      0xFF1976D2,
      0xFF1E88E5,
    ];
    return colors[(value - 1) % colors.length];
  }

  /// تطبيع النص العربي
  String _normalizeArabic(String text) {
    // Normalize only variants with the same table value. Keep hamza and
    // ta marbuta intact because their explicit Abjad values differ from
    // unrelated letters in this table.
    return text
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '');
  }
}

