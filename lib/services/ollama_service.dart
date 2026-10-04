import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Local AI gateway.
///
/// The app never contains provider API keys and never launches a shell,
/// Termux process, or remote AI provider. A local Ollama-compatible endpoint
/// is used instead. The endpoint/model can be changed at runtime.
class OllamaService {
  static final OllamaService _instance = OllamaService._();
  factory OllamaService() => _instance;
  OllamaService._();

  static const String defaultBaseUrl = 'http://127.0.0.1:11434';
  static const String defaultModel = 'mudabbir';

  String _baseUrl = defaultBaseUrl;
  String _modelName = defaultModel;

  String get baseUrl => _baseUrl;
  String get modelName => _modelName;

  bool _available = false;
  bool get isRunning => _available;

  void configure({String? baseUrl, String? modelName}) {
    if (baseUrl != null && baseUrl.trim().isNotEmpty) {
      _baseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    }
    if (modelName != null && modelName.trim().isNotEmpty) {
      _modelName = modelName.trim();
    }
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<bool> checkAvailability() async {
    try {
      final response = await http
          .get(_uri('/api/tags'))
          .timeout(const Duration(seconds: 3));
      _available = response.statusCode == 200;
      return _available;
    } catch (_) {
      _available = false;
      return false;
    }
  }

  Future<bool> hasModel([String? name]) async {
    try {
      final response = await http
          .get(_uri('/api/tags'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final models = (data['models'] as List<dynamic>? ?? const []);
      final target = (name ?? _modelName).trim();

      return models.any((item) {
        final model = item as Map<String, dynamic>;
        final value = (model['name'] ?? model['model'] ?? '').toString();
        return value == target || value.startsWith('$target:');
      });
    } catch (_) {
      return false;
    }
  }

  Future<String> generate(
    String prompt, {
    double temperature = 0.7,
    int maxTokens = 600,
  }) async {
    final cleanPrompt = prompt.trim();
    if (cleanPrompt.isEmpty) return '';

    final response = await http
        .post(
          _uri('/api/generate'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': _modelName,
            'prompt': cleanPrompt,
            'stream': false,
            'options': {
              'temperature': temperature,
              'num_predict': maxTokens,
              'top_k': 40,
              'top_p': 0.9,
            },
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      throw Exception('Local model returned HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result = (data['response'] ?? '').toString().trim();
    if (result.isEmpty) {
      throw Exception('Local model returned an empty response');
    }

    _available = true;
    return result;
  }

  /// Compatibility helper for existing callers.
  Future<bool> startServer() => checkAvailability();

  /// The app does not own the local model process.
  void stopServer() {
    _available = false;
    debugPrint('Local AI gateway disconnected');
  }
}
