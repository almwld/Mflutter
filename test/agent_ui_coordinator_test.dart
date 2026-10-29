import 'package:flutter_test/flutter_test.dart';
import 'package:mflutter/services/agent_ui_coordinator.dart';

void main() {
  const coordinator = AgentUiCoordinator();

  test('routes numerical Quran questions to analytics template', () {
    final intent = coordinator.resolve('كم مرة ذكرت الحياة والموت');
    expect(intent?.targetScreen, 'miracles_screen');
    expect(intent?.templateId, 'analytics_template');
    expect(intent?.payload['requires_verified_counts'], isTrue);
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

  test('does not navigate for ordinary questions', () {
    expect(coordinator.resolve('اشرح معنى الصبر'), isNull);
  });
}
