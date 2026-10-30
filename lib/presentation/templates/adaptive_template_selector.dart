/// Deterministic presentation selection for trusted, already-computed data.
///
/// This class chooses a layout only. It never creates blocks, calculates values,
/// fetches Quran text, or upgrades an untrusted payload into trusted data.
abstract final class AdaptiveTemplateSelector {
  static const Set<String> supportedTemplates = <String>{
    'generic_template',
    'reader_template',
    'analytics_template',
    'comparison_template',
    'graph_template',
    'cosmic_template',
    'abjad_template',
    'agent_template',
    'universal_dynamic_canvas',
    'dashboard_template',
    'chat_template',
    'library_template',
    'player_template',
    'settings_template',
    'search_template',
    'profile_template',
    'lab_template',
    'service_hub_template',
    'cosmic_celestial_template',
    'quantum_mesh_template',
    'vector_embedding_template',
    'dream_journal_template',
    'sovereign_ar_iot_template',
  };

  static String select({
    required String requestedTemplateId,
    required String domain,
    required String query,
    required List<Map<String, dynamic>> blocks,
  }) {
    if (!supportedTemplates.contains(requestedTemplateId)) {
      return requestedTemplateId;
    }

    final normalizedDomain = _normalize(domain);
    final normalizedQuery = _normalize(query);
    final types = blocks
        .map((block) => block['type'])
        .whereType<String>()
        .toSet();

    if (types.contains('quran_verse')) return 'reader_template';
    if (normalizedDomain.contains('abjad')) return 'abjad_template';
    if (types.contains('star_tracker_block')) {
      return 'cosmic_celestial_template';
    }
    if (types.contains('quantum_particle_block')) {
      return 'quantum_mesh_template';
    }
    if (types.contains('vector_space_block')) {
      return 'vector_embedding_template';
    }

    if (_containsAny(normalizedQuery, const <String>[
      'قارن', 'مقارنه', 'الفرق بين',
    ])) {
      return 'comparison_template';
    }

    if (_containsAny(normalizedDomain, const <String>[
      'astronomy', 'cosmic', 'planet', 'celestial',
    ])) {
      return 'cosmic_template';
    }

    if (_containsAny(normalizedDomain, const <String>[
      'network', 'nucleus', 'agent',
    ]) ||
        types.contains('relation_graph_block') ||
        types.contains('spatial_map_block') ||
        types.contains('star_map_block')) {
      return 'graph_template';
    }

    if (types.contains('bar_chart') ||
        types.contains('metric') ||
        types.contains('metric_card') ||
        types.contains('table')) {
      return 'analytics_template';
    }

    return requestedTemplateId;
  }

  static bool _containsAny(String value, List<String> terms) =>
      terms.any(value.contains);

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
