/// تحويلات glyph-level للأوضاع التجريبية.
///
/// التخطيط لا يتم هنا. هذا الملف يحافظ فقط على قاعدة استبدال الحروف داخل
/// السطر الذي حدده تخطيط QCF. لذلك لا يستطيع التحويل وحده إنشاء سطور جديدة.
class TextTransformer {
  const TextTransformer._();

  static const Map<String, String> musnadMap = {
    'ا': '𐩱', 'أ': '𐩱', 'إ': '𐩱', 'آ': '𐩱', 'ٱ': '𐩱',
    'ب': '𐩨', 'ت': '𐩩', 'ث': '𐩻', 'ج': '𐩴', 'ح': '𐩢', 'خ': '𐩭',
    'د': '𐩵', 'ذ': '𐩹', 'ر': '𐩧', 'ز': '𐩸', 'س': '𐩪', 'ش': '𐩦',
    'ص': '𐩮', 'ض': '𐩳', 'ط': '𐩷', 'ظ': '𐩼', 'ع': '𐩲', 'غ': '𐩶',
    'ف': '𐩰', 'ق': '𐩤', 'ك': '𐩫', 'ل': '𐩡', 'م': '𐩣', 'ن': '𐩬',
    'ه': '𐩠', 'ة': '𐩠', 'و': '𐩥', 'ي': '𐩺', 'ى': '𐩺', 'ؤ': '𐩥', 'ئ': '𐩺',
  };

  static const Map<String, String> hieroglyphMap = {
    'ا': '𓇋', 'أ': '𓇋', 'إ': '𓇋', 'آ': '𓇋', 'ٱ': '𓇋',
    'ب': '𓃀', 'ت': '𓏏', 'ث': '𓍿', 'ج': '𓆓', 'ح': '𓎛', 'خ': '𓐍',
    'د': '𓂧', 'ذ': '𓏭', 'ر': '𓂋', 'ز': '𓊃', 'س': '𓋴', 'ش': '𓈙',
    'ص': '𓊮', 'ض': '𓍑', 'ط': '𓍔', 'ظ': '𓆑', 'ع': '𓂝', 'غ': '𓎼',
    'ف': '𓆑', 'ق': '𓏘', 'ك': '𓎡', 'ل': '𓃭', 'م': '𓅓', 'ن': '𓈖',
    'ه': '𓉔', 'ة': '𓉔', 'و': '𓅱', 'ي': '𓇌', 'ى': '𓇌', 'ؤ': '𓅱', 'ئ': '𓇌',
  };

  static const String _arabicMarks =
      '\\u064B\\u064C\\u064D\\u064E\\u064F\\u0650\\u0651\\u0652\\u0670';

  static String toMusnad(String text) => _map(text, musnadMap);
  static String toHieroglyphic(String text) => _map(text, hieroglyphMap);

  /// يحذف النقاط مع الإبقاء على هيكل الكلمة ومكانها في السطر.
  static String toDotless(String text) {
    const replacements = {
      'ب': 'ٮ', 'ت': 'ٮ', 'ث': 'ٮ', 'ن': 'ں', 'ي': 'ى', 'ج': 'ح',
      'خ': 'ح', 'ذ': 'د', 'ز': 'ر', 'ش': 'س', 'ض': 'ص', 'ظ': 'ط',
      'غ': 'ع', 'ف': 'ڡ', 'ق': 'ٯ',
    };
    return _map(text, replacements, removeMarks: false);
  }

  static String transform(String text, String mode) {
    switch (mode) {
      case 'musnad':
        return toMusnad(text);
      case 'dotless':
        return toDotless(text);
      case 'hieroglyphic':
        return toHieroglyphic(text);
      default:
        return text;
    }
  }

  static String _map(
    String text,
    Map<String, String> map, {
    bool removeMarks = true,
  }) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final c = String.fromCharCode(rune);
      if (removeMarks && _arabicMarks.contains(c)) continue;
      buffer.write(map[c] ?? c);
    }
    return buffer.toString();
  }
}
