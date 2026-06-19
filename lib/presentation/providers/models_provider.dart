import 'package:flutter/material.dart';

class ModelsProvider extends ChangeNotifier {
  String _selectedModel = 'mudabbir.gguf';
  final List<String> _availableModels = ['mudabbir.gguf', 'mudabbir_llm.gguf', 'mudabbir.tflite'];

  String get selectedModel => _selectedModel;
  List<String> get availableModels => _availableModels;

  void selectModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }
}
