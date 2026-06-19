import '../entities/abjad_result.dart';

abstract class AbjadRepository {
  Future<AbjadResult> calculate(String text, AbjadMethod method);
  Future<String> getElement(int value);
  Future<String> getPlanet(int value);
  Future<String> getZodiac(int value);
  Future<String> getDivineName(int value);
  Future<List<String>> getLetterValues(String text);
}