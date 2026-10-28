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
    buffer.writeln('إليك نتائج الحسابات المحلية ومخرجات النماذج المتاحة:\n');

    // نتائج الجمل
    buffer.writeln('📊 حساب الجمل:');
    buffer.writeln('• الكبير: ${abjadResult.kabir}');
    buffer.writeln('• الصغير: ${abjadResult.saghir}');
    buffer.writeln('• الوسط: ${abjadResult.wasat}');
    buffer.writeln('• العنصر الرمزي: ${abjadResult.element}');
    buffer.writeln('• الكوكب الرمزي: ${abjadResult.planet}');
    buffer.writeln('• البرج الرمزي: ${abjadResult.zodiac}');
    buffer.writeln('• الاسم حسب ترتيب القائمة: ${abjadResult.divineName}');
    buffer.writeln(
      'هذه روابط اصطلاحية من جداول رمزية وليست قياسات علمية أو تنبؤات.',
    );
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

    // Generic model output is shown as raw data, not mislabeled as energy.
    if (energy['prediction'] is num) {
      buffer.writeln('مخرج النموذج المحلي (قيمة خام غير مفسّرة):');
      buffer.writeln('• القيمة الأولى: ${(energy['prediction'] as num).toString()}');
      final rawOutputs = energy['raw_outputs'];
      if (rawOutputs is List) {
        buffer.writeln('• عدد قيم المخرجات: ${rawOutputs.length}');
      }
      buffer.writeln(
        'هذا الرقم ليس قياسًا للطاقة أو تشخيصًا أو استنتاجًا علميًا؛ '
        'يلزم توثيق مهمة النموذج قبل تفسيره.',
      );
      buffer.writeln('');
    } else if (energy['error'] != null) {
      buffer.writeln('النموذج المحلي: ${energy['error']}');
      buffer.writeln('');
    }

    if (pattern['supported'] == false || pattern['error'] != null) {
      buffer.writeln('اكتشاف الأنماط: غير متاح لهذا النموذج العام.');
      buffer.writeln((pattern['error'] ?? 'لا توجد نتيجة موثقة.').toString());
      buffer.writeln('');
    }

    // سؤال البصيرة
    buffer.writeln('سؤال تأملي اختياري:');
    buffer.writeln(_generateInsightQuestion(abjadResult));
    buffer.writeln(
      'تنبيه: الأسئلة التأملية وحسابات الجمل لا تمثل تفسيرًا للقرآن '
      'ولا دليلًا علميًا على علاقة سببية.',
    );

    return buffer.toString();
  }

  /// توليد سؤال بصيرة
  String _generateInsightQuestion(AbjadResult abjad) {
    final questions = [
      'ما الذي تريد التحقق منه في قيمة أبجد ${abjad.kabir} بوصفها حسابًا حرفيًا؟',
      'هل تريد مراجعة مصدر موثوق لمعنى الاسم ${abjad.divineName}؟',
      'ما السياق النصي الذي يساعد على فهم الآيات ذات الصلة؟',
      'ما الافتراضات التي ينبغي اختبارها قبل استنتاج نمط؟',
      'هل تريد مقارنة قيمة الحروف وفق جدول أبجد المعلن؟',
      'كيف يمكن فصل التأمل الشخصي عن الدليل النصي القابل للتحقق؟',
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