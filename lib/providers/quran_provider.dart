import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quran_service.dart';
import '../models/verse.dart';

/// =============================================================================
/// QuranProvider - مزود حالة القرآن
/// =============================================================================

class QuranProvider extends ChangeNotifier {
  final QuranService _quranService = QuranService();

  List<SurahInfo> _surahs = [];
  List<Verse> _currentVerses = [];
  List<Verse> _searchResults = [];
  Verse? _dailyVerse;
  bool _isLoading = false;
  String? _error;
  int _selectedSurah = 0;

  List<SurahInfo> get surahs => _surahs;
  List<Verse> get currentVerses => _currentVerses;
  List<Verse> get searchResults => _searchResults;
  Verse? get dailyVerse => _dailyVerse;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedSurah => _selectedSurah;

  /// تحميل السور
  Future<void> loadSurahs() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _quranService.loadFromDatabase();
      _surahs = await _quranService.getAllSurahs();
      _error = null;
    } catch (e) {
      _error = 'فشل تحميل السور';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// اختيار سورة
  Future<void> selectSurah(int surahNumber) async {
    _selectedSurah = surahNumber;
    _isLoading = true;
    notifyListeners();

    try {
      _currentVerses = await _quranService.getSurahVerses(surahNumber);
      _error = null;
    } catch (e) {
      _error = 'فشل تحميل آيات السورة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// البحث في القرآن
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _quranService.search(query);
      _error = null;
    } catch (e) {
      _error = 'فشل البحث';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحميل الآية اليومية
  Future<void> loadDailyVerse() async {
    try {
      _dailyVerse = await _quranService.getDailyVerse();
      notifyListeners();
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  /// الحصول على آية عشوائية
  Future<Verse> getRandomVerse() async {
    return await _quranService.getRandomVerse();
  }

  /// مسح نتائج البحث
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  /// إعادة تعيين السورة المحددة
  void clearSelection() {
    _selectedSurah = 0;
    _currentVerses = [];
    notifyListeners();
  }
}