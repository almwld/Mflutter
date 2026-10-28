import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ContextMemoryService {
  static const _storageKey = 'mudabbir_context_memory_v1';
  static final List<Map<String, dynamic>> _memory = [];
  static final Map<String, int> _topicFrequency = {};
  static final List<String> _recentQuestions = [];
  static Future<void> _writeQueue = Future<void>.value();
  static bool _loaded = false;

  static Future<void> loadSavedMemory() async {
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
    unawaited(_enqueuePersistence());
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
    _writeQueue = _writeQueue.then((_) async {
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
  static Map<String, int> getTopicStats() => Map.from(_topicFrequency);

  static String getContextSummary() {
    if (_memory.isEmpty) return 'لا توجد محادثات محفوظة في ذاكرة السياق بعد';
    return '${_memory.length} محادثة | الموضوع الأكثر تكرارًا: ${getFavoriteTopic()}';
  }
}
