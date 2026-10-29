import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/agent_task.dart';

/// Durable local checkpoints for the on-device agent runtime.
///
/// Only task state is stored; no network sync is performed. Writes are
/// serialized so rapid progress updates cannot overwrite a newer checkpoint
/// with an older snapshot.
class AgentTaskStore {
  AgentTaskStore._();

  static final AgentTaskStore instance = AgentTaskStore._();
  static const String _storageKey = 'mudabbir_agent_task_checkpoints_v1';
  static const int _maxTasks = 12;

  Future<void> _writeQueue = Future<void>.value();

  Future<void> save(AgentTask task) {
    _writeQueue = _writeQueue
        .catchError((Object _) {})
        .then((_) => _saveSerially(task));
    return _writeQueue;
  }

  Future<void> _saveSerially(AgentTask task) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = _decode(prefs.getString(_storageKey));
    final snapshot = <String, dynamic>{
      ...task.toJson(),
      'checkpointAt': DateTime.now().toIso8601String(),
    };
    rows.removeWhere((row) => row['id'] == task.id);
    rows.add(snapshot);
    if (rows.length > _maxTasks) {
      rows.removeRange(0, rows.length - _maxTasks);
    }

    final encoded = jsonEncode(rows);
    if (!await prefs.setString(_storageKey, encoded)) {
      throw StateError('تعذر حفظ نقطة استعادة مهمة الوكيل محليًا.');
    }

    // Verify the latest checkpoint was actually committed to preferences.
    final readBack = _decode(prefs.getString(_storageKey));
    final verified = readBack.any((row) =>
        row['id'] == task.id &&
        row['checkpointAt'] == snapshot['checkpointAt']);
    if (!verified) {
      throw StateError('فشل التحقق من نقطة استعادة مهمة الوكيل.');
    }
  }

  /// Returns the most recently checkpointed task. Interrupted work is marked
  /// paused and its in-flight step remains eligible for a deliberate retry.
  Future<AgentTask?> loadLatest() async {
    await _writeQueue;
    final prefs = await SharedPreferences.getInstance();
    final rows = _decode(prefs.getString(_storageKey));
    if (rows.isEmpty) return null;

    rows.sort((a, b) => (a['checkpointAt'] ?? '')
        .toString()
        .compareTo((b['checkpointAt'] ?? '').toString()));
    try {
      return AgentTask.fromJson(rows.last).recoverInterrupted();
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  Future<List<AgentTask>> recent({int limit = 8}) async {
    if (limit <= 0) return const [];
    await _writeQueue;
    final prefs = await SharedPreferences.getInstance();
    final rows = _decode(prefs.getString(_storageKey));
    rows.sort((a, b) => (b['checkpointAt'] ?? '')
        .toString()
        .compareTo((a['checkpointAt'] ?? '').toString()));
    final tasks = <AgentTask>[];
    for (final row in rows.take(limit)) {
      try {
        tasks.add(AgentTask.fromJson(row).recoverInterrupted());
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      } on ArgumentError {
        continue;
      }
    }
    return List.unmodifiable(tasks);
  }

  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .where((row) => row['id'] is String && row['userQuery'] is String)
          .toList();
    } on FormatException {
      return <Map<String, dynamic>>[];
    } on TypeError {
      return <Map<String, dynamic>>[];
    } on ArgumentError {
      return <Map<String, dynamic>>[];
    }
  }
}
