import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('⚙️ الإعدادات')),
      body: ListView(
        children: [
          _section('🎨 المظهر'),
          SwitchListTile(
            title: const Text('الوضع الليلي', style: TextStyle(color: Colors.white)),
            subtitle: const Text('ذهبي × كحلي', style: TextStyle(color: Colors.white54)),
            value: theme.isDark,
            activeColor: const Color(0xFFFFD700),
            onChanged: (_) => theme.toggleTheme(),
          ),
          const Divider(color: Colors.white12),

          _section('🔤 الخط'),
          _fontOption(context, theme, 'Amiri', 'أميري — الخط الافتراضي'),
          _fontOption(context, theme, 'Musnad', '𐩱 المسند اليمني'),
          const Divider(color: Colors.white12),

          _section('📏 حجم الخط'),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.remove, color: Color(0xFFFFD700)), onPressed: () => theme.setFontSize(theme.fontSize - 2)),
            Text('${theme.fontSize.toInt()}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 20)),
            IconButton(icon: const Icon(Icons.add, color: Color(0xFFFFD700)), onPressed: () => theme.setFontSize(theme.fontSize + 2)),
          ]),
          const Divider(color: Colors.white12),

          _section('🤖 النظام'),
          _tile('الوكلاء', '127'),
          _tile('الإصدار', '1.0.154'),
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
      trailing: Text(subtitle, style: const TextStyle(color: Color(0xFFFFD700))),
    );
  }

  Widget _fontOption(BuildContext context, ThemeProvider theme, String font, String label) {
    final isActive = theme.fontFamily == font;
    return ListTile(
      leading: Icon(isActive ? Icons.check_circle : Icons.radio_button_unchecked, color: isActive ? const Color(0xFFFFD700) : Colors.white54),
      title: Text(label, style: TextStyle(color: isActive ? const Color(0xFFFFD700) : Colors.white54, fontFamily: font)),
      onTap: () => theme.setFont(font),
    );
  }
}
