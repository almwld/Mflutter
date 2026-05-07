import '../../domain/entities/divine_name.dart';
import '../../domain/repositories/divine_names_repository.dart';
import '../datasources/local/abjad_local_datasource.dart';

class DivineNamesRepositoryImpl implements DivineNamesRepository {
  final AbjadLocalDatasource localDatasource;

  DivineNamesRepositoryImpl({required this.localDatasource});

  @override
  Future<List<DivineName>> getAllNames() async {
    return await localDatasource.getAllDivineNames();
  }

  @override
  Future<DivineName> getName(int number) async {
    return await localDatasource.getDivineName(number);
  }

  @override
  Future<List<DivineName>> searchNames(String query) async {
    return await localDatasource.searchDivineNames(query);
  }

  @override
  Future<DivineName> getRandomName() async {
    return await localDatasource.getRandomDivineName();
  }

  @override
  Future<List<DivineName>> getNamesByAttribute(AttributeType attribute) async {
    return await localDatasource.getDivineNamesByAttribute(attribute);
  }
}