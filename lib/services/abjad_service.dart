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

    // تحديد العنصر
    final element = _getElement(totalKabir);

    // تحديد الكوكب
    final planet = _getPlanet(totalKabir);

    // تحديد البرج
    final zodiac = _getZodiac(totalKabir);

    // تحديد الاسم الإلهي
    final divineName = _getDivineName(totalKabir);

    // حساب التذبذب (البعد عن المتوسط)
    final avgValue = letterResults.isEmpty ? 0 :
        letterResults.map((l) => l.value).reduce((a, b) => a + b) / letterResults.length;
    final variance = letterResults.isEmpty ? 0.0 :
        letterResults.map((l) => (l.value - avgValue).abs()).reduce((a, b) => a + b) / letterResults.length;
    final frequency = (1.0 - (variance / 20.0)).clamp(0.0, 1.0);

    // تحديد اللون
    final color = _getColor(totalKabir);

    return AbjadResult(
      kabir: totalKabir,
      saghir: totalSaghir,
      wasat: totalWasat,
      element: element,
      planet: planet,
      zodiac: zodiac,
      divineName: divineName,
      frequency: frequency,
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

  /// الحصول على العنصر
  String _getElement(int value) {
    final elements = ['النار', 'الماء', 'التراب', 'الهواء', 'الروح'];
    return elements[value % elements.length];
  }

  /// الحصول على الكوكب
  String _getPlanet(int value) {
    final planets = ['الشمس', 'القمر', 'المريخ', 'عطارد', 'المشتري', 'الزهرة', 'زحل'];
    return planets[value % planets.length];
  }

  /// الحصول على البرج
  String _getZodiac(int value) {
    final zodiacs = [
      'الحمل', 'الثور', 'الجوزاء', 'السرطان',
      'الأسد', 'العذراء', 'الميزان', 'العقرب',
      'القوس', 'الجدي', 'الدلو', 'الحوت'
    ];
    return zodiacs[value % zodiacs.length];
  }

  /// الحصول على الاسم الإلهي
  String _getDivineName(int value) {
    final index = (value - 1) % 99;
    return AbjadConstants.divineNames[index];
  }

  /// الحصول على اللون
  int _getColor(int value) {
    final colors = [0xFF1A237E, 0xFF0D47A1, 0xFF1565C0, 0xFF1976D2, 0xFF1E88E5];
    return colors[value % colors.length];
  }

  /// تطبيع النص العربي
  String _normalizeArabic(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ء', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ي', 'ي')
        .replaceAll('ۧ', '')
        .replaceAll('ۨ', '');
  }
}

/// =============================================================================
/// LetterResult - نتيجة الحرف
/// =============================================================================

class LetterResult {
  final String letter;
  final int value;

  LetterResult({required this.letter, required this.value});
}