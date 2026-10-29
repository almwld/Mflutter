import '../../utils/abjad_constants.dart';

/// =============================================================================
/// AbjadCalculator - حاسبة الجُمَّل
/// =============================================================================
/// حساب قيمة الجمل للنص العربي
/// =============================================================================

class AbjadCalculator {
  AbjadCalculator._();

  // ═══════════════════════════════════════════════════════════════════════════
  // قيم الحروف (الجمل الكبير)
  // ═══════════════════════════════════════════════════════════════════════════

  /// قيم الجمل الكبير (أبجد هوز)
  static const Map<String, int> kabirValues = {
    // الحروف العربية وقيمها
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ٱ': 1, 'ء': 1, // ألف
    'ب': 2, // با
    'ج': 3, // جيم
    'د': 4, // دال
    'ه': 5, // هاء
    'و': 6, 'ؤ': 6, // واو
    'ز': 7, // زاي
    'ح': 8, // حاء
    'ط': 9, // طاء
    'ي': 10, 'ى': 10, 'ئ': 10, // ياء
    'ك': 20, // كاف
    'ل': 30, // لام
    'م': 40, // ميم
    'ن': 50, // نون
    'س': 60, // سين
    'ع': 70, // عين
    'ف': 80, // فاء
    'ص': 90, // صاد
    'ق': 100, // قاف
    'ر': 200, // راء
    'ش': 300, // شين
    'ت': 400, 'ة': 400, // تاء
    'ث': 500, // ثاء
    'خ': 600, // خاء
    'ذ': 700, // ذال
    'ض': 800, // ضاد
    'ظ': 900, // ظاء
    'غ': 1000, // غين
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // قيم الجمل الصغير
  // ═══════════════════════════════════════════════════════════════════════════

  /// اختزال رقمي لقيمة كل حرف (مجموع الأرقام حتى خانة واحدة).
  /// هذه طريقة حسابية واحدة وليست تعريفًا موحدًا للجمل الصغير.
  static const Map<String, int> saghirValues = {
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ٱ': 1, 'ء': 1,
    'ب': 2, 'ج': 3, 'د': 4, 'ه': 5, 'و': 6, 'ؤ': 6,
    'ز': 7, 'ح': 8, 'ط': 9, 'ي': 1, 'ى': 1, 'ئ': 1,
    'ك': 2, 'ل': 3, 'م': 4, 'ن': 5, 'س': 6, 'ع': 7,
    'ف': 8, 'ص': 9, 'ق': 1, 'ر': 2, 'ش': 3, 'ت': 4,
    'ث': 5, 'خ': 6, 'ذ': 7, 'ض': 8, 'ظ': 9, 'غ': 1,
    'ة': 4,
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // القيم الوسطى
  // ═══════════════════════════════════════════════════════════════════════════

  /// رتبة الحرف في تسلسل أبجد التقليدي (ليست قيمة معيارية مستقلة باسم الوسط).
  static const Map<String, int> wasatValues = {
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ٱ': 1, 'ء': 1,
    'ب': 2,
    'ج': 3,
    'د': 4,
    'ه': 5,
    'و': 6, 'ؤ': 6,
    'ز': 7,
    'ح': 8,
    'ط': 9,
    'ي': 10, 'ى': 10, 'ئ': 10,
    'ك': 11,
    'ل': 12,
    'م': 13,
    'ن': 14,
    'س': 15,
    'ع': 16,
    'ف': 17,
    'ص': 18,
    'ق': 19,
    'ر': 20,
    'ش': 21,
    'ت': 22, 'ة': 22,
    'ث': 23,
    'خ': 24,
    'ذ': 25,
    'ض': 26,
    'ظ': 27,
    'غ': 28,
  };

  /// Canonical Arabic normalization shared by every calculation entry point.
  /// Diacritics and tatweel are removed; equivalent alif/hamza forms are
  /// normalized while ta marbuta remains distinct (value 400 in this convention).
  static String normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\\u0610-\\u061A\\u064B-\\u065F\\u0670\\u06D6-\\u06ED]'), '')
        .replaceAll('ـ', '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ى', 'ي');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // حساب الجمل
  // ═══════════════════════════════════════════════════════════════════════════

  /// حساب الجمل الكبير
  static int calculateKabir(String text) {
    text = normalizeArabic(text);
    int total = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toLowerCase();
      total += kabirValues[char] ?? 0;
    }
    return total;
  }

