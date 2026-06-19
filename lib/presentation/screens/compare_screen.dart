import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String _verse1 = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
  String _verse2 = 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('مقارنة الآيات', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVerseCard(_verse1, 'الفاتحة:1', '786', 'الرحمن، الرحيم', 'علم اللغة'),
            SizedBox(height: 20),
            Icon(Icons.compare_arrows, color: AppColors.primaryGold, size: 40),
            SizedBox(height: 20),
            _buildVerseCard(_verse2, 'الفاتحة:2', '632', 'الرب، العالمين', 'علم التوحيد'),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('🔍 التحليل المقارن', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('• الآيتان من سورة الفاتحة', style: TextStyle(color: Colors.white70)),
                  Text('• الأولى: بسم الله - افتتاحية', style: TextStyle(color: Colors.white70)),
                  Text('• الثانية: حمد الله - استمرار', style: TextStyle(color: Colors.white70)),
                  Text('• الجمع بينهما: بدء + استمرار = كمال', style: TextStyle(color: AppColors.primaryGold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(String text, String ref, String jummal, String attrs, String sci) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryNavy.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('📖 $text', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Amiri')),
          SizedBox(height: 8),
          Text('📍 $ref | جمل: $jummal', style: TextStyle(color: Colors.white54)),
          Text('🔮 $attrs | 🔬 $sci', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
