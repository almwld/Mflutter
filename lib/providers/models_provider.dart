import 'package:flutter/material.dart';
import '../utils/science_constants.dart';

/// =============================================================================
/// ModelsProvider - مزود حالة النماذج
/// =============================================================================

class ModelsProvider extends ChangeNotifier {
  bool _modelsLoaded = false;
  bool _isLoadingModels = false;
  List<String> _availableModels = [];
  List<String> _loadedModels = [];
  String? _error;

  bool get modelsLoaded => _modelsLoaded;
  bool get isLoadingModels => _isLoadingModels;
  List<String> get availableModels => _availableModels;
  List<String> get loadedModels => _loadedModels;
  String? get error => _error;

  /// فحص وجود النماذج
  Future<bool> checkModelsExist() async {
    _isLoadingModels = true;
    notifyListeners();

    try {
      // محاكاة فحص النماذج
      await Future.delayed(const Duration(milliseconds: 500));
      _availableModels = [
        'energy_analysis',
        'pattern_discovery',
        'topic_classification',
        'verse_prediction',
        'makki_madani',
      ];
      _error = null;
    } catch (e) {
      _error = 'فشل فحص النماذج';
      _availableModels = [];
    } finally {
      _isLoadingModels = false;
      notifyListeners();
    }

    return _availableModels.isNotEmpty;
  }

  /// تحميل النماذج
  Future<void> loadModels() async {
    _isLoadingModels = true;
    notifyListeners();

    try {
      // محاكاة تحميل النماذج
      await Future.delayed(const Duration(seconds: 1));
      _loadedModels = List.from(_availableModels);
      _modelsLoaded = true;
      _error = null;
    } catch (e) {
      _error = 'فشل تحميل النماذج';
      _loadedModels = [];
    } finally {
      _isLoadingModels = false;
      notifyListeners();
    }
  }

  /// إيقاف تحميل نموذج
  Future<void> unloadModel(String modelName) async {
    _loadedModels.remove(modelName);
    notifyListeners();
  }

  /// الحصول على معلومات النموذج
  Map<String, dynamic> getModelInfo(String modelName) {
    return {
      'name': modelName,
      'loaded': _loadedModels.contains(modelName),
      'available': _availableModels.contains(modelName),
    };
  }
}

/// =============================================================================
/// InsightProvider - مزود حالة البصيرة
/// =============================================================================

class InsightProvider extends ChangeNotifier {
  List<InsightQuestion> _dailyInsights = [];
  List<InsightQuestion> _allInsights = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  List<InsightQuestion> get dailyInsights => _dailyInsights;
  List<InsightQuestion> get allInsights => _allInsights;
  InsightQuestion? get currentInsight =>
      _dailyInsights.isNotEmpty ? _dailyInsights[_currentIndex] : null;
  bool get isLoading => _isLoading;

  /// تحميل أسئلة البصيرة
  Future<void> loadInsights() async {
    _isLoading = true;
    notifyListeners();

    try {
      // محاكاة تحميل البيانات
      await Future.delayed(const Duration(milliseconds: 500));

      _allInsights = _generateInsights();
      _dailyInsights = _allInsights.take(5).toList();
    } catch (e) {
      _allInsights = [];
      _dailyInsights = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// السؤال التالي
  void nextInsight() {
    if (_currentIndex < _dailyInsights.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// السؤال السابق
  void previousInsight() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// توليد أسئلة البصيرة
  List<InsightQuestion> _generateInsights() {
    return [
      InsightQuestion(
        id: '1',
        question: 'ما هو السر المخفي في الرقم 19؟',
        category: 'القرآن',
        difficulty: 'صعب',
        hint: 'اربط بين سورة المدثر وجمل الحروف',
      ),
      InsightQuestion(
        id: '2',
        question: 'كيف تؤثر العناصر الأربعة على تصرفاتك؟',
        category: 'العلوم',
        difficulty: 'متوسط',
        hint: 'فكر في طبيعة الماء والنار',
      ),
      InsightQuestion(
        id: '3',
        question: 'ما العلاقة بين الأسماء الحسنى والابتهاج؟',
        category: 'التأمل',
        difficulty: 'سهل',
        hint: 'التفكر في معاني الأسماء',
      ),
      InsightQuestion(
        id: '4',
        question: 'لماذا كان العدد 7 مقدساً في كل الأديان؟',
        category: 'الحكمة',
        difficulty: 'صعب',
        hint: 'العد التنازلي والتسبيح',
      ),
      InsightQuestion(
        id: '5',
        question: 'ما سر البسملة في بداية كل سورة؟',
        category: 'القرآن',
        difficulty: 'متوسط',
        hint: 'الربط بين البركة والحماية',
      ),
    ];
  }
}

/// =============================================================================
/// InsightQuestion - سؤال البصيرة
/// =============================================================================

class InsightQuestion {
  final String id;
  final String question;
  final String category;
  final String difficulty;
  final String hint;

  InsightQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.difficulty,
    required this.hint,
  });
}