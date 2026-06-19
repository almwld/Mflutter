import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _results = [];
  String _query = '';
  bool _searching = false;

  List<Map<String, dynamic>> get results => _results;
  String get query => _query;
  bool get searching => _searching;

  void search(String q, Map<String, dynamic> quran) {
    _query = q;
    _searching = true;
    notifyListeners();

    _results = [];
    for (final surahNum in quran.keys) {
      final verses = quran[surahNum] as List<dynamic>;
      for (int i = 0; i < verses.length; i++) {
        final text = verses[i]['text'] ?? '';
        if (text.contains(q)) {
          _results.add({'surah': int.parse(surahNum), 'ayah': i + 1, 'text': text});
          if (_results.length >= 50) break;
        }
      }
    }

    _searching = false;
    notifyListeners();
  }
}
