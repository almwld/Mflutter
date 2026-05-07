import '../../core/constants/app_enums.dart';

/// =============================================================================
/// Insight - كيان البصيرة
/// =============================================================================

class Insight {
  final int id;
  final String question;
  final String category;
  final InsightType type;
  final List<String> reflections;
  final List<String> keywords;
  final int difficulty;
  final String? relatedVerse;
  final String? relatedScience;

  const Insight({
    required this.id,
    required this.question,
    required this.category,
    required this.type,
    required this.reflections,
    required this.keywords,
    required this.difficulty,
    this.relatedVerse,
    this.relatedScience,
  });

  /// نوع البصيرة بالكلمات
  String get typeDisplay {
    switch (type) {
      case InsightType.reflective:
        return 'تأملي';
      case InsightType.exploratory:
        return 'اكتشافي';
      case InsightType.deep:
        return 'عميق';
      case InsightType.practical:
        return 'تطبيقي';
    }
  }

  /// الصعوبة بالكلمات
  String get difficultyDisplay {
    switch (difficulty) {
      case 1:
        return 'سهل';
      case 2:
        return 'متوسط';
      case 3:
        return 'صعب';
      default:
        return 'غير محدد';
    }
  }

  /// السؤال المعروض
  String get displayQuestion => question;

  /// معلومات البصيرة
  String get info =>
      'النوع: $typeDisplay\n'
      'الصعوبة: $difficultyDisplay\n'
      'التصنيف: $category';

  /// نسخ كـ Map
  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'category': category,
    'type': type.index,
    'reflections': reflections,
    'keywords': keywords,
    'difficulty': difficulty,
    'related_verse': relatedVerse,
    'related_science': relatedScience,
  };

  /// إنشاء من Map
  factory Insight.fromMap(Map<String, dynamic> map) => Insight(
    id: map['id'] ?? 0,
    question: map['question'] ?? '',
    category: map['category'] ?? '',
    type: InsightType.values[map['type'] ?? 0],
    reflections: List<String>.from(map['reflections'] ?? []),
    keywords: List<String>.from(map['keywords'] ?? []),
    difficulty: map['difficulty'] ?? 1,
    relatedVerse: map['related_verse'],
    relatedScience: map['related_science'],
  );
}

/// =============================================================================
/// InsightResponse - استجابة البصيرة
/// =============================================================================

class InsightResponse {
  final int insightId;
  final String answer;
  final DateTime answeredAt;
  final int reflectionScore;
  final List<String> relatedInsights;

  const InsightResponse({
    required this.insightId,
    required this.answer,
    required this.answeredAt,
    required this.reflectionScore,
    this.relatedInsights = const [],
  });

  /// هل استجابة عميقة؟
  bool get isDeep => reflectionScore >= 8;

  /// الوصف
  String get description =>
      'إجابة: $answer\n'
      'درجة التأمل: $reflectionScore/10';
}

/// =============================================================================
/// InsightJourney - رحلة البصيرة
/// =============================================================================

class InsightJourney {
  final int id;
  final String title;
  final List<Insight> insights;
  final int currentIndex;
  final DateTime startedAt;
  final DateTime? completedAt;

  const InsightJourney({
    required this.id,
    required this.title,
    required this.insights,
    required this.currentIndex,
    required this.startedAt,
    this.completedAt,
  });

  /// هل مكتملة؟
  bool get isCompleted => completedAt != null;

  /// التقدم
  double get progress =>
      insights.isNotEmpty ? (currentIndex / insights.length) * 100 : 0;

  /// السؤال الحالي
  Insight? get currentInsight =>
      currentIndex < insights.length ? insights[currentIndex] : null;

  /// الرحلة المتبقية
  int get remainingCount => insights.length - currentIndex;
}

/// =============================================================================
/// InsightProgress - تقدم البصيرة
/// =============================================================================

class InsightProgress {
  final int totalAnswered;
  final int deepAnswers;
  final int streakDays;
  final DateTime lastAnswered;
  final List<String> categoriesCompleted;

  const InsightProgress({
    required this.totalAnswered,
    required this.deepAnswers,
    required this.streakDays,
    required this.lastAnswered,
    this.categoriesCompleted = const [],
  });

  /// نسبة الإجابات العميقة
  double get deepPercent =>
      totalAnswered > 0 ? (deepAnswers / totalAnswered) * 100 : 0;

  /// الوصف
  String get description =>
      '$totalAnswered سؤال\n'
      '$deepAnswers إجابة عميقة\n'
      '$streakDays يوم متتالي';
}