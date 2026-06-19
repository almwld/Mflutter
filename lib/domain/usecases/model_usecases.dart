import '../entities/models.dart';
import '../repositories/model_repository.dart';

class LoadModelUseCase {
  final ModelRepository repository;

  LoadModelUseCase(this.repository);

  Future<ModelInfo> call(String modelPath) async {
    return await repository.loadModel(modelPath);
  }
}

class UnloadModelUseCase {
  final ModelRepository repository;

  UnloadModelUseCase(this.repository);

  Future<void> call(String modelId) async {
    await repository.unloadModel(modelId);
  }
}

class PredictUseCase {
  final ModelRepository repository;

  PredictUseCase(this.repository);

  Future<PredictionResult> call(String input, Map<String, dynamic> params) async {
    return await repository.predict(input, params);
  }
}

class IsModelLoadedUseCase {
  final ModelRepository repository;

  IsModelLoadedUseCase(this.repository);

  Future<bool> call(String modelId) async {
    return await repository.isModelLoaded(modelId);
  }
}

class GetAvailableModelsUseCase {
  final ModelRepository repository;

  GetAvailableModelsUseCase(this.repository);

  Future<List<ModelInfo>> call() async {
    return await repository.getAvailableModels();
  }
}