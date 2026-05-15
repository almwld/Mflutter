import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'customize_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الإعدادات', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildTile(Icons.palette, 'تخصيص المظهر', 'ثيمات، خطوط، ألوان', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomizeScreen()));
          }),
          _buildTile(Icons.translate, 'الترجمة', 'English, Français, اردو', () {}),
          _buildTile(Icons.volume_up, 'القارئ', 'العفاسي', () {}),
          _buildTile(Icons.backup, 'نسخ احتياطي', 'حفظ جميع البيانات', () {}),
          _buildTile(Icons.restore, 'استعادة', 'استعادة من نسخة سابقة', () {}),
          _buildTile(Icons.delete, 'مسح البيانات', 'حذف جميع المحادثات', () {}),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGold),
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white54)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
      onTap: onTap,
    );
  }
}
