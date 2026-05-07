import 'package:flutter/material.dart';
import '../../domain/entities/verse.dart';

/// =============================================================================
/// SearchProvider - مزود البحث
/// =============================================================================

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<Verse> _results = [];
  bool _isSearching = false;
  String? _error;
  List<String> _recentSearches = [];
  List<String> _suggestions = [];

  // getters
  String get query => _query;
  List<Verse> get results => _results;
  bool get isSearching => _isSearching;
  String? get error => _error;
  List<String> get recentSearches => _recentSearches;
  List<String> get suggestions => _suggestions;
  bool get hasResults => _results.isNotEmpty;

  /// تحديث الاستعلام
  void updateQuery(String query) {
    _query = query;
    notifyListeners();
  }

  /// تنفيذ البحث
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      clearResults();
      return;
    }

    _query = query;
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      // محاكاة البحث
      await Future.delayed(const Duration(milliseconds: 500));

      // إضافة للبحث الأخير
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches.removeLast();
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isSearching = false;
    notifyListeners();
  }

  /// مسح النتائج
  void clearResults() {
    _results = [];
    _query = '';
    _error = null;
    notifyListeners();
  }

  /// مسح البحث الأخير
  void clearRecentSearches() {
    _recentSearches = [];
    notifyListeners();
  }

  /// حذف عنصر من البحث الأخير
  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }

  /// تحديث الاقتراحات
  void updateSuggestions(List<String> suggestions) {
    _suggestions = suggestions;
    notifyListeners();
  }
}