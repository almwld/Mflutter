import '../../domain/entities/science.dart';
import '../../domain/repositories/science_repository.dart';
import '../datasources/local/abjad_local_datasource.dart';

class ScienceRepositoryImpl implements ScienceRepository {
  final AbjadLocalDatasource localDatasource;

  ScienceRepositoryImpl({required this.localDatasource});

  @override
  Future<List<Science>> getAllSciences() async {
    return [
      Science(type: ScienceType.letters, name: 'علم الحروف', description: 'علم الحروف وأثره في الكشف', count: 28),
      Science(type: ScienceType.numbers, name: 'علم الأعداد', description: 'علم الأرقام ومعانيها', count: 10),
      Science(type: ScienceType.elements, name: 'علم العناصر', description: 'علم العناصر الأربعة وأثرها', count: 5),
      Science(type: ScienceType.planets, name: 'علم الكواكب', description: 'علم تأثير الكواكب', count: 7),
      Science(type: ScienceType.zodiac, name: 'علم الأبراج', description: 'علم الأبراج الإثني عشر', count: 12),
      Science(type: ScienceType.names, name: 'علم الأسماء', description: 'علم الأسماء الإلهية', count: 99),
    ];
  }

  @override
  Future<Science> getScience(ScienceType type) async {
    final sciences = await getAllSciences();
    return sciences.firstWhere((s) => s.type == type);
  }

  @override
  Future<List<Letter>> getLetters() async {
    return await localDatasource.getLetters();
  }

  @override
  Future<List<Number>> getNumbers() async {
    return await localDatasource.getNumbers();
  }

  @override
  Future<List<Element>> getElements() async {
    return await localDatasource.getElements();
  }

  @override
  Future<List<Planet>> getPlanets() async {
    return await localDatasource.getPlanets();
  }

  @override
  Future<List<ZodiacSign>> getZodiacSigns() async {
    return await localDatasource.getZodiacSigns();
  }
}