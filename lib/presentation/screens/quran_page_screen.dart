import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 📄 شاشة تصفح المصحف — عرض الصفحات كاملة
class QuranPageScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranPageScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranPageScreen> createState() => _QuranPageScreenState();
}

class _QuranPageScreenState extends State<QuranPageScreen> {
  List<dynamic> _verses = [];
  bool _loading = true;
  bool _showTranslation = false;
  int _fontSize = 22;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  Future<void> _loadSurah() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/unified_quran.json');
      final data = jsonDecode(jsonStr);
      setState(() {
        _verses = List<dynamic>.from(data[widget.surahNumber.toString()] ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _verses = _getBuiltInSurah(widget.surahNumber);
        _loading = false;
      });
    }
  }

  List<dynamic> _getBuiltInSurah(int number) {
    // بيانات مضمنة للسور الشائعة
    const builtIn = {
      1: [
        {'text': 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'},
        {'text': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
        {'text': 'الرَّحْمَنِ الرَّحِيمِ'},
        {'text': 'مَالِكِ يَوْمِ الدِّينِ'},
        {'text': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ'},
        {'text': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ'},
        {'text': 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ'},
      ],
      112: [
        {'text': 'قُلْ هُوَ اللَّهُ أَحَدٌ'},
        {'text': 'اللَّهُ الصَّمَدُ'},
        {'text': 'لَمْ يَلِدْ وَلَمْ يُولَدْ'},
        {'text': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ'},
      ],
    };
    return builtIn[number] ?? [{'text': 'جاري تحميل السورة...'}];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(
          widget.surahName,
          style: const TextStyle(color: Color(0xFFFFD700), fontFamily: 'Amiri'),
        ),
        backgroundColor: const Color(0xFF1A237E),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: Color(0xFFFFD700)),
            onPressed: () => setState(() => _showTranslation = !_showTranslation),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase, color: Color(0xFFFFD700)),
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(16, 32)),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease, color: Color(0xFFFFD700)),
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(16, 32)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0E27),
                    Color(0xFF1A237E),
                    Color(0xFF0A0E27),
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _verses.length,
                itemBuilder: (context, index) {
                  final verse = _verses[index];
                  final text = verse['text'] ?? '';
                  final ayahNum = index + 1;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: _fontSize.toDouble(),
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFECB3),
                            height: 2.2,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '﴿$ayahNum﴾',
                            style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
