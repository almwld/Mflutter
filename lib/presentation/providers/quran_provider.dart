import 'package:flutter/material.dart';
import '../../services/quran_loader_service.dart';

class QuranProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _surahs = [];
  List<Map<String, dynamic>> _verses = [];
  bool _loading = false;
  List<Map<String, dynamic>> get surahs => _surahs;
  List<Map<String, dynamic>> get verses => _verses;
  bool get loading => _loading;

  Future<void> loadSurahs() async {
    _loading = true; notifyListeners();
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      final grouped = <int, Map<String, dynamic>>{};
      for (final ayah in ayahs) {
        grouped.putIfAbsent(ayah.surahNumber, () => {'number': ayah.surahNumber, 'name': ayah.surahName, 'versesCount': 0});
        grouped[ayah.surahNumber]!['versesCount'] = (grouped[ayah.surahNumber]!['versesCount'] as int) + 1;
      }
      _surahs = grouped.values.toList()..sort((a,b)=>(a['number'] as int).compareTo(b['number'] as int));
    } finally { _loading = false; notifyListeners(); }
  }

  Future<void> loadVersesBySurah(int surahNumber) async {
    _loading = true; notifyListeners();
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      _verses = ayahs.where((a)=>a.surahNumber==surahNumber).map((a)=>{'text':a.text,'number':a.ayahNumber,'surahNumber':a.surahNumber}).toList();
    } finally { _loading = false; notifyListeners(); }
  }
}
