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

  /// Remove Arabic combining/annotation marks while preserving every base
  /// character. This is presentation-only; the canonical source remains intact.
  static String removeArabicMarks(String text) =>
      String.fromCharCodes(text.runes.where((rune) => !_isArabicMark(rune)));

  /// Arabic combining marks and Quranic annotation marks commonly found in
  /// Uthmani text. This is used only by optional presentation transforms.
  static bool _isArabicMark(int rune) =>
      (rune >= 0x0610 && rune <= 0x061A) ||
      (rune >= 0x064B && rune <= 0x065F) ||
      rune == 0x0670 ||
      (rune >= 0x06D6 && rune <= 0x06ED) ||
      (rune >= 0x08D3 && rune <= 0x08FF);

  static String toMusnad(String text) => _map(text, musnadMap);
  static String toHieroglyphic(String text) => _map(text, hieroglyphMap);

  /// يحذف النقاط وعلامات التشكيل، مع الحفاظ على النص الأصلي خارج طبقة العرض.
  static String toDotless(String text) => _toDotless(text, removeMarks: true);

  /// يحذف النقاط فقط ويُبقي التشكيل القرآني ظاهرًا.
  static String toDotlessPreservingMarks(String text) =>
      _toDotless(text, removeMarks: false);

  static String _toDotless(String text, {required bool removeMarks}) {
    const replacements = {
      'ب': 'ٮ', 'ت': 'ٮ', 'ث': 'ٮ', 'ن': 'ں', 'ي': 'ى', 'ج': 'ح',
      'خ': 'ح', 'ذ': 'د', 'ز': 'ر', 'ش': 'س', 'ض': 'ص', 'ظ': 'ط',
      'غ': 'ع', 'ف': 'ڡ', 'ق': 'ٯ',
    };
    return _map(text, replacements, removeMarks: removeMarks);
  }

  static String transform(String text, String mode) {
    switch (mode) {
      case 'musnad':
        return toMusnad(text);
      case 'dotless':
        return toDotless(text);
      case 'kufi':
        // Kufic is a calligraphic style, not a character substitution.
        // Preserve canonical Arabic text until a dedicated Kufic font exists.
        return text;
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
      if (removeMarks && _isArabicMark(rune)) continue;
      buffer.write(map[c] ?? c);
    }
    return buffer.toString();
  }
}
