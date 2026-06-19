import 'package:flutter/material.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  static const insights = [
    {'title': '🌟 آية النور', 'verse': 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ', 'ref': '24:35', 'science': 'فيزياء الضوء', 'desc': 'تشبيه النور الإلهي بالمشكاة والمصباح'},
    {'title': '🌌 توسع الكون', 'verse': 'وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ وَإِنَّا لَمُوسِعُونَ', 'ref': '51:47', 'science': 'علم الفلك', 'desc': 'اكتشف إدوين هابل توسع الكون 1929'},
    {'title': '🧬 خلق الإنسان', 'verse': 'وَلَقَدْ خَلَقْنَا الْإِنسَانَ مِن سُلَالَةٍ مِّن طِينٍ', 'ref': '23:12', 'science': 'علم الأجنة', 'desc': 'مراحل خلق الجنين في القرآن'},
    {'title': '🌊 البحر المسجور', 'verse': 'وَالْبَحْرِ الْمَسْجُورِ', 'ref': '52:6', 'science': 'علم المحيطات', 'desc': 'اكتشاف فوهات النار في قاع المحيط'},
    {'title': '⛰️ الجبال أوتاداً', 'verse': 'وَالْجِبَالَ أَوْتَادًا', 'ref': '78:7', 'science': 'الجيولوجيا', 'desc': 'الجبال لها جذور عميقة كالأوتاد'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('💡 التدبر', style: TextStyle(color: Color(0xFFFFD700)))),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: insights.length,
        itemBuilder: (_, i) {
          final item = insights[i];
          return Card(
            color: const Color(0xFF1A237E).withOpacity(0.6),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(item['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('﴿ ${item['verse']} ﴾', style: const TextStyle(color: Color(0xFFFFECB3), fontSize: 16, fontFamily: 'Amiri', height: 1.8), textDirection: TextDirection.rtl),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(item['ref']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF50C878).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text('🔬 ${item['science']}', style: const TextStyle(color: Color(0xFF50C878), fontSize: 11))),
                ]),
                const SizedBox(height: 6),
                Text(item['desc']!, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ]),
            ),
          );
        },
      ),
    );
  }
}
