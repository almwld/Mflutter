import 'package:flutter/material.dart';
import '../services/nucleus_service.dart';

/// =============================================================================
/// ThemeProvider - مزود حالة الثيم
/// =============================================================================

class ThemeProvider extends ChangeNotifier {
  final NucleusService _nucleusService = NucleusService();

  bool _isDarkMode = true;
  double _fontScale = 1.0;
  String _language = 'ar';

  bool get isDarkMode => _isDarkMode;
  double get fontScale => _fontScale;
  String get language => _language;

  /// تهيئة الثيم
  Future<void> initialize() async {
    await _nucleusService.loadNucleus();
    final uiSettings = _nucleusService.getUISettings();

    _isDarkMode = uiSettings['theme'] == 'dark';
    _fontScale = (uiSettings['fontScale'] ?? 1.0) as double;
    _language = uiSettings['language'] ?? 'ar';

    notifyListeners();
  }

  /// تبديل الوضع الداكن
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// تغيير حجم الخط
  void setFontScale(double scale) {
    _fontScale = scale.clamp(0.8, 1.5);
    notifyListeners();
  }

  /// تغيير اللغة
  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }

  /// الحصول على الألوان
  Map<String, int> get colors => _nucleusService.getColors();
}