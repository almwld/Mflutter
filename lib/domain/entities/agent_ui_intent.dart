/// A validated UI action proposed by the local agent coordinator.
/// It describes navigation and presentation intent; it never contains Quran text
/// rewritten by the model. Canonical text remains owned by local Quran screens.
class AgentUiIntent {
  final String id;
  final String targetScreen;
  final String templateId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  AgentUiIntent({
    required this.id,
    required this.targetScreen,
    required this.templateId,
    required Map<String, dynamic> payload,
    DateTime? createdAt,
  })  : payload = Map<String, dynamic>.unmodifiable(payload),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'target_screen': targetScreen,
        'ui_template': templateId,
        'data_payload': payload,
        'created_at': createdAt.toIso8601String(),
      };
}
