import '../entities/divine_name.dart';

abstract class DivineNamesRepository {
  Future<List<DivineName>> getAllNames();
  Future<DivineName> getName(int number);
  Future<List<DivineName>> searchNames(String query);
  Future<DivineName> getRandomName();
  Future<List<DivineName>> getNamesByAttribute(AttributeType attribute);
}