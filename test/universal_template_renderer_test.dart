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
