/// =============================================================================
/// Science - كيان العلم
/// =============================================================================

class Science {
  final int id;
  final String name;
  final String description;
  final String icon;
  final List<String> topics;
  final int relatedSciencesCount;
  final List<int> relatedScienceIds;
  final int level;
  final bool isActive;

  const Science({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.topics,
    required this.relatedSciencesCount,
    required this.relatedScienceIds,
    required this.level,
    this.isActive = false,
  });

  /// اسم العلم المعروض
  String get displayName => 'علم $name';

  /// معلومات العلم
  String get info =>
      '$description\n'
      'مواضيع: ${topics.take(3).join(' • ')}';

  /// المستوى المعروض
  String get levelDisplay => _getLevelText(level);

  String _getLevelText(int level) {
    switch (level) {
      case 1:
        return 'مبتدئ';
      case 2:
        return 'متوسط';
      case 3:
        return 'متقدم';
      default:
        return 'غير محدد';
    }
  }

  /// نسخ كـ Map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'topics': topics,
    'related_sciences_count': relatedSciencesCount,
    'related_science_ids': relatedScienceIds,
    'level': level,
    'is_active': isActive,
  };

  /// إنشاء من Map
  factory Science.fromMap(Map<String, dynamic> map) => Science(
    id: map['id'] ?? 0,
    name: map['name'] ?? '',
    description: map['description'] ?? '',
    icon: map['icon'] ?? '📚',
    topics: List<String>.from(map['topics'] ?? []),
    relatedSciencesCount: map['related_sciences_count'] ?? 0,
    relatedScienceIds: List<int>.from(map['related_science_ids'] ?? []),
    level: map['level'] ?? 1,
    isActive: map['is_active'] ?? false,
  );
}

/// =============================================================================
/// ScienceConnection - اتصال العلوم
/// =============================================================================

class ScienceConnection {
  final int sourceId;
  final int targetId;
  final String connectionType;
  final int strength;

  const ScienceConnection({
    required this.sourceId,
    required this.targetId,
    required this.connectionType,
    required this.strength,
  });
}

/// =============================================================================
/// ScienceProgress - تقدم العلم
/// =============================================================================

class ScienceProgress {
  final int scienceId;
  final int completedTopics;
  final int totalTopics;
  final DateTime lastStudied;
  final int studyMinutes;

  const ScienceProgress({
    required this.scienceId,
    required this.completedTopics,
    required this.totalTopics,
    required this.lastStudied,
    required this.studyMinutes,
  });

  /// نسبة الإكمال
  double get completionPercent =>
      totalTopics > 0 ? (completedTopics / totalTopics) * 100 : 0;

  /// هل مكتمل؟
  bool get isCompleted => completedTopics >= totalTopics;

  /// الوصف
  String get description =>
      '$completedTopics من $totalTopics موضوع\n'
      'وقت الدراسة: $studyMinutes دقيقة';
}