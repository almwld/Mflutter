import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CosmicServicesScreen extends StatelessWidget {
  const CosmicServicesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الخدمات الكونية', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _buildCard('🌙 مذكرات أحلام', 'سجل أحلامك واربطها بالرموز القرآنية'),
        _buildCard('🔮 تشابك كمي', 'محاكاة التشابك الكمي للتأمل'),
        _buildCard('🎵 إيقاع حيوي', 'ترددات صوتية للتركيز والتأمل'),
        _buildCard('🌟 مزامنة فلكية', 'مواقيت فلكية للتدبر'),
        _buildCard('⏳ كبسولة زمنية', 'رسالة لنفسك في المستقبل'),
        _buildCard('👁️ تتبع العين', 'تأمل بصري تفاعلي'),
      ]),
    );
  }
  Widget _buildCard(String title, String desc) {
    return Card(color: AppColors.surface, child: ListTile(
      title: Text(title, style: const TextStyle(color: AppColors.primaryGold)),
      subtitle: Text(desc, style: const TextStyle(color: Colors.white54)),
    ));
  }
}
