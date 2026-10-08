import 'package:flutter/material.dart';
import 'customize_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile(
            context,
            icon: Icons.palette_outlined,
            title: 'تخصيص المظهر',
            subtitle: 'الثيمات والخطوط والألوان',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomizeScreen()),
              );
            },
          ),
          _buildTile(
            context,
            icon: Icons.translate,
            title: 'الترجمة',
            subtitle: 'خيارات اللغة المتاحة',
            onTap: null,
          ),
          _buildTile(
            context,
            icon: Icons.volume_up_outlined,
            title: 'القارئ',
            subtitle: 'إعدادات التلاوة المتاحة',
            onTap: null,
          ),
          _buildTile(
            context,
            icon: Icons.backup_outlined,
            title: 'النسخ الاحتياطي',
            subtitle: 'إدارة النسخ الاحتياطية',
            onTap: null,
          ),
          _buildTile(
            context,
            icon: Icons.restore_outlined,
            title: 'الاستعادة',
            subtitle: 'استعادة بيانات محفوظة',
            onTap: null,
          ),
          _buildTile(
            context,
            icon: Icons.delete_outline,
            title: 'مسح البيانات',
            subtitle: 'إدارة بيانات التطبيق',
            onTap: null,
          ),
          const SizedBox(height: 12),
          Text(
            'تظهر الخيارات غير المفعّلة للتوضيح فقط؛ لم يتم تنفيذ إجراءاتها بعد.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withOpacity(.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: colors.onSurface.withOpacity(.45),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
