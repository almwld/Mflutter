import '../core/utils/abjad_calculator.dart' as core;
import '../domain/entities/abjad_result.dart' as model;
import '../utils/abjad_constants.dart';

/// Compatibility facade for older screens. All arithmetic is delegated to the
/// canonical AbjadCalculator so screens cannot silently use different formulas.
class AbjadService {
  static final AbjadService _instance = AbjadService._internal();
  factory AbjadService() => _instance;
  AbjadService._internal();

  model.AbjadResult calculate(String text) {
    final normalized = core.AbjadCalculator.normalizeArabic(text);
    final canonical = core.AbjadCalculator.calculateAll(normalized);
    final letters = core.AbjadCalculator.calculateLetterByLetter(normalized)
        .map((entry) => model.LetterResult(
              letter: entry.letter,
              value: entry.kabir,
            ))
        .toList(growable: false);

    return model.AbjadResult(
      major: canonical.kabir,
      minor: canonical.saghir,
      middle: canonical.wasat,
      element: canonical.kabir < 1
          ? 'غير محدد'
          : AbjadConstants.getElementByNumber(canonical.kabir),
      planet: canonical.kabir < 1
          ? 'غير محدد'
          : AbjadConstants.getPlanetByNumber(canonical.kabir),
      zodiac: canonical.kabir < 1
          ? 'غير محدد'
          : AbjadConstants.getZodiacByNumber(canonical.kabir),
      divineName: canonical.kabir < 1
          ? 'غير محدد'
          : AbjadConstants.getDivineNameByNumber(canonical.kabir),
      frequency: 0,
      energy: 0,
      color: _getColor(canonical.kabir),
      letterResults: letters,
    );
  }

  List<model.LetterResult> calculateLetterByLetter(String text) {
    final normalized = _normalizeArabic(text);
    return core.AbjadCalculator.calculateLetterByLetter(normalized)
        .map((entry) => model.LetterResult(
              letter: entry.letter,
              value: entry.kabir,
            ))
        .toList(growable: false);
  }

  String _normalizeArabic(String text) =>
      core.AbjadCalculator.normalizeArabic(text);

  int _getColor(int value) {
    if (value < 1) return 0xFF808080;
    const colors = <int>[
      0xFFE53935,
      0xFF43A047,
      0xFF1E88E5,
      0xFFFDD835,
      0xFFF5F5F5,
      0xFF212121,
      0xFFFFC107,
    ];
    return colors[(value - 1) % colors.length];
  }
}
