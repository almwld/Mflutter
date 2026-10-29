import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/templates/universal_template_renderer.dart';

void main() {
  group('TemplatePayloadSchema', () {
    test('parses a valid analytics payload without inventing values', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'analytics_template',
        'schema_version': 1,
        'title': 'تحليل محلي',
        'domain': 'quran',
        'blocks': [
          {'type': 'metric', 'title': 'عدد النتائج', 'value': 12},
          {'type': 'bar_chart', 'items': [
            {'label': 'أ', 'value': 3},
            {'label': 'ب', 'value': 9},
          ]},
        ],
      });

      expect(schema.templateId, 'analytics_template');
      expect(schema.version, 1);
      expect(schema.title, 'تحليل محلي');
      expect(schema.domain, 'quran');
      expect(schema.hasRenderableBlocks, isTrue);
      expect(schema.blocks, hasLength(2));
    });

    test('returns an explicit empty schema when source data is missing', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'cosmic_template',
      });

      expect(schema.templateId, 'cosmic_template');
      expect(schema.blocks, isEmpty);
      expect(schema.hasRenderableBlocks, isFalse);
      expect(schema.emptyMessage, isNotEmpty);
    });

    test('does not classify unsupported block types as renderable', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'generic_template',
        'schema_version': 1,
        'blocks': [
          {'type': 'invented_chart', 'value': 99},
          {'type': 'metric', 'title': 'Verified', 'value': 7},
        ],
      });

      expect(schema.hasRenderableBlocks, isTrue);
      expect(
        schema.blocks.where(TemplateBlockSchema.isSupported),
        hasLength(1),
      );
    });

    test('rejects unsupported schema versions and malformed envelope fields', () {
      final unsupportedVersion = TemplatePayloadSchema.fromMap({
        'ui_template': 'analytics_template',
        'schema_version': 2,
        'title': 'إصدار غير مدعوم',
        'blocks': [
          {'type': 'metric', 'title': 'عدد', 'value': 4},
        ],
      });
      expect(unsupportedVersion.envelopeValid, isFalse);
      expect(unsupportedVersion.hasRenderableBlocks, isFalse);
      expect(unsupportedVersion.validationErrors, isNotEmpty);

      final malformedEnvelope = TemplatePayloadSchema.fromMap({
        'ui_template': 'analytics_template',
        'schema_version': 1,
        'title': 12,
        'blocks': [],
      });
      expect(malformedEnvelope.envelopeValid, isFalse);
    });

    test('rejects malformed block fields instead of rendering invented defaults', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'analytics_template',
        'schema_version': 1,
        'title': 'بيانات مختبرة',
        'blocks': [
          {'type': 'metric', 'title': 'عدد', 'value': null},
          {'type': 'text', 'text': ''},
          {'type': 'metric', 'title': 'قيمة صحيحة', 'value': 5},
        ],
      });

      expect(schema.envelopeValid, isTrue);
      expect(schema.blocks, hasLength(1));
      expect(schema.blocks.single['value'], 5);
      expect(schema.validationErrors, hasLength(2));
      expect(schema.hasRenderableBlocks, isTrue);
    });

    test('Quran verse blocks require a canonical reference and no supplied text', () {
      final missingReference = TemplatePayloadSchema.fromMap({
        'ui_template': 'reader_template',
        'schema_version': 1,
        'blocks': [
          {'type': 'quran_verse', 'title': 'Verse', 'text': 'payload text'},
        ],
      });
      expect(missingReference.blocks, isEmpty);
      expect(missingReference.validationErrors, isNotEmpty);

      final suppliedText = TemplatePayloadSchema.fromMap({
        'ui_template': 'reader_template',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'quran_verse',
            'title': 'Verse',
            'surah_number': 1,
            'ayah_number': 1,
            'text': 'payload text',
          },
        ],
      });
      expect(suppliedText.blocks, isEmpty);
      expect(suppliedText.validationErrors, isNotEmpty);

      final canonicalReference = TemplatePayloadSchema.fromMap({
        'ui_template': 'reader_template',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'quran_verse',
            'title': 'Verse',
            'surah_number': 1,
            'ayah_number': 1,
          },
        ],
      });
      expect(canonicalReference.blocks, hasLength(1));
      expect(canonicalReference.validationErrors, isEmpty);
    });

    test('requires table rows to match the declared columns', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'generic_template',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'table',
            'columns': ['الاسم', 'القيمة'],
            'rows': [['عنصر واحد']],
          },
        ],
      });

      expect(schema.blocks, isEmpty);
      expect(schema.hasRenderableBlocks, isFalse);
      expect(schema.validationErrors, isNotEmpty);
    });

    test('preserves source provenance and rejects malformed source metadata', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'analytics_template',
        'schema_version': 1,
        'title': 'نتائج محلية',
        'source': 'QuranLoaderService',
        'blocks': [
          {'type': 'metric', 'title': 'عدد الآيات', 'value': 6236},
        ],
      });
      expect(schema.envelopeValid, isTrue);
      expect(schema.source, 'QuranLoaderService');

      final malformedSource = TemplatePayloadSchema.fromMap({
        'ui_template': 'analytics_template',
        'schema_version': 1,
        'source': 17,
        'blocks': [
          {'type': 'metric', 'value': 1},
        ],
      });
      expect(malformedSource.envelopeValid, isFalse);
      expect(malformedSource.validationErrors, isNotEmpty);
    });

    test('rejects non-string keys without throwing while parsing blocks', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'generic_template',
        'schema_version': 1,
        'blocks': [
          {7: 'unexpected', 'type': 'text', 'text': 'يجب استبعاد هذه الكتلة'},
          {'type': 'metric', 'value': 3},
        ],
      });
      expect(schema.envelopeValid, isTrue);
      expect(schema.blocks, hasLength(1));
      expect(schema.blocks.single['value'], 3);
      expect(schema.validationErrors, isNotEmpty);
    });

    test('registers every domain template used by trusted local services', () {
      expect(TemplateRegistry.lookup('analytics_template'), isNotNull);
      expect(TemplateRegistry.lookup('abjad_template'), isNotNull);
      expect(TemplateRegistry.lookup('graph_template'), isNotNull);
    });

    test('supports the universal metadata envelope and block data object', () {
      final schema = TemplatePayloadSchema.fromMap({
        'template_id': 'universal_dynamic_canvas',
        'schema_version': 1,
        'metadata': {
          'title': 'لوحة عامة',
          'subtitle': 'عرض محلي',
          'topic_category': 'Science',
          'source': 'LocalDemoService',
          'generated_at': '2026-10-29T00:00:00Z',
        },
        'blocks': [
          {
            'type': 'metric',
            'title': 'عدد موثّق',
            'data': {'value': 8},
            'style_hints': {'color_theme': 'untrusted-custom-color'},
          },
        ],
      });

      expect(schema.envelopeValid, isTrue);
      expect(schema.templateId, 'universal_dynamic_canvas');
      expect(schema.title, 'لوحة عامة');
      expect(schema.subtitle, 'عرض محلي');
      expect(schema.domain, 'Science');
      expect(schema.source, 'LocalDemoService');
      expect(schema.blocks.single['value'], 8);
      expect(schema.blocks.single.containsKey('style_hints'), isFalse);
      expect(TemplateRegistry.lookup(schema.templateId), isNotNull);
    });

    test('registers the specialist template ecosystem', () {
      const ids = [
        'dashboard_template', 'reader_template', 'chat_template',
        'library_template', 'analytics_template', 'graph_template',
        'player_template', 'settings_template', 'search_template',
        'profile_template', 'lab_template', 'service_hub_template',
        'cosmic_celestial_template', 'quantum_mesh_template',
        'vector_embedding_template', 'dream_journal_template',
        'sovereign_ar_iot_template', 'universal_dynamic_canvas',
      ];
      for (final id in ids) {
        expect(TemplateRegistry.lookup(id), isNotNull, reason: id);
      }
    });

    test('validates coordinate blocks and rejects unbounded point payloads', () {
      final valid = TemplatePayloadSchema.fromMap({
        'ui_template': 'cosmic_celestial_template',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'star_map_block',
            'title': 'Coordinate demonstration',
            'data': {
              'stars': [
                {'x': 0.2, 'y': 0.4, 'label': 'A'},
                {'x': 0.8, 'y': 0.6, 'label': 'B'},
              ],
            },
          },
        ],
      });
      expect(valid.blocks, hasLength(1));
      expect(valid.validationErrors, isEmpty);

      final invalid = TemplatePayloadSchema.fromMap({
        'ui_template': 'vector_embedding_template',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'vector_space_block',
            'points': [
              {'x': 1.2, 'y': 0.4},
            ],
          },
        ],
      });
      expect(invalid.blocks, isEmpty);
      expect(invalid.validationErrors, isNotEmpty);
    });

    test('normalizes nested data blocks and caps oversized envelopes', () {
      final nested = TemplatePayloadSchema.fromMap({
        'ui_template': 'universal_dynamic_canvas',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'section',
            'title': 'Section',
            'children': [
              {
                'type': 'metric',
                'title': 'Nested metric',
                'data': {'value': 17},
              },
            ],
          },
        ],
      });
      expect(nested.blocks, hasLength(1));
      final child = (nested.blocks.single['children'] as List).single as Map;
      final normalizedChild = TemplateBlockSchema.normalize(child);
      expect(normalizedChild?['value'], 17);
      expect(TemplateBlockSchema.validate(normalizedChild!), isEmpty);

      final oversized = TemplatePayloadSchema.fromMap({
        'ui_template': 'universal_dynamic_canvas',
        'schema_version': 1,
        'blocks': List.generate(301, (_) => {'type': 'metric', 'value': 1}),
      });
      expect(oversized.envelopeValid, isFalse);
      expect(oversized.validationErrors, isNotEmpty);
    });

    test('validates timeline and interactive card blocks', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'dream_journal_template',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'timeline_block',
            'events': [
              {'label': 'Entry saved', 'date': '2026-10-29'},
            ],
          },
          {
            'type': 'interactive_card_block',
            'front': 'Reflection',
            'details': 'User-provided reflection details',
          },
        ],
      });
      expect(schema.blocks, hasLength(2));
      expect(schema.validationErrors, isEmpty);
    });

    test('registry rejects duplicate identifiers and accepts new modules', () {
      const id = 'test_dynamic_module';
      expect(
        TemplateRegistry.register(
          id,
          (context, schema) => const TemplateEmptyState(message: 'test'),
        ),
        isTrue,
      );
      expect(
        TemplateRegistry.register(
          id,
          (context, schema) => const TemplateEmptyState(message: 'duplicate'),
        ),
        isFalse,
      );
      expect(TemplateRegistry.lookup(id), isNotNull);
    });
  });
}
