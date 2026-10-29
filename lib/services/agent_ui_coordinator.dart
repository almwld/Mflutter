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
      return _intent(
        target: 'miracles_screen',
        template: 'analytics_template',
        query: rawQuery,
        payload: {
          'analysis_query': rawQuery,
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
