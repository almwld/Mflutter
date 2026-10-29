import '../domain/entities/agent_ui_intent.dart';

/// Deterministic, local-first routing policy for agent-driven presentation.
/// Only allow-listed screen/template pairs can be emitted. General questions
/// remain in chat; the coordinator does not navigate for every user message.
class AgentUiCoordinator {
  const AgentUiCoordinator();

  static final RegExp _verseReference =
      RegExp(r'([0-9]{1,3})\s*[:/]\s*([0-9]{1,3})');

  AgentUiIntent? resolve(
    String rawQuery, {
    int? currentSurahNumber,
    int? currentAyahNumber,
  }) {
    final query = _normalize(rawQuery);
    if (query.isEmpty) return null;

    if (_containsAny(query, const [
      'حاله الوكلاء',
      'حاله النواه',
      'تفاعل النواه',
      'مراقبه الوكلاء',
      'شبكه الوكلاء',
      'اعرض النواه',
      'حاله النظام',
    ])) {
      return _intent(
        target: 'nucleus_screen',
        template: 'graph_template',
        query: rawQuery,
        payload: const {'visualization': 'agent_network'},
      );
    }

    if (_containsAny(query, const [
      'كم مره',
      'عدد مرات',
      'تكرار',
      'احصاء',
      'احصائي',
      'اعجاز عددي',
      'الحياه والموت',
    ])) {
      final words = _extractCountWords(query);
      return _intent(
        target: 'miracles_screen',
        template: 'analytics_template',
        query: rawQuery,
        payload: {
          'analysis_query': rawQuery,
          'first_word': words.$1,
          'second_word': words.$2,
          'source': 'local_quran_corpus',
          'requires_verified_counts': true,
        },
      );
    }

    if (_containsAny(query, const [
      'قارن',
      'مقارنه',
      'مقارنه ايات',
      'ترتيب الانبياء',
      'تسلسل الانبياء',
      'ارتباط الانبياء',
    ])) {
      return _intent(
        target: 'compare_screen',
        template: 'comparison_template',
        query: rawQuery,
        payload: {
          'comparison_query': rawQuery,
          'source': 'local_quran_corpus',
        },
      );
    }

    final asksToOpenReader = _containsAny(query, const [
      'افتح المصحف',
      'افتح الايه',
      'اعرض الايه',
      'اقرا الايه',
      'صفحه المصحف',
      'افتح صفحه المصحف',
    ]);
    if (asksToOpenReader) {
      final match = _verseReference.firstMatch(query);
      final surah = int.tryParse(match?.group(1) ?? '') ??
          currentSurahNumber ??
          1;
      final ayah = int.tryParse(match?.group(2) ?? '') ??
          currentAyahNumber ??
          1;
      if (surah < 1 || surah > 114 || ayah < 1) return null;
      return _intent(
        target: 'quran_page_screen',
        template: 'reader_template',
        query: rawQuery,
        payload: {
          'surah_number': surah,
          'ayah_number': ayah,
          'source': 'canonical_local_quran',
        },
      );
    }

    return null;
  }


  /// Wraps a schema assembled by a trusted domain service for universal
  /// rendering. Callers must pass actual service output; this method does not
  /// calculate metrics, create Quran text, or synthesize missing values.
  AgentUiIntent? resolveSchemaPayload({
    required String templateId,
    required String title,
    required String domain,
    required List<Map<String, dynamic>> blocks,
    required String source,
    String? originalQuery,
  }) {
    const supportedTemplates = <String>{
      'generic_template',
      'reader_template',
      'analytics_template',
      'comparison_template',
      'graph_template',
      'cosmic_template',
      'abjad_template',
      'agent_template',
    };
    if (!supportedTemplates.contains(templateId) || blocks.isEmpty) {
      return null;
    }
    return _intent(
      target: 'template_renderer',
      template: templateId,
      query: originalQuery ?? title,
      payload: {
        'schema_version': 1,
        'title': title,
        'domain': domain,
        'blocks': blocks,
        'source': source,
        'empty_message': 'لم تُرجع الخدمة بيانات قابلة للعرض.',
      },
    );
  }

  /// Extracts only explicit lexical targets. It deliberately does not guess
  /// a word from an arbitrary question, so the analytics screen never reports
  /// a count for an unrelated default word.
  (String?, String?) _extractCountWords(String normalizedQuery) {
    if (normalizedQuery.contains('الحياه والموت')) {
      return ('الحياة', 'الموت');
    }

    final explicit = RegExp(
      r'(?:كلمه|لفظ|لفظه)\s+([\u0621-\u064A]{2,})',
    ).firstMatch(normalizedQuery);
    if (explicit != null) return (explicit.group(1), null);

    final pair = RegExp(
      r'(?:ذكر|ورد|ظهور|ظهرت|تكرار)\s+([\u0621-\u064A]{2,})\s+و([\u0621-\u064A]{2,})',
    ).firstMatch(normalizedQuery);
    if (pair != null) return (pair.group(1), pair.group(2));

    final verbTarget = RegExp(
      r'(?:ذكر|ورد|ظهور|ظهرت|تكرار)\s+(?:كلمه\s+)?([\u0621-\u064A]{2,})',
    ).firstMatch(normalizedQuery);
    if (verbTarget != null) return (verbTarget.group(1), null);
    return (null, null);
  }

  AgentUiIntent _intent({
    required String target,
    required String template,
    required String query,
    required Map<String, dynamic> payload,
  }) {
    return AgentUiIntent(
      id: '${DateTime.now().microsecondsSinceEpoch}-$target',
      targetScreen: target,
      templateId: template,
      payload: {
        ...payload,
        'original_query': query,
      },
    );
  }

  bool _containsAny(String query, List<String> terms) =>
      terms.any(query.contains);

  String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAllMapped(
        RegExp(r'[٠-٩۰-۹]'),
        (match) {
          final code = match.group(0)!.codeUnitAt(0);
          final digit = code >= 0x06F0 ? code - 0x06F0 : code - 0x0660;
          return String.fromCharCode(0x30 + digit);
        },
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
