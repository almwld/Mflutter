import 'package:flutter/material.dart';
import '../services/ollama_service.dart';

class SovereignChatProvider extends ChangeNotifier {
  final OllamaService _localAi = OllamaService();
  bool _isLoading = false;
  String _insight = '';

  bool get isLoading => _isLoading;
  String get insight => _insight;

  Future<void> fetchInsight({
    required String query,
    required double focus,
    required String topography,
    required int abjad,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    _insight = '';
    notifyListeners();

    try {
      _insight = await _localAi.generate(
        'أنت مُدَبِّر، مساعد معرفي محلي. أجب بالعربية الفصحى بدقة. '
        'لا تدّعِ امتلاك مصادر أو قدرات غير متاحة محلياً.\n'
        'التركيز: ' + focus.toString() + '\n'
        'البيئة: ' + topography + '\n'
        'الرنين: ' + abjad.toString() + '\n\n'
        'السؤال: ' + query.trim(),
      );
    } catch (_) {
      _insight = 'تعذر الوصول إلى النموذج المحلي. تحقق من تشغيله ثم أعد المحاولة.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
