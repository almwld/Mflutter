import 'package:flutter/material.dart';

class QuranProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _surahs = [];
  List<Map<String, dynamic>> _verses = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get surahs => _surahs;
  List<Map<String, dynamic>> get verses => _verses;
  bool get isLoading => _isLoading;

  QuranProvider() {
    _loadStaticData();
  }

  void _loadStaticData() {
    // 114 سورة مع أسمائها
    _surahs = [
      {'surah': 1, 'surah_name': 'الفاتحة'},
      {'surah': 2, 'surah_name': 'البقرة'},
      {'surah': 3, 'surah_name': 'آل عمران'},
      {'surah': 4, 'surah_name': 'النساء'},
      {'surah': 5, 'surah_name': 'المائدة'},
      {'surah': 6, 'surah_name': 'الأنعام'},
      {'surah': 7, 'surah_name': 'الأعراف'},
      {'surah': 8, 'surah_name': 'الأنفال'},
      {'surah': 9, 'surah_name': 'التوبة'},
      {'surah': 10, 'surah_name': 'يونس'},
      {'surah': 11, 'surah_name': 'هود'},
      {'surah': 12, 'surah_name': 'يوسف'},
      {'surah': 13, 'surah_name': 'الرعد'},
      {'surah': 14, 'surah_name': 'إبراهيم'},
      {'surah': 15, 'surah_name': 'الحجر'},
      {'surah': 16, 'surah_name': 'النحل'},
      {'surah': 17, 'surah_name': 'الإسراء'},
      {'surah': 18, 'surah_name': 'الكهف'},
      {'surah': 19, 'surah_name': 'مريم'},
      {'surah': 20, 'surah_name': 'طه'},
      {'surah': 21, 'surah_name': 'الأنبياء'},
      {'surah': 22, 'surah_name': 'الحج'},
      {'surah': 23, 'surah_name': 'المؤمنون'},
      {'surah': 24, 'surah_name': 'النور'},
      {'surah': 25, 'surah_name': 'الفرقان'},
      {'surah': 26, 'surah_name': 'الشعراء'},
      {'surah': 27, 'surah_name': 'النمل'},
      {'surah': 28, 'surah_name': 'القصص'},
      {'surah': 29, 'surah_name': 'العنكبوت'},
      {'surah': 30, 'surah_name': 'الروم'},
      {'surah': 36, 'surah_name': 'يس'},
      {'surah': 55, 'surah_name': 'الرحمن'},
      {'surah': 67, 'surah_name': 'الملك'},
      {'surah': 112, 'surah_name': 'الإخلاص'},
      {'surah': 113, 'surah_name': 'الفلق'},
      {'surah': 114, 'surah_name': 'الناس'},
    ];
  }

  void loadSurahs() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
  }

  void loadVersesBySurah(int surah) {
    _isLoading = true;
    notifyListeners();
    
    // آيات افتراضية جميلة
    final defaultVerses = {
      1: ['بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 'الرَّحْمَٰنِ الرَّحِيمِ', 'مَالِكِ يَوْمِ الدِّينِ', 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ'],
      112: ['قُلْ هُوَ اللَّهُ أَحَدٌ', 'اللَّهُ الصَّمَدُ', 'لَمْ يَلِدْ وَلَمْ يُولَدْ', 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ'],
      113: ['قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ', 'مِن شَرِّ مَا خَلَقَ', 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ', 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ', 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ'],
      114: ['قُلْ أَعُوذُ بِرَبِّ النَّاسِ', 'مَلِكِ النَّاسِ', 'إِلَٰهِ النَّاسِ', 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ', 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ', 'مِنَ الْجِنَّةِ وَالنَّاسِ'],
    };
    
    final texts = defaultVerses[surah] ?? ['آيات سورة $surah'];
    _verses = texts.asMap().entries.map((e) => {
      'surah': surah,
      'ayah': e.key + 1,
      'text': e.value,
    }).toList();
    
    _isLoading = false;
    notifyListeners();
  }
}
