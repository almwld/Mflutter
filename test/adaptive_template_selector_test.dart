import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/templates/adaptive_template_selector.dart';

void main() {
  group('AdaptiveTemplateSelector', () {
    test('selects the Quran reader only for canonical verse blocks', () {
      expect(
        AdaptiveTemplateSelector.select(
          requestedTemplateId: 'generic_template',
          domain: 'quran',
          query: 'اعرض الآية',
          blocks: const [
            {'type': 'quran_verse', 'surah_number': 1, 'ayah_number': 1},
          ],
        ),
        'reader_template',
      );
    });

    test('does not infer the reader from a Quran domain without a valid verse', () {
      expect(
        AdaptiveTemplateSelector.select(
          requestedTemplateId: 'generic_template',
          domain: 'quran',
          query: 'اعرض الآية',
          blocks: const [
            {'type': 'quran_verse', 'surah_number': 0, 'ayah_number': 1},
          ],
        ),
        'generic_template',
      );
    });

    test('keeps Abjad calculations in the Abjad template', () {
      expect(
        AdaptiveTemplateSelector.select(
          requestedTemplateId: 'analytics_template',
          domain: 'abjad',
          query: 'احسب قيمة الحروف',
          blocks: const [
            {'type': 'metric', 'value': 19},
            {'type': 'table', 'columns': ['الحرف'], 'rows': [['ا']]},
          ],
        ),
        'abjad_template',
      );
    });

    test('chooses comparison layout from a comparison request', () {
      expect(
        AdaptiveTemplateSelector.select(
          requestedTemplateId: 'analytics_template',
          domain: 'research',
          query: 'قارن بين النتيجتين',
          blocks: const [
            {'type': 'metric', 'value': 2},
          ],
        ),
        'comparison_template',
      );
    });

    test('chooses analytics for metric and chart blocks', () {
      expect(
        AdaptiveTemplateSelector.select(
          requestedTemplateId: 'generic_template',
          domain: 'research',
          query: 'اعرض النتائج',
          blocks: const [
            {'type': 'metric', 'value': 2},
            {'type': 'bar_chart', 'items': []},
          ],
        ),
        'analytics_template',
      );
    });

    test('preserves a valid requested template for generic content', () {
      expect(
        AdaptiveTemplateSelector.select(
          requestedTemplateId: 'dream_journal_template',
          domain: 'journal',
          query: 'اعرض السجل',
          blocks: const [
            {'type': 'text', 'text': 'نص موثق'},
          ],
        ),
        'dream_journal_template',
      );
    });

    test('does not replace unknown requested identifiers', () {
      expect(
        AdaptiveTemplateSelector.select(
          requestedTemplateId: 'unknown_template',
          domain: 'research',
          query: 'قارن',
          blocks: const [
            {'type': 'table'},
          ],
        ),
        'unknown_template',
      );
    });
  });
}
