import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/domain/entities/agent_task.dart';
import 'package:mudabbir_al_asrar/presentation/providers/agent_chat_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cancelling during local knowledge initialization stays cancelled', () async {
    final provider = AgentChatProvider();
    final pending = provider.executeTask('اختبار إلغاء المهمة');

    // executeTask publishes its running task before awaiting local asset loads.
    provider.cancel();
    await pending;

    expect(provider.activeTask?.status, TaskStatus.cancelled);
    expect(provider.activeTask?.finalAnswer, isNull);
    provider.dispose();
  });
}
