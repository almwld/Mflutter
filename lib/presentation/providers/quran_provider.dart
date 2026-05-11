import 'package:flutter/material.dart';
import '../../data/datasources/local/quran_local_datasource.dart';
import '../../domain/entities/verse.dart';

class QuranProvider extends ChangeNotifier {
  final QuranLocalDatasource _datasource = QuranLocalDatasource();
  List<Verse> _verses = [];
  List<Map<String, dynamic>> _surahs = [];
  bool _isLoading = false;

  List<Verse> get verses => _verses;
  List<Map<String, dynamic>> get surahs => _surahs;
  bool get isLoading => _isLoading;

  Future<void> loadSurahs() async {
    _isLoading = true;
    notifyListeners();
    _surahs = await _datasource.getAllSurahs();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVersesBySurah(int surah) async {
    _isLoading = true;
    notifyListeners();
    final data = await _datasource.getVersesBySurah(surah);
    _verses = data.map((m) => Verse.fromMap(m)).toList();
    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    // basic search
  }
}
