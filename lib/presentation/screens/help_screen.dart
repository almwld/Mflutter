import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('المساعدة', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildSection('📖 المحادثة', '• اكتب أي سؤال عن القرآن\n• استخدم الميكروفون للبحث الصوتي\n• احصل على آيات + علوم + صفات'),
          _buildSection('🔢 الجمل', '• أدخل نصاً عربياً\n• احصل على الجمل الكبير والصغير والوسط\n• اكتشف العنصر والكوكب والبرج'),
          _buildSection('📚 القرآن', '• تصفح 114 سورة\n• اقرأ الآيات كاملة\n• ابحث عن كلمات'),
          _buildSection('🔮 الإعجاز', '• اكتشف الإعجاز العددي\n• توازن الكلمات\n• النسبة الذهبية'),
          _buildSection('💡 البصيرة', '• أسئلة تأملية يومية\n• 3 مستويات تتطور معك\n• تتبع تقدمك'),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryNavy.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(body, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.8)),
        ],
      ),
    );
  }
}
