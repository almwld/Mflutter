enum TaskStatus { pending, running, paused, completed, failed, cancelled }
enum StepStatus { pending, running, done, failed, paused }

class StepDetail {
  final String label;
  final String value;
  const StepDetail(this.label, this.value);
}

class AgentStep {
  final int number;
  final String agentName;
  final String title;
  final String subtitle;
  final StepStatus status;
  final double? progress;
  final List<StepDetail> details;
  final String? result;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const AgentStep({
    required this.number,
    required this.agentName,
    required this.title,
    required this.subtitle,
    this.status = StepStatus.pending,
    this.progress,
    this.details = const [],
    this.result,
    this.startedAt,
    this.completedAt,
  });

  AgentStep copyWith({
    StepStatus? status,
    double? progress,
    List<StepDetail>? details,
    String? result,
    DateTime? startedAt,
    DateTime? completedAt,
  }) => AgentStep(
    number: number,
    agentName: agentName,
    title: title,
    subtitle: subtitle,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    details: details ?? this.details,
    result: result ?? this.result,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
  );
}

class AgentTask {
  final String id;
  final String userQuery;
  final DateTime createdAt;
  final DateTime? completedAt;
  final TaskStatus status;
  final List<AgentStep> steps;
  final String? finalAnswer;
  final String? error;

  const AgentTask({
    required this.id,
    required this.userQuery,
    required this.createdAt,
    this.completedAt,
    this.status = TaskStatus.pending,
    this.steps = const [],
    this.finalAnswer,
    this.error,
  });

  double get progress {
    if (steps.isEmpty) return 0;
    final done = steps.where((s) => s.status == StepStatus.done).length;
    return done / steps.length;
  }

  AgentTask copyWith({
    TaskStatus? status,
    List<AgentStep>? steps,
    DateTime? completedAt,
    String? finalAnswer,
    String? error,
  }) => AgentTask(
    id: id,
    userQuery: userQuery,
    createdAt: createdAt,
    status: status ?? this.status,
    steps: steps ?? this.steps,
    completedAt: completedAt ?? this.completedAt,
    finalAnswer: finalAnswer ?? this.finalAnswer,
    error: error ?? this.error,
  );
}
