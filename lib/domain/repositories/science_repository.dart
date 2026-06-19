import '../entities/science.dart';

abstract class ScienceRepository {
  Future<List<Science>> getAllSciences();
  Future<Science> getScience(ScienceType type);
  Future<List<Letter>> getLetters();
  Future<List<Number>> getNumbers();
  Future<List<Element> >getElements();
  Future<List<Planet>> getPlanets();
  Future<List<ZodiacSign>> getZodiacSigns();
}