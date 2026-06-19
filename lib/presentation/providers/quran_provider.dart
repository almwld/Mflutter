import 'package:flutter/material.dart';

class QuranProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _surahs = [];
  List<Map<String, dynamic>> _verses = [];
  bool _loading = false;

  List<Map<String, dynamic>> get surahs => _surahs;
  List<Map<String, dynamic>> get verses => _verses;
  bool get loading => _loading;

  void loadSurahs() {
    _loading = true;
    notifyListeners();
    
    // بيانات مؤقتة للـ 114 سورة
    _surahs = List.generate(114, (i) => {
      'number': i + 1,
      'name': ['الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة'][i] ?? 'سورة ${i + 1}',
      'versesCount': [7, 286, 200, 176, 120][i] ?? 30,
    });
    
    _loading = false;
    notifyListeners();
  }

  void loadVersesBySurah(int surahNumber) {
    _loading = true;
    notifyListeners();
    
    // بيانات مؤقتة
    _verses = List.generate(7, (i) => {
      'text': 'آية ${i + 1} من السورة $surahNumber',
      'number': i + 1,
      'surahNumber': surahNumber,
    });
    
    _loading = false;
    notifyListeners();
  }
}
