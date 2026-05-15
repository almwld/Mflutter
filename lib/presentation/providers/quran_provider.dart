import 'package:flutter/material.dart';

class QuranProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _surahs = [];
  final List<Map<String, dynamic>> _verses = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get surahs => _surahs;
  List<Map<String, dynamic>> get verses => _verses;
  bool get isLoading => _isLoading;

  QuranProvider() {
    _surahs.addAll([
      {'surah': 1, 'name': 'الفاتحة'}, {'surah': 2, 'name': 'البقرة'},
      {'surah': 3, 'name': 'آل عمران'}, {'surah': 4, 'name': 'النساء'},
      {'surah': 5, 'name': 'المائدة'}, {'surah': 112, 'name': 'الإخلاص'},
      {'surah': 113, 'name': 'الفلق'}, {'surah': 114, 'name': 'الناس'},
    ]);
  }

  void loadVerses(int surah) {
    _isLoading = true;
    notifyListeners();
    _verses.clear();
    _verses.add({'text': 'آيات سورة $surah', 'ayah': 1});
    _isLoading = false;
    notifyListeners();
  }
}
