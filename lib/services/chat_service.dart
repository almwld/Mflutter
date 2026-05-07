import '../models/chat_message.dart';
import '../models/abjad_result.dart';
import '../models/verse.dart';
import 'abjad_service.dart';
import 'quran_service.dart';
import 'external_model_service.dart';

/// =============================================================================
/// ChatService - خدمة المحادثة
/// =============================================================================

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final AbjadService _abjadService = AbjadService();
  final QuranService _quranService = QuranService();
  final ExternalModelService _modelService = ExternalModelService();

  /// معالجة الاستعلام وبناء الإجابة
  Future<ChatResponse> processQuery(String query) async {
    // حساب الجمل
    final abjadResult = _abjadService.calculate(query);

    // البحث في القرآن
    final verses = await _quranService.search(query);

    // تشغيل النماذج
    final energyResult = await _modelService.runEnergyAnalysis(query);
    final patternResult = await _modelService.runPatternDiscovery(query);

    // بناء الإجابة
    final responseText = buildResponse(
      abjadResult: abjadResult,
      verses: verses,
      energy: energyResult,
      pattern: patternResult,
      query: query,
    );

    return ChatResponse(
      text: responseText,
      abjadResult: abjadResult,
      verses: verses.take(3).toList(),
      energy: energyResult,
      pattern: patternResult,
    );
  }

  /// بناء الإجابة
  String buildResponse({
    required AbjadResult abjadResult,
    required List<Verse> verses,
    required Map<String, dynamic> energy,
    required Map<String, dynamic> pattern,
    required String query,
  }) {
    final buffer = StringBuffer();

    // المقدمة
    buffer.writeln('✨ إليك نتائج تحليل طلبك:\n');

    // نتائج الجمل
    buffer.writeln('📊 حساب الجمل:');
    buffer.writeln('• الكبير: ${abjadResult.kabir}');
    buffer.writeln('• الصغير: ${abjadResult.saghir}');
    buffer.writeln('• الوسط: ${abjadResult.wasat}');
    buffer.writeln('• العنصر: ${abjadResult.element}');
    buffer.writeln('• الكوكب: ${abjadResult.planet}');
    buffer.writeln('• البرج: ${abjadResult.zodiac}');
    buffer.writeln('• الاسم الإلهي: ${abjadResult.divineName}');
    buffer.writeln('');

    // الآيات
    if (verses.isNotEmpty) {
      buffer.writeln('📖 آيات ذات صلة:');
      for (final verse in verses.take(2)) {
        buffer.writeln('• ${verse.text}');
        buffer.writeln('  (سورة ${verse.surah} - آية ${verse.ayah})');
        buffer.writeln('');
      }
    }

    // تحليل الطاقة
    if (energy['prediction'] != null) {
      buffer.writeln('⚡ تحليل الطاقة:');
      buffer.writeln('• المستوى: ${(energy['prediction'] as double * 100).toStringAsFixed(0)}%');
      buffer.writeln('');
    }

    // سؤال البصيرة
    buffer.writeln('💡 سؤال البصيرة:');
    buffer.writeln(_generateInsightQuestion(abjadResult));

    return buffer.toString();
  }

  /// توليد سؤال بصيرة
  String _generateInsightQuestion(AbjadResult abjad) {
    final questions = [
      'كيف يمكن لهذا الرقم ${abjad.kabir} أن يؤثر في قراراتك اليومية؟',
      'ما العلاقة بين عنصر "${abjad.element}" وروحانيتك؟',
      'كيف يمكنك استخدام كوكب "${abjad.planet}" في تحسين طاقتك؟',
      'ما البرج المناسب لك: "${abjad.zodiac}" - وكيف يؤثر في شخصيتك؟',
      'تأمل في الاسم "${abjad.divineName}" - كيف يمكن أن يغير حياتك؟',
      'كيف يؤثر تذبذب ${(abjad.frequency * 100).toStringAsFixed(0)}% على تفكيرك؟',
    ];
    return questions[abjad.kabir % questions.length];
  }

  /// الحصول على سياق المحادثة
  Map<String, dynamic> buildContext({
    required String query,
    required AbjadResult abjad,
    List<Verse>? verses,
  }) {
    return {
      'query': query,
      'abjad_value': abjad.kabir,
      'divine_name': abjad.divineName,
      'element': abjad.element,
      'planet': abjad.planet,
      'zodiac': abjad.zodiac,
      'verses': verses?.map((v) => {'surah': v.surah, 'ayah': v.ayah}).toList() ?? [],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// =============================================================================
/// ChatResponse - استجابة المحادثة
/// =============================================================================

class ChatResponse {
  final String text;
  final AbjadResult abjadResult;
  final List<Verse> verses;
  final Map<String, dynamic> energy;
  final Map<String, dynamic> pattern;

  ChatResponse({
    required this.text,
    required this.abjadResult,
    required this.verses,
    required this.energy,
    required this.pattern,
  });
}