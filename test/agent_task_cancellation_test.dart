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
    expect(provider.messages.where((message) => message.startsWith('تعذر إكمال المهمة:')), isEmpty);
    provider.dispose();
  });

  test('an older cancelled task cannot overwrite a newer task', () async {
    final provider = AgentChatProvider();
    final first = provider.executeTask('المهمة الأولى');
    provider.cancel();

    final second = provider.executeTask('المهمة الثانية');
    provider.cancel();
    await Future.wait<void>([first, second]);

    expect(provider.activeTask?.userQuery, 'المهمة الثانية');
    expect(provider.activeTask?.status, TaskStatus.cancelled);
    expect(
      provider.messages.where((message) => message.startsWith('تعذر إكمال المهمة:')),
      isEmpty,
    );
    provider.dispose();
  });
}
