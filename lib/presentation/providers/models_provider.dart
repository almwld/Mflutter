import 'package:flutter/material.dart';

class ModelsProvider extends ChangeNotifier {
  bool _loaded = false;

  bool get loaded => _loaded;

  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _loaded = true;
    notifyListeners();
  }
}
