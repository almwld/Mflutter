import 'package:flutter/material.dart';
import '../../data/datasources/local/quran_local_datasource.dart';
import '../../domain/entities/verse.dart';

/// =============================================================================
/// QuranProvider - مزود القرآن
/// =============================================================================

class QuranProvider extends ChangeNotifier {
  final QuranLocalDatasource _datasource = QuranLocalDatasource();

  List<Surah> _surahs = [];
  List<Verse> _currentVerses = [];
  List<Verse> _searchResults = [];
  Verse? _dailyVerse;
  Verse? _randomVerse;
  bool _isLoading = false;
  String? _error;

  // getters
  List<Surah> get surahs => _surahs;
  List<Verse> get currentVerses => _currentVerses;
  List<Verse> get searchResults => _searchResults;
  Verse? get dailyVerse => _dailyVerse;
  Verse? get randomVerse => _randomVerse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// تحميل جميع السور
  Future<void> loadSurahs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _datasource.getAllSurahs();
      _dailyVerse = await _datasource.getDailyVerse();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تحميل آيات سورة
  Future<void> loadSurahVerses(int surahNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentVerses = await _datasource.getVersesBySurah(surahNumber);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// البحث في القرآن
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _datasource.searchVerses(query);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// جلب آية عشوائية
  Future<void> getVerse() async {
    _isLoading = true;
    notifyListeners();

    try {
      _randomVerse = await _datasource.getVerse();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// مسح البحث
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  /// مسح الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }
}