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
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ء': 1, // ألف
    'ب': 2, // با
    'ج': 3, // جيم
    'د': 4, // دال
    'ه': 5, // هاء
    'و': 6, // واو
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
    'ت': 400, // تاء
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

  /// قيم الجمل الصغير
  static const Map<String, int> saghirValues = {
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ء': 1,
    'ب': 2,
    'ج': 3,
    'د': 4,
    'ه': 5,
    'و': 6,
    'ز': 7,
    'ح': 8,
    'ط': 9,
    'ي': 10, 'ى': 10, 'ئ': 10,
    'ك': 20,
    'ل': 30,
    'م': 40,
    'ن': 50,
    'س': 60,
    'ع': 70,
    'ف': 80,
    'ص': 90,
    'ق': 100,
    'ر': 101,
    'ش': 102,
    'ت': 103,
    'ث': 104,
    'خ': 105,
    'ذ': 106,
    'ض': 107,
    'ظ': 108,
    'غ': 109,
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // القيم الوسطى
  // ═══════════════════════════════════════════════════════════════════════════

  /// قيم الجمل الأوسط
  static const Map<String, int> wasatValues = {
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ء': 1,
    'ب': 2,
    'ج': 3,
    'د': 4,
    'ه': 5,
    'و': 6,
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
    'ت': 22,
    'ث': 23,
    'خ': 24,
    'ذ': 25,
    'ض': 26,
    'ظ': 27,
    'غ': 28,
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // حساب الجمل
  // ═══════════════════════════════════════════════════════════════════════════

  /// حساب الجمل الكبير
  static int calculateKabir(String text) {
    int total = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toLowerCase();
      total += kabirValues[char] ?? 0;
    }
    return total;
  }

  /// حساب الجمل الصغير
  static int calculateSaghir(String text) {
    int total = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text[i].toLowerCase();
      total += saghirValues[char] ?? 0;
    }
    return total;
  }

  /// حساب الجمل الأوسط
  static int calculateWasat(String text) {
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
    final frequency = _getFrequency(kabir);
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
      frequency: frequency,
      color: color,
    );
  }

  /// حساب حرف بحرف
  static List<LetterResult> calculateLetterByLetter(String text) {
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
    final remainder = value % 5;
    switch (remainder) {
      case 1:
        return ElementType.fire;
      case 2:
        return ElementType.water;
      case 3:
        return ElementType.earth;
      case 4:
        return ElementType.air;
      case 0:
        return ElementType.spirit;
      default:
        return ElementType.spirit;
    }
  }

  /// الحصول على الكوكب
  static PlanetType _getPlanet(int value) {
    final remainder = value % 7;
    switch (remainder) {
      case 1:
        return PlanetType.sun;
      case 2:
        return PlanetType.moon;
      case 3:
        return PlanetType.mars;
      case 4:
        return PlanetType.mercury;
      case 5:
        return PlanetType.venus;
      case 6:
        return PlanetType.jupiter;
      case 0:
        return PlanetType.saturn;
      default:
        return PlanetType.sun;
    }
  }

  /// الحصول على البرج
  static ZodiacType _getZodiac(int value) {
    final remainder = value % 12;
    return ZodiacType.values[remainder];
  }

  /// الحصول على الاسم الإلهي
  static String _getDivineName(int value) {
    final index = (value % 99);
    return DivineNames.arabicNames[index];
  }

  /// الحصول على التكرر
  static int _getFrequency(int value) {
    if (value < 100) return 1;
    if (value < 1000) return value ~/ 100;
    return value ~/ 1000;
  }

  /// الحصول على اللون
  static String _getColor(int value) {
    final remainder = value % 7;
    const colors = ['أحمر', 'أخضر', 'أزرق', 'أصفر', 'أبيض', 'أسود', 'ذهبي'];
    return colors[remainder];
  }
}

/// =============================================================================
/// ElementType - نوع العنصر
/// =============================================================================
enum ElementType {
  fire, water, earth, air, spirit
}

/// =============================================================================
/// PlanetType - نوع الكوكب
/// =============================================================================
enum PlanetType {
  sun, moon, mars, mercury, venus, jupiter, saturn
}

/// =============================================================================
/// ZodiacType - نوع البرج
/// =============================================================================
enum ZodiacType {
  aries, taurus, gemini, cancer, leo, virgo,
  libra, scorpio, sagittarius, capricorn, aquarius, pisces
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

  static const List<String> arabicNames = [
    'الله', 'الرَّحْمَنُ', 'الرَّحِيمُ', 'الْمَلِكُ', 'الْقُدُّوسُ',
    'السَّلَامُ', 'الْمُؤْمِنُ', 'الْمُهَيْمِنُ', 'الْعَزِيزُ', 'الْجَبَّارُ',
    'الْمُتَكَبِّرُ', 'الْخَالِقُ', 'الْبَارِئُ', 'الْمُصَوِّرُ', 'الْغَفَّارُ',
    'الْقَهَّارُ', 'الْوَهَّابُ', 'الرَّزَّاقُ', 'الْفَتَّاحُ', 'الْعَلِيمُ',
    'الْقَابِضُ', 'الْبَاسِطُ', 'الْخَافِضُ', 'الرَّافِعُ', 'الْمُعِزُّ',
    'الْمُذِلُّ', 'السَّمِيعُ', 'الْبَصِيرُ', 'الْحَكِيمُ', 'الْوَدُودُ',
    'الْمَجِيدُ', 'الْبَاعِثُ', 'الشَّهِيدُ', 'الْحَقُّ', 'الْوَكِيلُ',
    'الْقَوِيُّ', 'الْمَتِينُ', 'الْوَلِيُّ', 'الْحَمِيدُ', 'الْمُحْصِيُّ',
    'الْمُبْدِئُ', 'الْمُعِيدُ', 'الْمُحْيِي', 'الْمُمِيتُ', 'الْحَيُّ',
    'الْقَيُّومُ', 'الْوَاجِدُ', 'الْمَاجِدُ', 'الْواحِدُ', 'الصَّمَدُ',
    'الْقَادِرُ', 'الْمُقْتَدِرُ', 'الْقَدِيرُ', 'الْمُقَدِّمُ', 'الْمُؤَخِّرُ',
    'الْأَوَّلُ', 'الْآخِرُ', 'الظَّاهِرُ', 'الْبَاطِنُ', 'الْعَلِيُّ',
    'الْأَعْلَى', 'الْكَبِيرُ', 'الْحَفِيظُ', 'الْمُقِيتُ', 'الْحَسِيبُ',
    'الْجَلِيلُ', 'الْكَرِيمُ', 'الرَّقِيبُ', 'الْمُجِيبُ', 'الْوَاسِعُ',
    'الْحَكِيمُ', 'الْوَدُودُ', 'الْمُضِلُّ', 'النَّافِعُ', 'النُّورُ',
    'الْهَادِي', 'الْبَدِيعُ', 'الْبَاقِي', 'الْوَارِثُ', 'الرَّشِيدُ',
    'الصَّبُورُ',
  ];
}