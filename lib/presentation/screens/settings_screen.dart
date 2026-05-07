import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// =============================================================================
/// SettingsScreen - شاشة الإعدادات
/// =============================================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _notifications = true;
  bool _offlineMode = true;
  double _fontSize = 1.0;
  String _language = 'العربية';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildSection(
            'المظهر',
            [
              _buildSwitchTile(
                'الوضع الداكن',
                'تفعيل المظهر الداكن',
                Icons.dark_mode,
                _darkMode,
                (value) => setState(() => _darkMode = value),
              ),
              _buildSliderTile(
                'حجم الخط',
                'ضبط حجم خط القرآن',
                Icons.text_fields,
                _fontSize,
                (value) => setState(() => _fontSize = value),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildSection(
            'الإشعارات',
            [
              _buildSwitchTile(
                'إشعارات يومية',
                'تذكير بالآية اليومية',
                Icons.notifications,
                _notifications,
                (value) => setState(() => _notifications = value),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildSection(
            'اللغة',
            [
              _buildDropdownTile(
                'اللغة',
                'تغيير لغة التطبيق',
                Icons.language,
                _language,
                ['العربية', 'English'],
                (value) => setState(() => _language = value!),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildSection(
            'البيانات',
            [
              _buildSwitchTile(
                'الوضع بدون إنترنت',
                'تحميل البيانات للاستخدام بدون اتصال',
                Icons.cloud_off,
                _offlineMode,
                (value) => setState(() => _offlineMode = value),
              ),
              _buildActionTile(
                'مسح ذاكرة التخزين المؤقت',
                'تحرير مساحة التخزين',
                Icons.delete_sweep,
                () => _showClearCacheDialog(),
              ),
              _buildActionTile(
                'تصدير البيانات',
                'حفظ نسخة من بياناتك',
                Icons.download,
                () => _showExportDialog(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildSection(
            'النماذج',
            [
              _buildInfoTile(
                'مسار النماذج',
                '/storage/emulated/0/Download/mudabbir_models',
                Icons.folder,
              ),
              _buildActionTile(
                'فحص النماذج',
                'التحقق من وجود نماذج صالحة',
                Icons.check_circle,
                () => _checkModels(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildSection(
            'حول',
            [
              _buildInfoTile('الإصدار', '1.0.0', Icons.info),
              _buildInfoTile('المطور', 'Mudabbir Al-Asrar Team', Icons.code),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.gold, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Colors.white54,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.gold,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    Function(double) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.gold, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold,
            inactiveColor: AppColors.primaryNavy,
            min: 0.8,
            max: 1.5,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.gold, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Colors.white54,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: AppColors.primaryNavy,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: Colors.white,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.gold, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Colors.white54,
        ),
      ),
      trailing: const Icon(Icons.chevron_left, color: Colors.white54),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.gold, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Text(
            'مُدَبِّر الْأَسْرَارِ الْعُلْيَا',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'إدارة أسرار العلوم الربانية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '© 2024 - جميع الحقوق محفوظة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'مسح ذاكرة التخزين المؤقت',
          style: TextStyle(
            fontFamily: 'Amiri',
            color: Colors.white,
          ),
        ),
        content: const Text(
          'هل تريد مسح ذاكرة التخزين المؤقت؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح ذاكرة التخزين المؤقت'),
                  backgroundColor: AppColors.primaryNavy,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
            ),
            child: const Text(
              'نعم',
              style: TextStyle(color: AppColors.primaryNavy),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تصدير البيانات...'),
        backgroundColor: AppColors.primaryNavy,
      ),
    );
  }

  void _checkModels() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فحص النماذج...'),
        backgroundColor: AppColors.primaryNavy,
      ),
    );
  }
}