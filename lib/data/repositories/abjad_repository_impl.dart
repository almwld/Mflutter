import '../../core/utils/abjad_calculator.dart' as core;
import '../../domain/entities/abjad_result.dart';
import '../../domain/repositories/abjad_repository.dart';
import '../../utils/abjad_constants.dart';

class AbjadRepositoryImpl implements AbjadRepository {
  static const Map<String, int> _colorValues = {
    'أحمر': 0xFFE53935,
    'أخضر': 0xFF43A047,
    'أزرق': 0xFF1E88E5,
    'أصفر': 0xFFFDD835,
    'أبيض': 0xFFF5F5F5,
    'أسود': 0xFF212121,
    'ذهبي': 0xFFFFC107,
  };

  @override
  Future<AbjadResult> calculate(String text, AbjadMethod method) async {
    // Return all three explicitly defined local calculations. The requested
    // method is retained for repository compatibility; callers can select the
    // relevant field without discarding the other transparent results.
    final all = core.AbjadCalculator.calculateAll(text);
    return AbjadResult(
      major: all.kabir,
      minor: all.saghir,
      middle: all.wasat,
      element: all.kabir < 1 ? 'غير محدد' : all.element.name,
      planet: all.kabir < 1 ? 'غير محدد' : all.planet.name,
      zodiac: all.kabir < 1 ? 'غير محدد' : all.zodiac.name,
      divineName: all.divineName,
      frequency: 0,
      color: _colorValues[all.color] ?? 0xFF1A237E,
    );
  }

  @override
  Future<String> getElement(int value) async =>
      value < 1 ? 'غير محدد' : AbjadConstants.getElementByNumber(value);

  @override
  Future<String> getPlanet(int value) async =>
      value < 1 ? 'غير محدد' : AbjadConstants.getPlanetByNumber(value);

  @override
  Future<String> getZodiac(int value) async =>
      value < 1 ? 'غير محدد' : AbjadConstants.getZodiacByNumber(value);

  @override
  Future<String> getDivineName(int value) async =>
      value < 1 ? 'غير محدد' : AbjadConstants.getDivineNameByNumber(value);

  @override
  Future<List<String>> getLetterValues(String text) async =>
      core.AbjadCalculator.calculateLetterByLetter(text)
          .map((letter) => '${letter.letter}: ${letter.kabir}')
          .toList(growable: false);
}
