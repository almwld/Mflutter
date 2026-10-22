import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../services/ollama_service.dart';
import '../../services/local_gguf_runtime_service.dart';
import '../../services/quran_loader_service.dart';
import '../../services/quranic_search_engine.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider() {
    _gguf.addListener(_onGgufChanged);
  }

  final List<ChatMessage> _messages = [];
  final OllamaService _localAi = OllamaService();
  final LocalGgufRuntimeService _gguf = LocalGgufRuntimeService.instance;

  void _onGgufChanged() => notifyListeners();

  bool get hasActiveLocalModel => _gguf.isLoaded || _localAi.isRunning;

  bool _loading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get loading => _loading;
  String? get error => _error;

  String get localModelLabel {
    if (_gguf.isLoaded) return '3arabLM GGUF محمّل محليًا';
    if (_localAi.isRunning) return 'خادم Ollama المحلي متصل';
    return 'لا يوجد نموذج محمّل؛ افتح الوكلاء الفائقين لتحميل GGUF';
  }

  Future<bool> checkLocalModel() async {
    if (_gguf.isLoaded) return true;
    return _localAi.checkAvailability();
  }

  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _loading) return;

    _messages.add(ChatMessage(text: cleanText, isUser: true));
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final String reply;
      if (_gguf.isLoaded) {
        final ayahs = await QuranLoaderService.loadAllAyahs();
        QuranicSearchEngine.indexVerses(ayahs
            .map((ayah) => <String, String>{
                  'id': ayah.id.toString(),
                  'surah': ayah.surahName,
                  'ayah': ayah.ayahNumber.toString(),
                  'text': ayah.text,
                })
            .toList());
        final hits = QuranicSearchEngine.search(cleanText).take(5).toList();
        final evidence = hits.isEmpty
            ? 'لم يُعثر على تطابق نصي في assets/quran_full.json؛ لا تستخدم نصًا قرآنيًا غير موثق.'
            : hits
                .map((verse) =>
                    '${verse['surah']} ${verse['ayah']}: ${verse['text']} — المصدر: assets/quran_full.json')
                .join('\n');
        reply = await _gguf.generateGroundedAnswer(
          question: cleanText,
          evidence: evidence,
          maxTokens: 512,
        );
      } else {
        reply = await _localAi.generate(
          'أنت مُدَبِّر الْأَسْرَارِ الْعُلْيَا، مساعد معرفي محلي. '
          'أجب بالعربية الفصحى بدقة ووضوح، ولا تدّعِ امتلاك مصادر غير متاحة محلياً.\n\n'
          'المستخدم: $cleanText\n\nمُدَبِّر:',
        );
      }

      _messages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _error = e.toString();
      _messages.add(ChatMessage(
        text: _gguf.isLoaded
            ? 'تعذر الاستدلال باستخدام نموذج GGUF المحلي. راجع حالة النموذج في شاشة الوكلاء الفائقين.'
            : 'تعذر الوصول إلى نموذج محلي. حمّل GGUF من شاشة الوكلاء الفائقين أو تحقق من خادم Ollama.',
        isUser: false,
      ));
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _gguf.removeListener(_onGgufChanged);
    super.dispose();
  }
}
