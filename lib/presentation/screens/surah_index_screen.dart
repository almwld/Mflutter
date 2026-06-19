import 'package:flutter/material.dart';

/// 📖 فهرس سور القرآن — تصميم ذهبي فاخر
class SurahIndexScreen extends StatelessWidget {
  const SurahIndexScreen({super.key});

  static const List<Map<String, dynamic>> surahs = [
    {'number': 1, 'name': 'الفاتحة', 'englishName': 'Al-Fatiha', 'verses': 7, 'type': 'مكية'},
    {'number': 2, 'name': 'البقرة', 'englishName': 'Al-Baqarah', 'verses': 286, 'type': 'مدنية'},
    {'number': 3, 'name': 'آل عمران', 'englishName': 'Aal-E-Imran', 'verses': 200, 'type': 'مدنية'},
    {'number': 4, 'name': 'النساء', 'englishName': 'An-Nisa', 'verses': 176, 'type': 'مدنية'},
    {'number': 5, 'name': 'المائدة', 'englishName': 'Al-Maidah', 'verses': 120, 'type': 'مدنية'},
    {'number': 6, 'name': 'الأنعام', 'englishName': 'Al-Anaam', 'verses': 165, 'type': 'مكية'},
    {'number': 7, 'name': 'الأعراف', 'englishName': 'Al-Araf', 'verses': 206, 'type': 'مكية'},
    {'number': 8, 'name': 'الأنفال', 'englishName': 'Al-Anfal', 'verses': 75, 'type': 'مدنية'},
    {'number': 9, 'name': 'التوبة', 'englishName': 'At-Tawbah', 'verses': 129, 'type': 'مدنية'},
    {'number': 10, 'name': 'يونس', 'englishName': 'Yunus', 'verses': 109, 'type': 'مكية'},
    {'number': 11, 'name': 'هود', 'englishName': 'Hud', 'verses': 123, 'type': 'مكية'},
    {'number': 12, 'name': 'يوسف', 'englishName': 'Yusuf', 'verses': 111, 'type': 'مكية'},
    {'number': 13, 'name': 'الرعد', 'englishName': 'Ar-Rad', 'verses': 43, 'type': 'مدنية'},
    {'number': 14, 'name': 'إبراهيم', 'englishName': 'Ibrahim', 'verses': 52, 'type': 'مكية'},
    {'number': 15, 'name': 'الحجر', 'englishName': 'Al-Hijr', 'verses': 99, 'type': 'مكية'},
    {'number': 16, 'name': 'النحل', 'englishName': 'An-Nahl', 'verses': 128, 'type': 'مكية'},
    {'number': 17, 'name': 'الإسراء', 'englishName': 'Al-Isra', 'verses': 111, 'type': 'مكية'},
    {'number': 18, 'name': 'الكهف', 'englishName': 'Al-Kahf', 'verses': 110, 'type': 'مكية'},
    {'number': 19, 'name': 'مريم', 'englishName': 'Maryam', 'verses': 98, 'type': 'مكية'},
    {'number': 20, 'name': 'طه', 'englishName': 'Ta-Ha', 'verses': 135, 'type': 'مكية'},
    {'number': 36, 'name': 'يس', 'englishName': 'Ya-Sin', 'verses': 83, 'type': 'مكية'},
    {'number': 55, 'name': 'الرحمن', 'englishName': 'Ar-Rahman', 'verses': 78, 'type': 'مدنية'},
    {'number': 67, 'name': 'الملك', 'englishName': 'Al-Mulk', 'verses': 30, 'type': 'مكية'},
    {'number': 112, 'name': 'الإخلاص', 'englishName': 'Al-Ikhlas', 'verses': 4, 'type': 'مكية'},
    {'number': 113, 'name': 'الفلق', 'englishName': 'Al-Falaq', 'verses': 5, 'type': 'مكية'},
    {'number': 114, 'name': 'الناس', 'englishName': 'An-Nas', 'verses': 6, 'type': 'مكية'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text(
          '📖 فهرس السور',
          style: TextStyle(color: Color(0xFFFFD700), fontFamily: 'Amiri'),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          return _buildSurahCard(context, surah);
        },
      ),
    );
  }

  Widget _buildSurahCard(BuildContext context, Map<String, dynamic> surah) {
    final isEven = surah['number'] % 2 == 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            const Color(0xFF1A237E).withOpacity(isEven ? 0.8 : 0.5),
            const Color(0xFF0D1B2A).withOpacity(isEven ? 0.5 : 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuranPageScreen(
                  surahNumber: surah['number'],
                  surahName: surah['name'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // رقم السورة بدائرة ذهبية
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${surah['number']}',
                      style: const TextStyle(
                        color: Color(0xFF1A237E),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // اسم السورة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        surah['name'],
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 20,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${surah['englishName']} • ${surah['verses']} آية • ${surah['type']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
