import '../../core/utils/abjad_calculator.dart';
import '../../domain/entities/abjad_result.dart';
import '../../domain/repositories/abjad_repository.dart';
import '../datasources/local/abjad_local_datasource.dart';

class AbjadRepositoryImpl implements AbjadRepository {
  final AbjadLocalDatasource localDatasource;
  final AbjadCalculator calculator;

  AbjadRepositoryImpl({
    required this.localDatasource,
    required this.calculator,
  });

  @override
  Future<AbjadResult> calculate(String text, AbjadMethod method) async {
    final result = calculator.calculate(text, method);
    return AbjadResult(
      text: text,
      method: method,
      value: result['value']!,
      letterValues: result['letters'] as Map<String, int>,
      element: calculator.getElement(result['value']!),
      planet: calculator.getPlanet(result['value']!),
      zodiac: calculator.getZodiac(result['value']!),
      divineName: calculator.getDivineName(result['value']!),
    );
  }

  @override
  Future<String> getElement(int value) async {
    return calculator.getElement(value);
  }

  @override
  Future<String> getPlanet(int value) async {
    return calculator.getPlanet(value);
  }

  @override
  Future<String> getZodiac(int value) async {
    return calculator.getZodiac(value);
  }

  @override
  Future<String> getDivineName(int value) async {
    return calculator.getDivineName(value);
  }

  @override
  Future<List<String>> getLetterValues(String text) async {
    return calculator.getLetterValues(text);
  }
}