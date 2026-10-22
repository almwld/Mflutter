import 'dart:io';

import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Android-only llama.cpp runtime. Model bytes stay in app-private storage;
/// no cloud provider or remote fallback is used.
class LocalGgufService {
  LocalGgufService._();
  static final LocalGgufService instance = LocalGgufService._();

  static const _pathKey = 'mudabbir.local_gguf_path';
  static const _nameKey = 'mudabbir.local_gguf_name';
  static const _directoryName = 'local_gguf_models';

  LlamaController? _controller;
  String? _modelPath;
  String? _modelName;
  bool _loading = false;
  bool _generating = false;

  bool get isLoaded => _controller != null && _modelPath != null;
  bool get isLoading => _loading;
  bool get isGenerating => _generating;
  String? get modelPath => _modelPath;
  String? get modelName => _modelName;

  Future<Directory> _modelDirectory() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/$_directoryName');
    await directory.create(recursive: true);
    return directory;
  }

  Future<String?> getSavedModelPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pathKey);
  }

  Future<String> importModel(String sourcePath) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('تشغيل GGUF المضمّن متاح حالياً على Android فقط.');
    }
    final source = File(sourcePath);
    if (!await source.exists()) throw StateError('ملف النموذج غير موجود.');
    if (!source.path.toLowerCase().endsWith('.gguf')) {
      throw ArgumentError('اختر ملف نموذج بامتداد .gguf.');
    }
    final fileName = source.uri.pathSegments.isEmpty
        ? 'model.gguf'
        : source.uri.pathSegments.last;
    final directory = await _modelDirectory();
    final target = File('${directory.path}/$fileName');
    if (source.absolute.path != target.absolute.path) {
      await source.copy(target.path);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pathKey, target.path);
    await prefs.setString(_nameKey, fileName);
    await loadModel(target.path, modelName: fileName);
    return fileName;
  }

  Future<void> loadSavedModel() async {
    if (!Platform.isAndroid || isLoaded || _loading) return;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_pathKey);
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (!await file.exists()) {
      await prefs.remove(_pathKey);
      await prefs.remove(_nameKey);
      return;
    }
    await loadModel(path, modelName: prefs.getString(_nameKey) ?? file.uri.pathSegments.last);
  }

  Future<void> loadModel(String path, {String? modelName}) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('تشغيل GGUF المضمّن متاح حالياً على Android فقط.');
    }
    if (_loading) throw StateError('تحميل نموذج محلي جارٍ بالفعل.');
    final file = File(path);
    if (!await file.exists()) throw StateError('ملف النموذج غير موجود: $path');

    _loading = true;
    try {
      await _controller?.dispose();
      _controller = null;
      final controller = LlamaController();
      var gpuLayers = 0;
      try {
        final gpu = await controller.detectGpu();
        gpuLayers = gpu.recommendedGpuLayers;
        if (gpu.freeRamBytes < 2 * 1024 * 1024 * 1024) gpuLayers = 0;
      } catch (_) {
        gpuLayers = 0;
      }

      final processors = Platform.numberOfProcessors;
      final threads = processors < 2 ? 2 : (processors > 4 ? 4 : processors);
      final freeRamBytes = await _safeFreeRam(controller);
      final contextSize = freeRamBytes != null && freeRamBytes < 2 * 1024 * 1024 * 1024
          ? 1024
          : 2048;
      await controller.loadModel(
        modelPath: file.path,
        threads: threads,
        contextSize: contextSize,
        gpuLayers: gpuLayers,
      );
      _controller = controller;
      _modelPath = file.path;
      _modelName = modelName ?? file.uri.pathSegments.last;
    } catch (error) {
      await _controller?.dispose();
      _controller = null;
      _modelPath = null;
      _modelName = null;
      rethrow;
    } finally {
      _loading = false;
    }
  }

  Future<int?> _safeFreeRam(LlamaController controller) async {
    try {
      final gpu = await controller.detectGpu();
      return gpu.freeRamBytes;
    } catch (_) {
      return null;
    }
  }

  Stream<String> generateChat({
    required String systemPrompt,
    required String userPrompt,
    int maxTokens = 768,
    double temperature = 0.65,
  }) {
    final controller = _controller;
    if (controller == null) {
      throw StateError('لم يتم تحميل نموذج GGUF محلي. استورد ملفاً أولاً.');
    }
    if (_generating) throw StateError('التوليد المحلي جارٍ بالفعل.');
    _generating = true;
    return controller.generateChat(
      messages: [
        ChatMessage(role: 'system', content: systemPrompt),
        ChatMessage(role: 'user', content: userPrompt),
      ],
      maxTokens: maxTokens,
      temperature: temperature,
      topP: 0.9,
      topK: 40,
      repeatPenalty: 1.12,
    ).transform(
      StreamTransformer<String, String>.fromHandlers(
        handleData: (token, sink) => sink.add(token),
        handleDone: (sink) {
          _generating = false;
          sink.close();
        },
        handleError: (error, stack, sink) {
          _generating = false;
          sink.addError(error, stack);
        },
      ),
    );
  }

  Future<String> generateOnce({
    required String systemPrompt,
    required String userPrompt,
    int maxTokens = 768,
    double temperature = 0.65,
  }) async {
    final buffer = StringBuffer();
    await for (final token in generateChat(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: maxTokens,
      temperature: temperature,
    )) {
      buffer.write(token);
    }
    final output = buffer.toString().trim();
    if (output.isEmpty) throw StateError('لم يُنتج النموذج المحلي نصاً.');
    return output;
  }

  Future<void> stop() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.stop();
    _generating = false;
  }

  Future<void> unloadModel() async {
    await stop();
    await _controller?.dispose();
    _controller = null;
    _modelPath = null;
    _modelName = null;
  }

  Future<void> forgetModel() async {
    await unloadModel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pathKey);
    await prefs.remove(_nameKey);
  }
}
