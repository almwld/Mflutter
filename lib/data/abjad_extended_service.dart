import '../utils/abjad_constants.dart';

class AbjadExtendedService {
  AbjadExtendedService._();

  /// Canonical large-Abjad values shared with the primary calculator.
  static const Map<String, int> values = AbjadConstants.abjadSquare;

  /// Removes harakat and normalizes common Arabic letter variants.
  static String normalize(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
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