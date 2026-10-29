enum TaskStatus { pending, running, paused, completed, failed, cancelled }
enum StepStatus { pending, running, done, failed, paused, cancelled }

class StepDetail {
  final String label;
  final String value;
  const StepDetail(this.label, this.value);

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  factory StepDetail.fromJson(Map<String, dynamic> json) => StepDetail(
        (json['label'] ?? '').toString(),
        (json['value'] ?? '').toString(),
      );
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

  Map<String, dynamic> toJson() => {
        'number': number,
        'agentName': agentName,
        'title': title,
        'subtitle': subtitle,
        'status': status.name,
        'progress': progress,
        'details': details.map((detail) => detail.toJson()).toList(),
        'result': result,
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory AgentStep.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString();
    final status = StepStatus.values.firstWhere(
      (value) => value.name == rawStatus,
      orElse: () => StepStatus.pending,
    );
    final rawDetails = json['details'];
    return AgentStep(
      number: (json['number'] as num?)?.toInt() ?? 0,
      agentName: (json['agentName'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      status: status,
      progress: (json['progress'] as num?)?.toDouble(),
      details: rawDetails is List
          ? rawDetails.whereType<Map>().map((value) =>
              StepDetail.fromJson(Map<String, dynamic>.from(value))).toList()
          : const [],
      result: json['result']?.toString(),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
    );
  }
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'userQuery': userQuery,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'status': status.name,
        'steps': steps.map((step) => step.toJson()).toList(),
        'finalAnswer': finalAnswer,
        'error': error,
      };

  factory AgentTask.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString();
    final status = TaskStatus.values.firstWhere(
      (value) => value.name == rawStatus,
      orElse: () => TaskStatus.pending,
    );
    final rawSteps = json['steps'];
    return AgentTask(
      id: (json['id'] ?? '').toString(),
      userQuery: (json['userQuery'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      status: status,
      steps: rawSteps is List
          ? rawSteps.whereType<Map>().map((value) =>
              AgentStep.fromJson(Map<String, dynamic>.from(value))).toList()
          : const [],
      finalAnswer: json['finalAnswer']?.toString(),
      error: json['error']?.toString(),
    );
  }

  /// Converts an interrupted in-flight snapshot into a recoverable checkpoint.
  /// Completed steps remain intact; only the step that was executing is retried.
  AgentTask recoverInterrupted() {
    if (status != TaskStatus.running && status != TaskStatus.paused) return this;
    final recoveredSteps = steps.map((step) {
      if (step.status == StepStatus.running || step.status == StepStatus.paused) {
        return step.copyWith(status: StepStatus.paused);
      }
      return step;
    }).toList(growable: false);
    return copyWith(status: TaskStatus.paused, steps: recoveredSteps);
  }
}
