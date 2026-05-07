import 'package:flutter/material.dart';
import '../services/abjad_service.dart';
import '../models/abjad_result.dart';
import '../services/abjad_service.dart' as service;

/// =============================================================================
/// AbjadProvider - مزود حالة الجمل
/// =============================================================================

class AbjadProvider extends ChangeNotifier {
  final service.AbjadService _abjadService = service.AbjadService();

  AbjadResult? _lastResult;
  List<LetterResult> _letterResults = [];
  bool _isCalculating = false;
  String _inputText = '';

  AbjadResult? get lastResult => _lastResult;
  List<LetterResult> get letterResults => _letterResults;
  bool get isCalculating => _isCalculating;
  String get inputText => _inputText;

  /// حساب الجمل
  Future<void> calculate(String text) async {
    if (text.trim().isEmpty) return;

    _inputText = text;
    _isCalculating = true;
    notifyListeners();

    try {
      // حساب الجمل
      final result = _abjadService.calculate(text);

      // تحويل النتيجة
      _lastResult = AbjadResult(
        kabir: result.kabir,
        saghir: result.saghir,
        wasat: result.wasat,
        element: result.element,
        planet: result.planet,
        zodiac: result.zodiac,
        divineName: result.divineName,
        frequency: result.frequency,
        color: result.color,
        letterResults: result.letterResults,
      );

      _letterResults = result.letterResults;
    } catch (e) {
      _lastResult = null;
      _letterResults = [];
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  /// مسح النتائج
  void clear() {
    _lastResult = null;
    _letterResults = [];
    _inputText = '';
    notifyListeners();
  }

  /// تحديث النص المدخل
  void updateInput(String text) {
    _inputText = text;
    notifyListeners();
  }
}

/// =============================================================================
/// AbjadResult - نموذج نتيجة الجمل
/// =============================================================================

class AbjadResult {
  final int kabir;
  final int saghir;
  final int wasat;
  final String element;
  final String planet;
  final String zodiac;
  final String divineName;
  final double frequency;
  final int color;
  final List<LetterResult> letterResults;

  AbjadResult({
    required this.kabir,
    required this.saghir,
    required this.wasat,
    required this.element,
    required this.planet,
    required this.zodiac,
    required this.divineName,
    required this.frequency,
    required this.color,
    required this.letterResults,
  });
}