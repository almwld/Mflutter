import 'package:flutter/material.dart';
import '../../domain/entities/abjad_result.dart';

class AbjadProvider extends ChangeNotifier {
  AbjadResult? _result;

  AbjadResult? get result => _result;

  void calculate(String text) {
    _result = AbjadResult.fromText(text);
    notifyListeners();
  }
}
