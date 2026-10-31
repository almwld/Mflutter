/// =============================================================================
/// AbjadConstants - ثوابت حساب الجمل
/// =============================================================================

class AbjadConstants {
  AbjadConstants._();

  /// خريطة قيم الحروف العربية (النظام المربع)
  static const Map<String, int> abjadSquare = {
    // الهمزة والألف
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ٱ': 1, 'ء': 1,
    // الباء
    'ب': 2,
    // التاء
    'ت': 400, 'ة': 400,
    // الثاء
    'ث': 500,
    // الجيم
    'ج': 3,
    // الحاء
    'ح': 8,
    // الخاء
    'خ': 600,
    // الدال
    'د': 4,
    // الذال
    'ذ': 700,
    // الراء
    'ر': 200,
    // الزاي
    'ز': 7,
    // السين
    'س': 60,
    // الشين
    'ش': 300,
    // الصاد
    'ص': 90,
    // الضاد
    'ض': 800,
    // الطاء
    'ط': 9,
    // الظاء
    'ظ': 900,
    // العين
    'ع': 70,
    // الغين
    'غ': 1000,
    // الفاء
    'ف': 80,
    // القاف
    'ق': 100,
    // الكاف
    'ك': 20,
    // اللام
    'ل': 30,
    // الميم
    'م': 40,
    // النون
    'ن': 50,
    // الهاء
    'ه': 5,
    // الواو
    'و': 6, 'ؤ': 6,
    // الياء
    'ي': 10, 'ى': 10, 'ئ': 10,
  };

  /// خريطة قيم الحروف العربية (النظام الهجائي)
  static const Map<String, int> abjadAlphabetical = {
    'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ٱ': 1, 'ء': 1,
    'ب': 2,
    'ت': 3, 'ة': 3,
    'ث': 4,
    'ج': 5,
    'ح': 6,
    'خ': 7,
    'د': 8,
    'ذ': 9,
    'ر': 10,
    'ز': 11,
    'س': 12,
    'ش': 13,
    'ص': 14,
    'ض': 15,
    'ط': 16,
    'ظ': 17,
    'ع': 18,
    'غ': 19,
    'ف': 20,
    'ق': 21,
    'ك': 22,
    'ل': 23,
    'م': 24,
    'ن': 25,
    'ه': 26,
    'و': 27, 'ؤ': 27,
    'ي': 28, 'ى': 28, 'ئ': 28,
  };

  /// قائمة شائعة متداولة للأسماء الحسنى؛ قد تختلف بعض القوائم في العدّ والترتيب.
  static const List<String> divineNames = [
    'الله',
    'الرحمن',
    'الرحيم',
    'الملك',
    'القدوس',
    'السلام',
    'المؤمن',
    'المهيمن',
    'العزيز',
    'الجبار',
    'المتكبر',
    'الخالق',
    'البارئ',
    'المصور',
    'الغفار',
    'القهار',
    'الوهاب',
    'الرزاق',
    'الفتاح',
    'العليم',
    'القابض',
    'الباسط',
    'الخافض',
    'الرافع',
    'المعز',
    'المذل',
    'السميع',
    'البصير',
    'الحكم',
    'العدل',
    'اللطيف',
    'الخبير',
    'الحليم',
    'العظيم',
    'الغفور',
    'الشكور',
    'العلي',
    'الكبير',
    'الحفيظ',
    'المقيت',
    'الحسيب',
    'الجليل',
    'الكريم',
    'الرقيب',
    'المجيب',
    'الواسع',
    'الحكيم',
    'الودود',
    'المجيد',
    'الباعث',
    'الشهيد',
    'الحق',
    'الوكيل',
    'القوي',
    'المتين',
    'الولي',
    'الحميد',
    'المحصي',
    'المبدئ',
    'المعيد',
    'المحيي',
    'المميت',
    'الحي',
    'القيوم',
    'الواجد',
    'الماجد',
    'الواحد',
    'الصمد',
    'القادر',
    'المقتدر',
    'المقدم',
    'المؤخر',
    'الأول',
    'الآخر',
    'الظاهر',
    'الباطن',
    'الوالي',
    'المتعالي',
    'البر',
    'التواب',
    'المنتقم',
    'العفو',
    'الرؤوف',
    'مالك الملك',
    'ذو الجلال والإكرام',
    'المقسط',
    'الجامع',
    'الغني',
    'المغني',
    'المانع',
    'الضار',
    'النافع',
    'النور',
    'الهادي',
    'البديع',
    'الباقي',
    'الوارث',
    'الرشيد',
    'الصبور',
  ];

  /// العناصر الأربعة
  static const List<String> elements = ['النار', 'الماء', 'التراب', 'الهواء', 'الروح'];

  /// الكواكب السبعة
  static const List<String> planets = ['الشمس', 'القمر', 'المريخ', 'عطارد', 'المشتري', 'الزهرة', 'زحل'];

  /// الأبراج الإثنا عشر
  static const List<String> zodiacSigns = [
    'الحمل', 'الثور', 'الجوزاء', 'السرطان',
    'الأسد', 'العذراء', 'الميزان', 'العقرب',
    'القوس', 'الجدي', 'الدلو', 'الحوت'
  ];

  /// Canonical text normalization used by all Abjad entry points.
  /// Diacritics and tatweel are removed; equivalent alif/hamza forms are
  /// normalized while ta marbuta is deliberately preserved.
  static String normalizeArabic(String text) => text
      .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
      .replaceAll('ـ', '')
      .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ى', 'ي');

  /// الحصول على قيمة الحرف (النظام المربع)
  static int getValue(String letter) {
    return abjadSquare[letter] ?? 0;
  }

  /// الحصول على قيمة الحرف (النظام الهجائي)
  static int getAlphabeticalValue(String letter) {
    return abjadAlphabetical[letter] ?? 0;
  }

  /// حساب المجموع
  static int calculateTotal(String text) {
    final normalized = normalizeArabic(text);
    var total = 0;
    for (final rune in normalized.runes) {
      total += getValue(String.fromCharCode(rune));
    }
    return total;
  }

  static int _indexForPositiveNumber(int number, int length) {
    if (number < 1) {
      throw ArgumentError.value(number, 'number', 'يجب أن يكون الرقم 1 أو أكبر.');
    }
    return (number - 1) % length;
  }

  /// تحويل الرقم الموجب إلى اسم من القائمة المتداولة (بفهرسة تبدأ من 1).
  static String getDivineNameByNumber(int number) {
    return divineNames[_indexForPositiveNumber(number, divineNames.length)];
  }

  /// تحويل الرقم الموجب إلى عنصر رمزي (بفهرسة تبدأ من 1).
  static String getElementByNumber(int number) {
    return elements[_indexForPositiveNumber(number, elements.length)];
  }

  /// تحويل الرقم الموجب إلى كوكب رمزي (بفهرسة تبدأ من 1).
  static String getPlanetByNumber(int number) {
    return planets[_indexForPositiveNumber(number, planets.length)];
  }

  /// تحويل الرقم الموجب إلى برج رمزي (بفهرسة تبدأ من 1).
  static String getZodiacByNumber(int number) {
    return zodiacSigns[_indexForPositiveNumber(number, zodiacSigns.length)];
  }
}