import '../../domain/entities/models.dart';
import '../../domain/repositories/model_repository.dart';
import '../datasources/external/tflite_datasource.dart';

class ModelRepositoryImpl implements ModelRepository {
  final TFLiteDatasource tfliteDatasource;
  final Map<String, ModelInfo> _loadedModels = {};

  ModelRepositoryImpl({required this.tfliteDatasource});

  @override
  Future<ModelInfo> loadModel(String modelPath) async {
    final modelInfo = await tfliteDatasource.loadModel(modelPath);
    _loadedModels[modelInfo.id] = modelInfo;
    return modelInfo;
  }

  @override
  Future<void> unloadModel(String modelId) async {
    await tfliteDatasource.unloadModel(modelId);
    _loadedModels.remove(modelId);
  }

  @override
  Future<PredictionResult> predict(String input, Map<String, dynamic> params) async {
    return await tfliteDatasource.predict(input, params);
  }

  @override
  Future<bool> isModelLoaded(String modelId) async {
    return _loadedModels.containsKey(modelId);
  }

  @override
  Future<List<ModelInfo>> getAvailableModels() async {
    return await tfliteDatasource.getAvailableModels();
  }

  @override
  Future<double> getModelAccuracy(String modelId) async {
    final model = _loadedModels[modelId];
    return model?.accuracy ?? 0.0;
  }
}