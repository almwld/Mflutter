import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('المجتمع', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('🌍 إحصائيات المجتمع', style: TextStyle(color: AppColors.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildCommunityCard('📖 آية اليوم المتداولة', 'آية الكرسي - البقرة:255'),
            _buildCommunityCard('🔬 العلم الأكثر استكشافاً', 'علم الفلك'),
            _buildCommunityCard('🔮 الصفة الأكثر تدبراً', 'الرحمن'),
            _buildCommunityCard('👥 المستخدمين النشطين', '1,234 مستخدم'),
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
                  Text('🤝 انضم إلينا', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('شارك في تدبر القرآن مع مجتمع عالمي. تعلم وعلّم.', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
