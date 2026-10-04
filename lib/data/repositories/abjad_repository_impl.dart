import '../../core/utils/abjad_calculator.dart' as core;
import '../../domain/entities/abjad_result.dart';
import '../../domain/repositories/abjad_repository.dart';

class AbjadRepositoryImpl implements AbjadRepository {
  @override
  Future<AbjadResult> calculate(String text, AbjadMethod method) async {
    final all = core.AbjadCalculator.calculateAll(text);
    return AbjadResult(major: all.kabir, minor: all.saghir, middle: all.wasat, element: all.element.name, planet: all.planet.name, zodiac: all.zodiac.name, divineName: all.divineName, frequency: all.frequency.toDouble(), color: int.tryParse(all.color.replaceFirst('#', ''), radix: 16) ?? 0xFF1A237E);
  }
  @override Future<String> getElement(int value) async => const ['spirit','fire','water','earth','air'][value % 5];
  @override Future<String> getPlanet(int value) async => const ['saturn','sun','moon','mars','mercury','venus','jupiter'][value % 7];
  @override Future<String> getZodiac(int value) async => core.ZodiacType.values[value % core.ZodiacType.values.length].name;
  @override Future<String> getDivineName(int value) async => core.DivineNames.arabicNames[value % core.DivineNames.arabicNames.length];
  @override Future<List<String>> getLetterValues(String text) async => core.AbjadCalculator.calculateLetterByLetter(text).map((x) => '${x.letter}: ${x.kabir}').toList();
}
