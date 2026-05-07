import '../entities/divine_name.dart';
import '../repositories/divine_names_repository.dart';

class GetAllNamesUseCase {
  final DivineNamesRepository repository;

  GetAllNamesUseCase(this.repository);

  Future<List<DivineName>> call() async {
    return await repository.getAllNames();
  }
}

class GetNameUseCase {
  final DivineNamesRepository repository;

  GetNameUseCase(this.repository);

  Future<DivineName> call(int number) async {
    return await repository.getName(number);
  }
}

class SearchNamesUseCase {
  final DivineNamesRepository repository;

  SearchNamesUseCase(this.repository);

  Future<List<DivineName>> call(String query) async {
    return await repository.searchNames(query);
  }
}

class GetRandomNameUseCase {
  final DivineNamesRepository repository;

  GetRandomNameUseCase(this.repository);

  Future<DivineName> call() async {
    return await repository.getRandomName();
  }
}

class GetNamesByAttributeUseCase {
  final DivineNamesRepository repository;

  GetNamesByAttributeUseCase(this.repository);

  Future<List<DivineName>> call(AttributeType attribute) async {
    return await repository.getNamesByAttribute(attribute);
  }
}