import 'package:flutter/material.dart';
import '../../data/datasources/local/quran_local_datasource.dart';
import '../../domain/entities/verse.dart';

class QuranProvider extends ChangeNotifier {
  final QuranLocalDatasource _datasource = QuranLocalDatasource();
  List<Verse> _currentVerses = [];
  List<Verse> _searchResults = [];
  Verse? _dailyVerse;
  Verse? _randomVerse;
  bool _isLoading = false;

  List<Verse> get currentVerses => _currentVerses;
  List<Verse> get searchResults => _searchResults;
  Verse? get dailyVerse => _dailyVerse;
  Verse? get randomVerse => _randomVerse;
  bool get isLoading => _isLoading;

  Future<void> loadVersesBySurah(int surahNumber) async {
    _isLoading = true;
    notifyListeners();
    final data = await _datasource.getVersesBySurah(surahNumber);
    _currentVerses = data.map((m) => Verse.fromMap(m)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchVerses(String query) async {
    _isLoading = true;
    notifyListeners();
    final data = await _datasource.searchVerses(query);
    _searchResults = data.map((m) => Verse.fromMap(m)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadRandomVerse() async {
    final data = await _datasource.getVerse(1, 1);
    if (data != null) _randomVerse = Verse.fromMap(data);
    notifyListeners();
  }
}

  Future<void> loadSurahs() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 500));
    _isLoading = false;
    notifyListeners();
  }
