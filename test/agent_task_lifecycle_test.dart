import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudabbir_al_asrar/domain/entities/agent_task.dart';
import 'package:mudabbir_al_asrar/presentation/providers/agent_chat_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pause and cancel cannot change a completed task back to active', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AgentChatProvider();
    addTearDown(provider.dispose);

    await provider.executeTask('اختبار بسيط');
    expect(provider.activeTask?.status, TaskStatus.completed);

    provider.pauseOrResume();
    expect(provider.activeTask?.status, TaskStatus.completed);
    expect(provider.paused, isFalse);

    provider.cancel();
    expect(provider.activeTask?.status, TaskStatus.completed);
  });
}
