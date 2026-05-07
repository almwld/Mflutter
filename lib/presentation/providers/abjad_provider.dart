import 'package:flutter/material.dart';
import '../../core/utils/abjad_calculator.dart';

/// =============================================================================
/// AbjadProvider - مزود الجُمَّل
/// =============================================================================

class AbjadProvider extends ChangeNotifier {
  dynamic _lastResult;
  List<LetterResult> _letterBreakdown = [];
  bool _isLoading = false;
  String? _error;

  // getters
  dynamic get lastResult => _lastResult;
  List<LetterResult> get letterBreakdown => _letterBreakdown;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// حساب الجمل
  Future<void> calculateAbjad(String text) async {
    if (text.trim().isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // حساب الجمل
      final result = AbjadCalculator.calculateAll(text);
      _lastResult = result;

      // حساب حرف بحرف
      _letterBreakdown = AbjadCalculator.calculateLetterByLetter(text);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// مسح النتائج
  void clearResults() {
    _lastResult = null;
    _letterBreakdown = [];
    _error = null;
    notifyListeners();
  }

  /// مسح الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// الحصول على العنصر
  String getElement(int value) {
    final element = (value % 5);
    const elements = ['روح', 'نار', 'ماء', 'تراب', 'هواء'];
    return elements[element];
  }

  /// الحصول على الكوكب
  String getPlanet(int value) {
    final planet = (value % 7);
    const planets = ['زُحل', 'شمس', 'قمر', 'مريخ', 'عطارد', 'زُهرة', 'مشتري'];
    return planets[planet];
  }

  /// الحصول على البرج
  String getZodiac(int value) {
    final zodiac = (value % 12);
    const zodiacs = [
      'الحمل', 'الثور', 'الجوزاء', 'السرطان', 'الأسد', 'العذراء',
      'الميزان', 'العقرب', 'القوس', 'الجدي', 'الدلو', 'الحوت',
    ];
    return zodiacs[zodiac];
  }

  /// الحصول على الاسم الإلهي
  String getDivineName(int value) {
    final index = value % 99;
    return DivineNames.arabicNames[index];
  }
}