  /// حساب الجمل الصغير
  static int calculateSaghir(String text) {
    text = normalizeArabic(text);
    int total = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toLowerCase();
      total += saghirValues[char] ?? 0;
    }
    return total;
  }

  /// حساب الجمل الأوسط
  static int calculateWasat(String text) {
    text = normalizeArabic(text);
    int total = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toLowerCase();
      total += wasatValues[char] ?? 0;
    }
    return total;
  }

  /// حساب جميع أنواع الجمل
  static AbjadResult calculateAll(String text) {
    final kabir = calculateKabir(text);
    final saghir = calculateSaghir(text);
    final wasat = calculateWasat(text);
    final element = _getElement(kabir);
    final planet = _getPlanet(kabir);
    final zodiac = _getZodiac(kabir);
    final divineName = _getDivineName(kabir);
    final color = _getColor(kabir);

    return AbjadResult(
      text: text,
      kabir: kabir,
      saghir: saghir,
      wasat: wasat,
      element: element,
      planet: planet,
      zodiac: zodiac,
      divineName: divineName,
      // Retained for model compatibility; no physical frequency is calculated.
      frequency: 0,
      color: color,
    );
  }

  /// حساب حرف بحرف
  static List<LetterResult> calculateLetterByLetter(String text) {
    text = normalizeArabic(text);
    final results = <LetterResult>[];
    int runningTotal = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i].toLowerCase();
      final kabirValue = kabirValues[char] ?? 0;
      final saghirValue = saghirValues[char] ?? 0;
      final wasatValue = wasatValues[char] ?? 0;

      if (kabirValue > 0) {
        runningTotal += kabirValue;
        results.add(LetterResult(
          letter: text[i],
          kabir: kabirValue,
          saghir: saghirValue,
          wasat: wasatValue,
          runningTotal: runningTotal,
        ));
      }
    }

    return results;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // دوال مساعدة
  // ═══════════════════════════════════════════════════════════════════════════

  /// الحصول على العنصر
  static ElementType _getElement(int value) {
    if (value < 1) return ElementType.unknown;
    const order = [
      ElementType.fire,
      ElementType.water,
      ElementType.earth,
      ElementType.air,
      ElementType.spirit,
    ];
    return order[(value - 1) % order.length];
  }

  /// الحصول على ارتباط الكوكب الرمزي وفق ترتيب الجدول المشترك.
  static PlanetType _getPlanet(int value) {
    if (value < 1) return PlanetType.unknown;
    const order = [
      PlanetType.sun,
      PlanetType.moon,
      PlanetType.mars,
      PlanetType.mercury,
      PlanetType.jupiter,
      PlanetType.venus,
      PlanetType.saturn,
    ];
    return order[(value - 1) % order.length];
  }

  /// الحصول على ارتباط البرج الرمزي وفق ترتيب الجدول المشترك.
  static ZodiacType _getZodiac(int value) {
    if (value < 1) return ZodiacType.unknown;
    const order = [
      ZodiacType.aries,
      ZodiacType.taurus,
      ZodiacType.gemini,
      ZodiacType.cancer,
      ZodiacType.leo,
      ZodiacType.virgo,
      ZodiacType.libra,
      ZodiacType.scorpio,
      ZodiacType.sagittarius,
      ZodiacType.capricorn,
      ZodiacType.aquarius,
      ZodiacType.pisces,
    ];
    return order[(value - 1) % order.length];
  }

  /// اختيار اسم من القائمة بحسب ترتيب اصطلاحي؛ لا يحمل دلالة تنبؤية.
  static String _getDivineName(int value) {
    if (value < 1 || AbjadConstants.divineNames.isEmpty) return 'غير محدد';
    final index = (value - 1) % AbjadConstants.divineNames.length;
    return AbjadConstants.divineNames[index];
  }

  /// الحصول على اللون
  static String _getColor(int value) {
    if (value < 1) return 'غير محدد';
    final index = (value - 1) % 7;
    const colors = ['أحمر', 'أخضر', 'أزرق', 'أصفر', 'أبيض', 'أسود', 'ذهبي'];
    return colors[index];
  }
}

/// =============================================================================
/// ElementType - نوع العنصر
/// =============================================================================
enum ElementType {
  fire, water, earth, air, spirit, unknown
}

/// =============================================================================
/// PlanetType - نوع الكوكب
/// =============================================================================
enum PlanetType {
  sun, moon, mars, mercury, venus, jupiter, saturn, unknown
}

/// =============================================================================
/// ZodiacType - نوع البرج
/// =============================================================================
enum ZodiacType {
  aries, taurus, gemini, cancer, leo, virgo,
  libra, scorpio, sagittarius, capricorn, aquarius, pisces, unknown
}

/// =============================================================================
/// AbjadResult - نتيجة الجمل
/// =============================================================================

class AbjadResult {
  final String text;
  final int kabir;
  final int saghir;
  final int wasat;
  final ElementType element;
  final PlanetType planet;
  final ZodiacType zodiac;
  final String divineName;
  final int frequency;
  final String color;

  const AbjadResult({
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
  });
}

/// =============================================================================
/// LetterResult - نتيجة حرف
/// =============================================================================

class LetterResult {
  final String letter;
  final int kabir;
  final int saghir;
  final int wasat;
  final int runningTotal;

  const LetterResult({
    required this.letter,
    required this.kabir,
    required this.saghir,
    required this.wasat,
    required this.runningTotal,
  });
}

/// =============================================================================
/// DivineNames - الأسماء الإلهية
/// =============================================================================

class DivineNames {
  DivineNames._();

  /// Shared canonicalized list; avoid maintaining a second divergent copy.
  static const List<String> arabicNames = AbjadConstants.divineNames;
}
