import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/theme_service.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});
  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  String _selectedTheme = 'default';
  double _fontSize = 18.0;
  bool _autoNight = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('تخصيص', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text('🎨 الثيمات', style: TextStyle(color: AppColors.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: ThemeService.themeNames.map((name) {
              final theme = ThemeService.getTheme(name);
              return GestureDetector(
                onTap: () => setState(() => _selectedTheme = name),
                child: Container(
                  width: 70,
                  height: 70,
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedTheme == name ? AppColors.primaryGold : Colors.transparent,
                      width: 3,
                    ),
                    gradient: LinearGradient(
                      colors: [theme['primary']!, theme['secondary']!],
                    ),
                  ),
                  child: Center(
                    child: Text(name, style: TextStyle(color: Colors.white, fontSize: 9)),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32),
          Text('📝 حجم الخط', style: TextStyle(color: AppColors.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
          Slider(
            value: _fontSize,
            min: 14,
            max: 28,
            activeColor: AppColors.primaryGold,
            onChanged: (v) => setState(() => _fontSize = v),
          ),
          Text('${_fontSize.toInt()} px', style: TextStyle(color: Colors.white54)),
          SizedBox(height: 32),
          Text('🌙 الوضع الليلي التلقائي', style: TextStyle(color: AppColors.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
          SwitchListTile(
            value: _autoNight,
            activeColor: AppColors.primaryGold,
            title: Text('تفعيل تلقائي', style: TextStyle(color: Colors.white)),
            subtitle: Text('يتغير مع غروب الشمس', style: TextStyle(color: Colors.white54)),
            onChanged: (v) => setState(() => _autoNight = v),
          ),
        ],
      ),
    );
  }
}
