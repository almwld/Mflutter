import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';

/// =============================================================================
/// InsightProvider - مزود البصيرة
/// =============================================================================

class InsightProvider extends ChangeNotifier {
  int _currentIndex = 0;
  List<InsightItem> _insights = [];
  List<InsightItem> _completedInsights = [];
  bool _isLoading = false;
  String? _error;
  int _streakDays = 0;
  DateTime? _lastCompletedDate;

  // getters
  int get currentIndex => _currentIndex;
  List<InsightItem> get insights => _insights;
  List<InsightItem> get completedInsights => _completedInsights;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get streakDays => _streakDays;
  int get totalInsights => _insights.length;
  int get remainingInsights => _insights.length - _currentIndex;
  double get progress => _insights.isNotEmpty ? (_currentIndex / _insights.length) : 0;

  /// تهيئة أسئلة البصيرة
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // تحميل الأسئلة
      _insights = _getInitialInsights();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// الحصول على السؤال الحالي
  InsightItem? get currentInsight {
    if (_currentIndex < _insights.length) {
      return _insights[_currentIndex];
    }
    return null;
  }

  /// إكمال السؤال الحالي
  Future<void> completeCurrentInsight(String answer) async {
    if (currentInsight == null) return;

    final insight = currentInsight!;
    final completedInsight = InsightItem(
      id: insight.id,
      question: insight.question,
      type: insight.type,
      answer: answer,
      completedAt: DateTime.now(),
    );

    _completedInsights.add(completedInsight);
    _currentIndex++;

    // تحديث السلسلة
    _updateStreak();

    notifyListeners();
  }

  /// إعادة تعيين الرحلة
  void resetJourney() {
    _currentIndex = 0;
    _completedInsights = [];
    notifyListeners();
  }

  /// تحديث السلسلة
  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastCompletedDate != null) {
      final lastDate = DateTime(
        _lastCompletedDate!.year,
        _lastCompletedDate!.month,
        _lastCompletedDate!.day,
      );

      if (today.difference(lastDate).inDays == 1) {
        _streakDays++;
      } else if (today.difference(lastDate).inDays > 1) {
        _streakDays = 1;
      }
    } else {
      _streakDays = 1;
    }

    _lastCompletedDate = now;
  }

  /// الحصول على الأسئلة الأولية
  List<InsightItem> _getInitialInsights() {
    return [
      InsightItem(
        id: 1,
        question: 'ما هو أعظم سر في حياتك؟',
        type: InsightType.deep,
      ),
      InsightItem(
        id: 2,
        question: 'كيف ترى نفسك بعد عشر سنوات؟',
        type: InsightType.reflective,
      ),
      InsightItem(
        id: 3,
        question: 'ما هو الشيء الذي تخاف من اكتشافه في نفسك؟',
        type: InsightType.exploratory,
      ),
      InsightItem(
        id: 4,
        question: 'كيف تغيرت نظرتك للحياة في السنوات الأخيرة؟',
        type: InsightType.reflective,
      ),
      InsightItem(
        id: 5,
        question: 'ما هو الحلم الذي لم تحلم به بعد؟',
        type: InsightType.practical,
      ),
    ];
  }

  /// مسح الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// =============================================================================
/// InsightItem - عنصر البصيرة
/// =============================================================================

class InsightItem {
  final int id;
  final String question;
  final InsightType type;
  final String? answer;
  final DateTime? completedAt;

  const InsightItem({
    required this.id,
    required this.question,
    required this.type,
    this.answer,
    this.completedAt,
  });

  bool get isCompleted => answer != null;
}