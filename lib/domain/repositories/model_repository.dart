import '../entities/models.dart';

abstract class ModelRepository {
  Future<ModelInfo> loadModel(String modelPath);
  Future<void> unloadModel(String modelId);
  Future<PredictionResult> predict(String input, Map<String, dynamic> params);
  Future<bool> isModelLoaded(String modelId);
  Future<List<ModelInfo>> getAvailableModels();
  Future<double> getModelAccuracy(String modelId);
}