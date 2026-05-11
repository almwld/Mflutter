import 'package:flutter/material.dart';
import '../../domain/entities/abjad_result.dart';

class AbjadProvider extends ChangeNotifier {
  AbjadResult? _lastResult;

  AbjadResult? get lastResult => _lastResult;

  void calculateAbjad(String text) {
    _lastResult = AbjadResult.fromText(text);
    notifyListeners();
  }
}
