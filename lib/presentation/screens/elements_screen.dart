import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// =============================================================================
/// ElementsScreen - شاشة علم العناصر
/// =============================================================================

class ElementsScreen extends StatelessWidget {
  const ElementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text(
          'العناصر في التصورات التراثية',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildSymbolicDisclaimer(context),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildElementCard(
            'النار',
            'العنصر الأول',
            'الصفات التراثية المنسوبة: الحرارة واليبوس',
            Colors.red,
            Icons.local_fire_department,
          ),
          _buildElementCard(
            'الماء',
            'العنصر الثاني',
            'الصفات التراثية المنسوبة: الرطوبة والبرودة',
            AppColors.primaryNavyLight,
            Icons.water_drop,
          ),
          _buildElementCard(
            'التراب',
            'العنصر الثالث',
            'الصفات التراثية المنسوبة: اليبوسة والبرودة',
            Colors.brown,
            Icons.landscape,
          ),
          _buildElementCard(
            'الهواء',
            'العنصر الرابع',
            'الصفات التراثية المنسوبة: الحرارة والرطوبة',
            Colors.grey,
            Icons.air,
          ),
          _buildElementCard(
            'الروح',
            'تصنيف إضافي في بعض الموروثات',
            'مفهوم رمزي/فلسفي؛ ليس عنصرًا علميًا ضمن العناصر الأربعة',
            AppColors.gold,
            Icons.auto_awesome,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildRelationsSection(),
        ],
      ),
    );
  }

  Widget _buildSymbolicDisclaimer(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        'المعاني المعروضة تمثل تصنيفات رمزية أو تاريخية. لا تثبت هذه الجداول خصائص علمية للعناصر أو الأعداد ولا تتنبأ بأحداث أو صفات الأشخاص.',
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: colors.onSurface.withOpacity(.72),
          height: 1.5,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildElementCard(
    String name,
    String subtitle,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationsSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'روابط تصورية في بعض الموروثات',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          const Text(
            'تختلف هذه العلاقات باختلاف النظام التراثي، وهي ليست نموذجًا علميًا حديثًا.',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildRelationRow('النار', 'تجفف', 'الماء'),
          _buildRelationRow('الماء', 'يُطفئ', 'النار'),
          _buildRelationRow('التراب', 'يُحيط', 'الماء'),
          _buildRelationRow('الهواء', 'يُحيط', 'النار'),
          _buildRelationRow('الروح', 'يُرمز بها إلى', 'الحياة'),
        ],
      ),
    );
  }

  Widget _buildRelationRow(String from, String action, String to) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            from,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            action,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            to,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}