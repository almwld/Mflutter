import 'package:flutter/material.dart';
import '../services/ollama_service.dart';
import '../services/nucleus_service.dart';

class SovereignChatProvider extends ChangeNotifier {
  SovereignChatProvider() {
    _core.addListener(_onRuntimeChanged);
  }

  final OllamaService _localAi = OllamaService();
  final NucleusService _core = NucleusService();

  void _onRuntimeChanged() => notifyListeners();

  bool get hasActiveLocalModel => _core.isModelLoaded || _localAi.isRunning;

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
      final prompt = 'أنت مُدَبِّر، مساعد معرفي محلي. أجب بالعربية الفصحى بدقة. '
          'لا تدّعِ امتلاك مصادر أو قدرات غير متاحة محلياً.\n'
          'التركيز: $focus\n'
          'البيئة: $topography\n'
          'الرنين العددي: $abjad\n\n'
          'السؤال: ${query.trim()}';
      if (_core.isModelLoaded) {
        _insight = await _core.generateGroundedAnswer(
          question: prompt,
          evidence: 'لم يتم إرفاق آيات قرآنية أو مصادر خارجية بهذه الشاشة؛ '
              'لا تنسب أقوالًا إلى القرآن أو مصادر غير متاحة.',
          maxTokens: 384,
        );
      } else {
        _insight = await _localAi.generate(prompt);
      }
    } catch (_) {
      _insight = 'تعذر الوصول إلى النموذج المحلي. تحقق من تشغيله ثم أعد المحاولة.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _core.removeListener(_onRuntimeChanged);
    super.dispose();
  }
}
