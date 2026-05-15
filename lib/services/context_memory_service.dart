class ContextMemoryService {
  static final List<Map<String, dynamic>> _memory = [];
  static final Map<String, int> _topicFrequency = {};
  static final List<String> _recentQuestions = [];

  static void remember(String question, String response, String topic) {
    _memory.add({
      'question': question,
      'response': response,
      'topic': topic,
      'timestamp': DateTime.now(),
    });
    _topicFrequency[topic] = (_topicFrequency[topic] ?? 0) + 1;
    _recentQuestions.add(question);
    if (_recentQuestions.length > 20) _recentQuestions.removeAt(0);
  }

  static String getFavoriteTopic() {
    if (_topicFrequency.isEmpty) return 'عام';
    return _topicFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static List<String> getRecentQuestions() => List.from(_recentQuestions.reversed);

  static Map<String, int> getTopicStats() => Map.from(_topicFrequency);

  static String getContextSummary() {
    if (_memory.isEmpty) return 'لا توجد محادثات سابقة';
    return '${_memory.length} محادثة | الموضوع المفضل: ${getFavoriteTopic()}';
  }
}
