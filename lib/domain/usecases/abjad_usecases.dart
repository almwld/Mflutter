import '../entities/abjad_result.dart';
import '../repositories/abjad_repository.dart';

class CalculateAbjadUseCase {
  final AbjadRepository repository;

  CalculateAbjadUseCase(this.repository);

  Future<AbjadResult> call(String text, AbjadMethod method) async {
    return await repository.calculate(text, method);
  }
}

class GetElementUseCase {
  final AbjadRepository repository;

  GetElementUseCase(this.repository);

  Future<String> call(int value) async {
    return await repository.getElement(value);
  }
}

class GetPlanetUseCase {
  final AbjadRepository repository;

  GetPlanetUseCase(this.repository);

  Future<String> call(int value) async {
    return await repository.getPlanet(value);
  }
}

class GetZodiacUseCase {
  final AbjadRepository repository;

  GetZodiacUseCase(this.repository);

  Future<String> call(int value) async {
    return await repository.getZodiac(value);
  }
}

class GetDivineNameUseCase {
  final AbjadRepository repository;

  GetDivineNameUseCase(this.repository);

  Future<String> call(int value) async {
    return await repository.getDivineName(value);
  }
}