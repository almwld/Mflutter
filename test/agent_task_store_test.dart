import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mudabbir_al_asrar/domain/entities/agent_task.dart';
import 'package:mudabbir_al_asrar/services/agent_task_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('task JSON round-trip preserves step evidence and timestamps', () {
    final created = DateTime.utc(2026, 10, 29, 1, 2, 3);
    final task = AgentTask(
      id: 'task-1',
      userQuery: 'اختبار الذاكرة',
      createdAt: created,
      status: TaskStatus.completed,
      steps: [
        AgentStep(
          number: 1,
          agentName: 'researcher',
          title: 'باحث',
          subtitle: 'بحث محلي',
          status: StepStatus.done,
          progress: 1,
          details: const [StepDetail('المصدر', 'assets/agent_knowledge.json')],
          result: 'نتيجة موثقة',
          startedAt: created,
          completedAt: created.add(const Duration(seconds: 2)),
        ),
      ],
      finalAnswer: 'اكتملت المهمة',
    );

    final decoded = AgentTask.fromJson(task.toJson());
    expect(decoded.id, task.id);
    expect(decoded.userQuery, task.userQuery);
    expect(decoded.status, TaskStatus.completed);
    expect(decoded.steps.single.status, StepStatus.done);
    expect(decoded.steps.single.result, 'نتيجة موثقة');
    expect(decoded.steps.single.details.single.value, 'assets/agent_knowledge.json');
    expect(decoded.finalAnswer, 'اكتملت المهمة');
  });

  test('loading an interrupted task recovers it as paused without losing done steps', () async {
    final store = AgentTaskStore.instance;
    final now = DateTime.now();
    final task = AgentTask(
      id: 'interrupted-task',
      userQuery: 'مهمة متعددة الخطوات',
      createdAt: now,
      status: TaskStatus.running,
      steps: [
        const AgentStep(
          number: 1,
          agentName: 'researcher',
          title: 'البحث',
          subtitle: 'استرجاع الأدلة',
          status: StepStatus.done,
          progress: 1,
          result: 'دليل محفوظ',
        ),
        const AgentStep(
          number: 2,
          agentName: 'critic',
          title: 'المراجعة',
          subtitle: 'فحص الدليل',
          status: StepStatus.running,
        ),
      ],
    );

    await store.save(task);
    final recovered = await store.loadLatest();

    expect(recovered, isNotNull);
    expect(recovered!.status, TaskStatus.paused);
    expect(recovered.steps[0].status, StepStatus.done);
    expect(recovered.steps[0].result, 'دليل محفوظ');
    expect(recovered.steps[1].status, StepStatus.paused);
  });
}
