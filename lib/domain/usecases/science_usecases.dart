import '../entities/science.dart';
import '../repositories/science_repository.dart';

class GetAllSciencesUseCase {
  final ScienceRepository repository;

  GetAllSciencesUseCase(this.repository);

  Future<List<Science>> call() async {
    return await repository.getAllSciences();
  }
}

class GetScienceUseCase {
  final ScienceRepository repository;

  GetScienceUseCase(this.repository);

  Future<Science> call(ScienceType type) async {
    return await repository.getScience(type);
  }
}

class GetLettersUseCase {
  final ScienceRepository repository;

  GetLettersUseCase(this.repository);

  Future<List<Letter>> call() async {
    return await repository.getLetters();
  }
}

class GetNumbersUseCase {
  final ScienceRepository repository;

  GetNumbersUseCase(this.repository);

  Future<List<Number>> call() async {
    return await repository.getNumbers();
  }
}

class GetElementsUseCase {
  final ScienceRepository repository;

  GetElementsUseCase(this.repository);

  Future<List<Element>> call() async {
    return await repository.getElements();
  }
}

class GetPlanetsUseCase {
  final ScienceRepository repository;

  GetPlanetsUseCase(this.repository);

  Future<List<Planet>> call() async {
    return await repository.getPlanets();
  }
}

class GetZodiacSignsUseCase {
  final ScienceRepository repository;

  GetZodiacSignsUseCase(this.repository);

  Future<List<ZodiacSign>> call() async {
    return await repository.getZodiacSigns();
  }
}