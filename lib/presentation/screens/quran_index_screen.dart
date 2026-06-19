import 'package:flutter/material.dart';

class QuranIndexScreen extends StatelessWidget {
  const QuranIndexScreen({super.key});

  static const surahs = [
    {'n': 1, 'name': 'الفاتحة', 'page': 1, 'verses': 7, 'type': 'مكية'},
    {'n': 2, 'name': 'البقرة', 'page': 2, 'verses': 286, 'type': 'مدنية'},
    {'n': 3, 'name': 'آل عمران', 'page': 50, 'verses': 200, 'type': 'مدنية'},
    {'n': 4, 'name': 'النساء', 'page': 77, 'verses': 176, 'type': 'مدنية'},
    {'n': 5, 'name': 'المائدة', 'page': 106, 'verses': 120, 'type': 'مدنية'},
    {'n': 6, 'name': 'الأنعام', 'page': 128, 'verses': 165, 'type': 'مكية'},
    {'n': 7, 'name': 'الأعراف', 'page': 151, 'verses': 206, 'type': 'مكية'},
    {'n': 8, 'name': 'الأنفال', 'page': 177, 'verses': 75, 'type': 'مدنية'},
    {'n': 9, 'name': 'التوبة', 'page': 187, 'verses': 129, 'type': 'مدنية'},
    {'n': 10, 'name': 'يونس', 'page': 208, 'verses': 109, 'type': 'مكية'},
    {'n': 36, 'name': 'يس', 'page': 440, 'verses': 83, 'type': 'مكية'},
    {'n': 55, 'name': 'الرحمن', 'page': 531, 'verses': 78, 'type': 'مدنية'},
    {'n': 67, 'name': 'الملك', 'page': 562, 'verses': 30, 'type': 'مكية'},
    {'n': 112, 'name': 'الإخلاص', 'page': 604, 'verses': 4, 'type': 'مكية'},
    {'n': 113, 'name': 'الفلق', 'page': 604, 'verses': 5, 'type': 'مكية'},
    {'n': 114, 'name': 'الناس', 'page': 604, 'verses': 6, 'type': 'مكية'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('📖 فهرس السور', style: TextStyle(color: Color(0xFFFFD700)))),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: surahs.length,
        itemBuilder: (_, i) {
          final s = surahs[i];
          return Card(
            color: const Color(0xFF1A237E).withOpacity(0.6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFFD700),
                child: Text('${s['n']}', style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
              ),
              title: Text(s['name']!, style: const TextStyle(color: Color(0xFFFFD700), fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
              subtitle: Text('${s['verses']} آية • ${s['type']} • صفحة ${s['page']}', style: const TextStyle(color: Colors.white54)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
            ),
          );
        },
      ),
    );
  }
}
