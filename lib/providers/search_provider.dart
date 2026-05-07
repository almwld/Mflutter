import 'package:flutter/material.dart';
import '../models/verse.dart';
import '../services/quran_service.dart';

/// =============================================================================
/// SearchProvider - مزود حالة البحث
/// =============================================================================

class SearchProvider extends ChangeNotifier {
  final QuranService _quranService = QuranService();

  String _query = '';
  List<Verse> _results = [];
  bool _isSearching = false;
  List<String> _recentSearches = [];

  String get query => _query;
  List<Verse> get results => _results;
  bool get isSearching => _isSearching;
  List<String> get recentSearches => _recentSearches;

  /// البحث
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _results = [];
      _query = '';
      notifyListeners();
      return;
    }

    _query = query;
    _isSearching = true;
    notifyListeners();

    try {
      _results = await _quranService.search(query);

      // إضافة للبحث recent
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches.removeLast();
        }
      }
    } catch (e) {
      _results = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// مسح البحث
  void clear() {
    _query = '';
    _results = [];
    notifyListeners();
  }

  /// مسح البحث recent
  void clearRecentSearches() {
    _recentSearches = [];
    notifyListeners();
  }

  /// حذف عنصر من البحث recent
  void removeFromRecent(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }
}