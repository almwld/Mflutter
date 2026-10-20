import '../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GreatVersesScreen extends StatelessWidget {
  const GreatVersesScreen({super.key});

  static const verses = [
    {'ref': '2:255', 'title': 'آية الكرسي', 'desc': 'أعظم آية في القرآن'},
    {'ref': '1:1', 'title': 'البسملة', 'desc': 'بداية كل سورة'},
    {'ref': '112:1', 'title': 'الإخلاص', 'desc': 'تعدل ثلث القرآن'},
    {'ref': '24:35', 'title': 'آية النور', 'desc': 'الله نور السماوات والأرض'},
    {'ref': '36:1', 'title': 'يس', 'desc': 'قلب القرآن'},
    {'ref': '55:13', 'title': 'الرحمن', 'desc': 'فبأي آلاء ربكما تكذبان'},
    {'ref': '67:1', 'title': 'تبارك', 'desc': 'تبارك الذي بيده الملك'},
    {'ref': '3:190', 'title': 'آية التفكر', 'desc': 'إن في خلق السماوات والأرض'},
    {'ref': '59:22', 'title': 'آية الأسماء', 'desc': 'هو الله الذي لا إله إلا هو'},
    {'ref': '56:1', 'title': 'الواقعة', 'desc': 'إذا وقعت الواقعة'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('🌟 آيات عظيمة', style: TextStyle(color: AppColors.gold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: verses.length,
        itemBuilder: (_, i) {
          final v = verses[i];
          return Card(
            color: AppColors.primaryNavy.withOpacity(0.6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.gold,
                child: Text('${i + 1}', style: const TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
              ),
              title: Text(v['title']!, style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
              subtitle: Text('${v['desc']}\n${v['ref']}', style: const TextStyle(color: Colors.white54)),
            ),
          );
        },
      ),
    );
  }
}
