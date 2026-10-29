import 'package:flutter_test/flutter_test.dart';
import '../lib/services/agent_ui_coordinator.dart';

void main() {
  const coordinator = AgentUiCoordinator();

  test('routes numerical Quran questions to analytics template', () {
    final intent = coordinator.resolve('كم مرة ذكرت الحياة والموت');
    expect(intent?.targetScreen, 'miracles_screen');
    expect(intent?.templateId, 'analytics_template');
    expect(intent?.payload['requires_verified_counts'], isTrue);
  });


  test('passes an explicit single word to the analytics template', () {
    final intent = coordinator.resolve('كم مرة ذكرت كلمة الرحمن');
    expect(intent?.targetScreen, 'miracles_screen');
    expect(intent?.payload['first_word'], 'الرحمن');
    expect(intent?.payload['second_word'], isNull);
  });

  test('passes both explicit words for a paired count request', () {
    final intent = coordinator.resolve('كم مرة ذكرت الحياة والموت');
    expect(intent?.payload['first_word'], 'الحياة');
    expect(intent?.payload['second_word'], 'الموت');
  });

  test('routes agent status requests to nucleus graph screen', () {
    final intent = coordinator.resolve('اعرض حالة الوكلاء وتفاعل النواة');
    expect(intent?.targetScreen, 'nucleus_screen');
    expect(intent?.templateId, 'graph_template');
  });

  test('routes comparisons to comparison screen', () {
    final intent = coordinator.resolve('قارن الآيات التي ذكرت الأنبياء');
    expect(intent?.targetScreen, 'compare_screen');
    expect(intent?.templateId, 'comparison_template');
  });

  test('opens a canonical reader for explicit verse navigation', () {
    final intent = coordinator.resolve('افتح المصحف عند ٢:٢٥٥');
    expect(intent?.targetScreen, 'quran_page_screen');
    expect(intent?.payload['surah_number'], 2);
    expect(intent?.payload['ayah_number'], 255);
  });

  test('wraps trusted service output as a schema-driven template intent', () {
    final intent = coordinator.resolveSchemaPayload(
      templateId: 'cosmic_template',
      title: 'خصائص جرم',
      domain: 'astronomy',
      source: 'local_astronomy_service',
      blocks: const [
        {'type': 'metric', 'title': 'نصف القطر', 'value': 123},
      ],
    );

    expect(intent?.targetScreen, 'template_renderer');
    expect(intent?.templateId, 'cosmic_template');
    expect(intent?.payload['source'], 'local_astronomy_service');
    expect(intent?.payload['blocks'], hasLength(1));
  });

  test('rejects unknown template ids and missing schema data', () {
    expect(
      coordinator.resolveSchemaPayload(
        templateId: 'unregistered_template',
        title: 'Unknown',
        domain: 'test',
        source: 'test_service',
        blocks: const [{'type': 'metric', 'value': 1}],
      ),
      isNull,
    );
    expect(
      coordinator.resolveSchemaPayload(
        templateId: 'abjad_template',
        title: 'Empty',
        domain: 'abjad',
        source: 'abjad_service',
        blocks: const [],
      ),
      isNull,
    );
  });

  test('does not navigate for ordinary questions', () {
    expect(coordinator.resolve('اشرح معنى الصبر'), isNull);
  });
}
