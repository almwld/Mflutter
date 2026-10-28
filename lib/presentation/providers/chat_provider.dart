import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../services/ollama_service.dart';
import '../../services/nucleus_service.dart';
import '../../services/quran_loader_service.dart';
import '../../services/quranic_search_engine.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider() {
    _core.addListener(_onGgufChanged);
  }

  final List<ChatMessage> _messages = [];
  final OllamaService _localAi = OllamaService();
  final NucleusService _core = NucleusService();

  // Quran data is immutable for the lifetime of this provider. Keep one
  // shared indexing future so consecutive messages do not reload and rebuild
  // the 6,236-verse search index every time.
  Future<void>? _quranIndexFuture;

  void _onGgufChanged() => notifyListeners();

  bool get hasActiveLocalModel => _core.isModelLoaded || _localAi.isRunning;

  bool _loading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get loading => _loading;
  String? get error => _error;

  String get localModelLabel {
    if (_core.isModelLoaded) return '3arabLM GGUF محمّل محليًا';
    if (_localAi.isRunning) return 'خادم Ollama المحلي متصل';
    return 'لا يوجد نموذج محمّل؛ افتح الوكلاء الفائقين لتحميل GGUF';
  }

  Future<bool> checkLocalModel() async {
    if (_core.isModelLoaded) return true;
    return _localAi.checkAvailability();
  }

  Future<void> _ensureQuranIndex() {
    final cached = _quranIndexFuture;
    if (cached != null) return cached;

    final build = _buildQuranIndex();
    _quranIndexFuture = build;
    return build.catchError((Object error) {
      // Permit retry if reading or indexing failed; never cache a failed load.
      if (identical(_quranIndexFuture, build)) {
        _quranIndexFuture = null;
      }
      throw error;
    });
  }

  Future<void> _buildQuranIndex() async {
    final ayahs = await QuranLoaderService.loadAllAyahs();
    QuranicSearchEngine.indexVerses(ayahs
        .map((ayah) => <String, String>{
              'id': ayah.id.toString(),
              'surah': ayah.surahName,
              'ayah': ayah.ayahNumber.toString(),
              'text': ayah.text,
            })
        .toList(growable: false));
  }

  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _loading) return;

    _messages.add(ChatMessage(text: cleanText, isUser: true));
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _ensureQuranIndex();
      final hits = QuranicSearchEngine.search(cleanText).take(5).toList();
      final evidence = hits.isEmpty
          ? 'لم يعثر البحث المحلي على شاهد قرآني مطابق. أجب عن السؤال العام إن أمكن، ولا تقتبس آية أو تنسب نصًا إلى القرآن دون شاهد موثق.'
          : hits
              .map((verse) =>
                  '${verse['surah']} ${verse['ayah']}: ${verse['text']} — المصدر: assets/quran_full.json')
              .join('\n');

      final String generated;
      if (_core.isModelLoaded) {
        generated = await _core.generateGroundedAnswer(
          question: cleanText,
          evidence: evidence,
          maxTokens: 512,
        );
      } else {
        generated = await _localAi.generate(
          'أنت مُدَبِّر الْأَسْرَارِ الْعُلْيَا، مساعد معرفي محلي. '
          'أجب عن السؤال مباشرة بالعربية الفصحى متى أمكن. عدم العثور على آية مطابقة ليس سببًا لرفض سؤال عام. لا تنسب نصًا إلى القرآن إلا إذا ظهر في الأدلة، '
          'لا تدّعِ امتلاك مصادر غير متاحة محلياً.\n\n'
          'المستخدم: $cleanText\n\nالأدلة المحلية:\n$evidence\n\nمُدَبِّر:',
        );
      }
      final evidenceNote = hits.isEmpty
          ? 'ملاحظة: لم يُرفق استشهاد قرآني لأن البحث المحلي لم يجد تطابقًا؛ هذا لا يمنع الإجابة عن الأسئلة العامة.'
          : 'الأدلة المحلية للمراجعة (ليست جزءًا من النص المولّد):\n$evidence';
      final reply = '$generated\n\n$evidenceNote';

      _messages.add(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _error = e.toString();
      _messages.add(ChatMessage(
        text: _core.isModelLoaded
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
    _core.removeListener(_onGgufChanged);
    super.dispose();
  }
}
