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
