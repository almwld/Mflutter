import '../core/utils/abjad_calculator.dart';
import '../utils/abjad_constants.dart';

/// One canonical normalization and arithmetic path for all Abjad tools.
///
/// The values are conventional letter-number mappings, not scientific
/// measurements or a basis for predictions. Unsupported characters are ignored.
class AbjadExtendedService {
  AbjadExtendedService._();

  static const Map<String, int> values = AbjadConstants.abjadSquare;

  /// Remove Arabic marks and normalize equivalent spellings consistently.
  /// Ta marbuta is intentionally preserved: traditional mappings may assign it
  /// 400, so silently converting it to ه would change the selected convention.
  static String normalize(String text) =>
      AbjadCalculator.normalizeArabic(text);

  /// Canonical large-Abjad sum. Uses the same implementation as the main UI.
  static int calculate(String text) =>
      AbjadCalculator.calculateKabir(normalize(text));

  /// Per-letter values from the same map and normalization policy.
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
