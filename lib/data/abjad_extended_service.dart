class AbjadExtendedService {
  AbjadExtendedService._();

  static const Map<String, int> values = <String, int>{
    'ا': 1, 'ب': 2, 'ج': 3, 'د': 4, 'ه': 5, 'و': 6, 'ز': 7, 'ح': 8,
    'ط': 9, 'ي': 10, 'ك': 20, 'ل': 30, 'م': 40, 'ن': 50, 'س': 60,
    'ع': 70, 'ف': 80, 'ص': 90, 'ق': 100, 'ر': 200, 'ش': 300,
    'ت': 400, 'ث': 500, 'خ': 600, 'ذ': 700, 'ض': 800, 'ظ': 900,
    'غ': 1000,
  };

  /// Removes harakat and normalizes common Arabic letter variants.
  static String normalize(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ـ', '');
  }

  /// Abjad al-kabir. Punctuation, spaces, and non-Arabic characters are ignored.
  static int calculate(String text) {
    var total = 0;
    for (final rune in normalize(text).runes) {
      final letter = String.fromCharCode(rune);
      total += values[letter] ?? 0;
    }
    return total;
  }

  static List<MapEntry<String, int>> analyzeLetters(String text) {
    final result = <MapEntry<String, int>>[];
    for (final rune in normalize(text).runes) {
      final letter = String.fromCharCode(rune);
      final value = values[letter];
      if (value != null) result.add(MapEntry<String, int>(letter, value));
    }
    return result;
  }
}