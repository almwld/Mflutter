import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('إحصائيات', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStatCard('📊 الأسئلة', '34 سؤالاً'),
            _buildStatCard('📖 الآيات المستشهد بها', '12 آية'),
            _buildStatCard('🔬 العلوم المستكشفة', '8 علوم'),
            _buildStatCard('🔮 الصفات المتدبرة', '15 صفة'),
            _buildStatCard('💡 مستوى البصيرة', 'المستوى 2'),
            _buildStatCard('🔥 أيام الاستخدام', '5 أيام'),
            SizedBox(height: 20),
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
                  Text('📈 تقدمك', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  LinearProgressIndicator(value: 0.65, backgroundColor: AppColors.surface, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold)),
                  SizedBox(height: 8),
                  Text('65% من رحلة المعرفة', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryNavy.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: TextStyle(color: AppColors.primaryGold, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}
