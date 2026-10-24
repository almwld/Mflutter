import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/domain/entities/agent_task.dart';
import 'package:mudabbir_al_asrar/presentation/providers/agent_chat_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('training agent never labels the canonical Quran corpus automatically', () async {
    final provider = AgentChatProvider();
    provider.selectAgent('tadrib');

    await provider.executeTask('تحقق من سياسة التدريب');

    final task = provider.activeTask;
    expect(task, isNotNull);
    final trainingStep = task!.steps.firstWhere((step) => step.agentName == 'tadrib');
    expect(trainingStep.status, StepStatus.done);
    expect(trainingStep.result, contains('لم يبدأ التدريب'));
    expect(trainingStep.result, contains('مُعنونة يدويًا'));
    expect(trainingStep.result, isNot(contains('اكتمل تدريب')));
    provider.dispose();
  });
}
