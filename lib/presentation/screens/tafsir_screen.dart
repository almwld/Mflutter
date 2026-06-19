import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TafsirScreen extends StatelessWidget {
  final String verseText;
  final String surahName;
  final int ayahNumber;

  const TafsirScreen({
    super.key,
    required this.verseText,
    required this.surahName,
    required this.ayahNumber,
  });

  static const Map<String, String> _tafsirDB = {
    'الفاتحة:1': 'افتتح الله كتابه بالبسملة، وهي آية عظيمة تقال في بداية كل أمر.',
    'البقرة:255': 'آية الكرسي أعظم آية في القرآن. فيها توحيد خالص وإثبات صفات الكمال لله.',
    'الإخلاص:1': 'سورة الإخلاص تعدل ثلث القرآن. تثبت وحدانية الله.',
  };

  @override
  Widget build(BuildContext context) {
    final key = '$surahName:$ayahNumber';
    final tafsir = _tafsirDB[key] ?? 'تفسير هذه الآية يدعوك للتدبر في معانيها العميقة.';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('التفسير', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('📖 $verseText', style: TextStyle(color: Colors.white, fontSize: 22, fontFamily: 'Amiri')),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
              ),
              child: Text(tafsir, style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.8)),
            ),
          ],
        ),
      ),
    );
  }
}
