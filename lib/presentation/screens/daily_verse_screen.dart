import 'dart:math';
import 'package:flutter/material.dart';

class DailyVerseScreen extends StatefulWidget {
  const DailyVerseScreen({super.key});

  @override
  State<DailyVerseScreen> createState() => _DailyVerseScreenState();
}

class _DailyVerseScreenState extends State<DailyVerseScreen> {
  final _verses = [
    {'text': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'ref': 'الشرح:6'},
    {'text': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ', 'ref': 'الطلاق:3'},
    {'text': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ', 'ref': 'الرعد:28'},
    {'text': 'وَقُل رَّبِّ زِدْنِي عِلْمًا', 'ref': 'طه:114'},
    {'text': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا', 'ref': 'الشرح:5'},
    {'text': 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ', 'ref': 'النور:35'},
    {'text': 'وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ', 'ref': 'البقرة:216'},
    {'text': 'ادْعُونِي أَسْتَجِبْ لَكُمْ', 'ref': 'غافر:60'},
    {'text': 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ', 'ref': 'يوسف:87'},
    {'text': 'فَاذْكُرُونِي أَذْكُرْكُمْ', 'ref': 'البقرة:152'},
  ];

  late int _index;

  @override
  void initState() {
    super.initState();
    _index = DateTime.now().day % _verses.length;
  }

  @override
  Widget build(BuildContext context) {
    final verse = _verses[_index];
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('📅 آية اليوم', style: TextStyle(color: Color(0xFFFFD700)))),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 40),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: Column(children: [
                Text('﴿ ${verse['text']} ﴾', style: const TextStyle(color: Color(0xFFFFECB3), fontSize: 24, fontFamily: 'Amiri', height: 2), textAlign: TextAlign.center, textDirection: TextDirection.rtl),
                const SizedBox(height: 12),
                Text(verse['ref']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 14)),
              ]),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => setState(() => _index = (_index + 1) % _verses.length),
              icon: const Icon(Icons.refresh),
              label: const Text('آية أخرى'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: const Color(0xFF1A237E), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ]),
        ),
      ),
    );
  }
}
