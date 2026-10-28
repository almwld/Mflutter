import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContextMemoryService {
  static const _storageKey = 'mudabbir_context_memory_v1';
  static final List<Map<String, dynamic>> _memory = [];
  static final Map<String, int> _topicFrequency = {};
  static final List<String> _recentQuestions = [];
  static Future<void> _writeQueue = Future<void>.value();
  static Future<void>? _loadFuture;
  static bool _loaded = false;

  static Future<void> loadSavedMemory() {
    if (_loaded) return Future<void>.value();
    return _loadFuture ??= _loadSavedMemoryOnce().whenComplete(() {
      _loadFuture = null;
    });
  }

  static Future<void> _loadSavedMemoryOnce() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded.whereType<Map>()) {
            final row = Map<String, dynamic>.from(item);
            final question = row['question']?.toString() ?? '';
            final topic = row['topic']?.toString() ?? 'عام';
            if (question.isEmpty) continue;
            final timestamp = DateTime.tryParse(row['timestamp']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
            _memory.add({'question': question, 'response': row['response']?.toString() ?? '', 'topic': topic, 'timestamp': timestamp});
            _topicFrequency[topic] = (_topicFrequency[topic] ?? 0) + 1;
            _recentQuestions.add(question);
          }
        }
      } on FormatException {
        _memory.clear();
        _topicFrequency.clear();
        _recentQuestions.clear();
      }
    }
    while (_memory.length > 100) {
      final removed = _memory.removeAt(0);
      final topic = removed['topic']?.toString() ?? 'عام';
      final count = (_topicFrequency[topic] ?? 1) - 1;
      if (count <= 0) { _topicFrequency.remove(topic); } else { _topicFrequency[topic] = count; }
    }
    while (_recentQuestions.length > 20) { _recentQuestions.removeAt(0); }
    _loaded = true;
  }

  static void remember(String question, String response, String topic) {
    _memory.add({'question': question, 'response': response, 'topic': topic, 'timestamp': DateTime.now()});
    _topicFrequency[topic] = (_topicFrequency[topic] ?? 0) + 1;
    _recentQuestions.add(question);
    if (_recentQuestions.length > 20) _recentQuestions.removeAt(0);
    while (_memory.length > 100) {
      final removed = _memory.removeAt(0);
      final removedTopic = removed['topic']?.toString() ?? 'عام';
      final count = (_topicFrequency[removedTopic] ?? 1) - 1;
      if (count <= 0) { _topicFrequency.remove(removedTopic); } else { _topicFrequency[removedTopic] = count; }
    }
    // Persistence is best-effort for the in-memory session; absorb this call's
    // asynchronous error while keeping the queue recoverable on the next write.
    unawaited(_enqueuePersistence().catchError((_) {}));
  }

  static Future<void> _enqueuePersistence() {
    final snapshot = _memory.map((row) => <String, dynamic>{
      'question': row['question'],
      'response': row['response'],
      'topic': row['topic'],
      'timestamp': (row['timestamp'] is DateTime
          ? row['timestamp'] as DateTime
          : DateTime.tryParse(row['timestamp']?.toString() ?? '') ?? DateTime.now()).toIso8601String(),
    }).toList(growable: false);
    // A failed preference write must not permanently poison the serial queue;
    // a later successful write should still be able to persist newer memory.
    _writeQueue = _writeQueue.catchError((_) {}).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(snapshot));
    });
    return _writeQueue;
  }

  static String getFavoriteTopic() {
    if (_topicFrequency.isEmpty) return 'عام';
    return _topicFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static List<String> getRecentQuestions() => List.from(_recentQuestions.reversed);

  /// Returns a bounded, newest-first snapshot for conversational continuity.
  /// Answers are truncated so a long session cannot inflate every model prompt.
  static List<String> getRecentExchanges({int limit = 3}) {
    if (limit <= 0) return const [];
    return _memory.reversed.take(limit).map((row) {
      final question = (row['question']?.toString() ?? '').trim();
      final response = (row['response']?.toString() ?? '').trim();
      final topic = (row['topic']?.toString() ?? 'عام').trim();
      final shortResponse = response.length > 240
          ? response.substring(0, 240) + '…'
          : response;
      return 'الموضوع: $topic | السؤال السابق: $question | خلاصة الإجابة السابقة: $shortResponse';
    }).where((entry) => entry.trim().isNotEmpty).toList(growable: false);
  }

  static Map<String, int> getTopicStats() => Map.from(_topicFrequency);

  static String getContextSummary() {
    if (_memory.isEmpty) return 'لا توجد محادثات محفوظة في ذاكرة السياق بعد';
    return '${_memory.length} محادثة | الموضوع الأكثر تكرارًا: ${getFavoriteTopic()}';
  }
}
