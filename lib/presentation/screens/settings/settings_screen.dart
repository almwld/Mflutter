import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('⚙️ الإعدادات')),
      body: ListView(
        children: [
          _section('🎨 المظهر'),
          SwitchListTile(
            title: const Text('الوضع الليلي', style: TextStyle(color: Colors.white)),
            subtitle: const Text('ذهبي × كحلي', style: TextStyle(color: Colors.white54)),
            value: themeProvider.themeMode == ThemeMode.dark,
            activeColor: const Color(0xFFFFD700),
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          const Divider(color: Colors.white12),

          _section('📖 القرآن'),
          _tile('نمط العرض', 'عثماني ذهبي'),
          _tile('حجم الخط', '22'),
          _tile('عدد الصفحات', '604'),
          const Divider(color: Colors.white12),

          _section('🤖 النظام'),
          _tile('عدد الوكلاء', '127'),
          _tile('المعرفة', '658 مصطلح'),
          _tile('الآيات', '6236'),
          _tile('حالة التدريب', 'نشط — 127 وكيل'),
          const Divider(color: Colors.white12),

          _section('ℹ️ حول'),
          _tile('مُدَبِّر', 'نظام ذكاء قرآني متكامل'),
          _tile('الإصدار', '1.0.123'),
          _tile('المصدر', 'القرآن الكريم'),
          _tile('GitHub', 'github.com/almwld/Mflutter'),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  Widget _tile(String title, String subtitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Text(subtitle, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
    );
  }
}
