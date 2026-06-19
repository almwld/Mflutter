import '../domain/models/quran_models.dart';

class TextTransformer {
  static String transform(String text, QuranDisplayMode mode) {
    switch (mode) {
      case QuranDisplayMode.uthmaniGold:
        return text;
      case QuranDisplayMode.musnadAncient:
        return _toMusnad(text);
      case QuranDisplayMode.dotless:
        return _removeDots(text);
      case QuranDisplayMode.kufi:
        return _toKufi(text);
      case QuranDisplayMode.hieroglyphic:
        return _toHieroglyphic(text);
    }
  }

  static String _toMusnad(String text) {
    const map = {
      'ا': '𐩱', 'ب': '𐩨', 'ت': '𐩩', 'ث': '𐩶', 'ج': '𐩳',
      'ح': '𐩢', 'خ': '𐩮', 'د': '𐩴', 'ذ': '𐩹', 'ر': '𐩧',
      'ز': '𐩷', 'س': '𐩪', 'ش': '𐩦', 'ص': '𐩯', 'ض': '𐩲',
      'ط': '𐩷', 'ظ': '𐩷', 'ع': '𐩰', 'غ': '𐩵', 'ف': '𐩸',
      'ق': '𐩤', 'ك': '𐩬', 'ل': '𐩡', 'م': '𐩣', 'ن': '𐩭',
      'ه': '𐩠', 'و': '𐩥', 'ي': '𐩺', 'ى': '𐩺', 'ة': '𐩠',
      ' ': ' ', 'أ': '𐩱', 'إ': '𐩱',
    };
    String r = '';
    for (int i = 0; i < text.length; i++) {
      String c = text[i];
      if ('\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652'.contains(c)) continue;
      r += map[c] ?? c;
    }
    return r;
  }

  static String _removeDots(String text) {
    const map = {
      'ب': 'ٮ', 'ت': 'ٮ', 'ث': 'ٮ', 'ج': 'ح', 'خ': 'ح',
      'ذ': 'د', 'ز': 'د', 'ش': 'س', 'ض': 'ص', 'ظ': 'ط',
      'غ': 'ع', 'ف': 'ڡ', 'ق': 'ڡ', 'ن': 'ٮ', 'ي': 'ى',
    };
    String r = '';
    for (int i = 0; i < text.length; i++) {
      String c = text[i];
      if ('\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652'.contains(c)) continue;
      r += map[c] ?? c;
    }
    return r;
  }

  static String _toKufi(String text) {
    // تبسيط للحروف بشكل كوفي
    const map = {
      'ا': '│', 'ب': 'ٮ', 'ت': 'ٮ', 'ث': 'ٮ',
      'ج': 'ﺝ', 'ح': 'ﺝ', 'خ': 'ﺝ',
      'د': 'ﺩ', 'ذ': 'ﺩ', 'ر': 'ﺭ', 'ز': 'ﺭ',
      'س': 'ﺱ', 'ش': 'ﺱ', 'ص': 'ﺹ', 'ض': 'ﺹ',
      'ط': 'ﻁ', 'ظ': 'ﻁ', 'ع': 'ﻉ', 'غ': 'ﻉ',
      'ف': 'ﻑ', 'ق': 'ﻑ', 'ك': 'ﻙ', 'ل': 'ﻝ',
      'م': 'ﻡ', 'ن': 'ﻥ', 'ه': 'ﻩ', 'و': 'ﻭ', 'ي': 'ﻱ',
    };
    String r = '';
    for (int i = 0; i < text.length; i++) {
      String c = text[i];
      if ('\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652'.contains(c)) continue;
      r += map[c] ?? c;
    }
    return r;
  }

  static String _toHieroglyphic(String text) {
    // رموز هيلوغريفية مبسطة
    const map = {
      'ا': '𓂝', 'ب': '𓃀', 'ت': '𓏏', 'ث': '𓏏',
      'ج': '𓎼', 'ح': '𓉔', 'خ': '𓆸',
      'د': '𓂧', 'ذ': '𓂧', 'ر': '𓂋', 'ز': '𓊃',
      'س': '𓋴', 'ش': '𓈙', 'ص': '𓄿', 'ض': '𓄿',
      'ط': '𓍿', 'ظ': '𓍿', 'ع': '𓂝', 'غ': '𓎼',
      'ف': '𓆑', 'ق': '𓈎', 'ك': '𓎡', 'ل': '𓃭',
      'م': '𓅓', 'ن': '𓈖', 'ه': '𓉔', 'و': '𓅱', 'ي': '𓇌',
    };
    String r = '';
    for (int i = 0; i < text.length; i++) {
      String c = text[i];
      if ('\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652'.contains(c)) continue;
      r += map[c] ?? c;
    }
    return r;
  }
}
