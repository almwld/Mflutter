import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// =============================================================================
/// PlanetsScreen - شاشة علم الكواكب
/// =============================================================================

class PlanetsScreen extends StatelessWidget {
  const PlanetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planets = [
      {'name': 'الشمس', 'symbol': '☉', 'element': 'الذهب', 'day': 'الأحد', 'color': 0xFFFFD700},
      {'name': 'القمر', 'symbol': '☽', 'element': 'الفضة', 'day': 'الاثنين', 'color': 0xFFC0C0C0},
      {'name': 'المريخ', 'symbol': '♂', 'element': 'الحديد', 'day': 'الثلاثاء', 'color': 0xFFFF4444},
      {'name': 'عطارد', 'symbol': '☿', 'element': 'النحاس', 'day': 'الأربعاء', 'color': 0xFF8B4513},
      {'name': 'المشتري', 'symbol': '♃', 'element': 'القصدير', 'day': 'الخميس', 'color': 0xFF4169E1},
      {'name': 'الزهرة', 'symbol': '♀', 'element': 'النحاس الأصفر', 'day': 'الجمعة', 'color': 0xFFDA70D6},
      {'name': 'زحل', 'symbol': '♄', 'element': 'الرصاص', 'day': 'السبت', 'color': 0xFF696969},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text(
          'علم الكواكب',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildPlanetsGrid(planets),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildInfluenceSection(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildDaysSection(planets),
        ],
      ),
    );
  }

  Widget _buildPlanetsGrid(List<Map<String, dynamic>> planets) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.paddingSmall,
        crossAxisSpacing: AppDimensions.paddingSmall,
        childAspectRatio: 1.2,
      ),
      itemCount: planets.length,
      itemBuilder: (context, index) {
        final planet = planets[index];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(planet['color'] as int).withOpacity(0.3),
                Color(planet['color'] as int).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: Color(planet['color'] as int).withOpacity(0.5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                planet['symbol'] as String,
                style: TextStyle(
                  fontSize: 40,
                  color: Color(planet['color'] as int),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                planet['name'] as String,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                planet['element'] as String,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfluenceSection() {
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
            'تأثير الكواكب',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildInfluenceItem('الشمس', 'الطاقة والقيادة والكرامة'),
          _buildInfluenceItem('القمر', 'العواطف والخيال والخصوبة'),
          _buildInfluenceItem('المريخ', 'الشجاعة والطاقة والعدوانية'),
          _buildInfluenceItem('عطارد', 'الذكاء والتواصل والتجارة'),
          _buildInfluenceItem('المشتري', 'الحكمة والعدل والسخاء'),
          _buildInfluenceItem('الزهرة', 'الجمال والحب والفن'),
          _buildInfluenceItem('زحل', 'الصبر والانضباط والحكمة'),
        ],
      ),
    );
  }

  Widget _buildInfluenceItem(String planet, String influence) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            planet,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ': $influence',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSection(List<Map<String, dynamic>> planets) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أيام الأسبوع',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: planets.map((planet) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(planet['color'] as int).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(planet['color'] as int).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '${planet['day']} - ${planet['name']}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}