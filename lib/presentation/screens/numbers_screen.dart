import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// =============================================================================
/// NumbersScreen - شاشة علم الأعداد
/// =============================================================================

class NumbersScreen extends StatelessWidget {
  const NumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final numbers = [
      {'number': '1', 'name': 'الواحد', 'meaning': 'الوحدانية والبداية', 'element': 'النار'},
      {'number': '2', 'name': 'الاثنان', 'meaning': 'الثنائية والاختيار', 'element': 'الماء'},
      {'number': '3', 'name': 'الثلاثة', 'meaning': 'الثلاثية والتواصل', 'element': 'الهواء'},
      {'number': '4', 'name': 'الأربعة', 'meaning': 'الرباعية والاستقرار', 'element': 'التراب'},
      {'number': '5', 'name': 'الخمسة', 'meaning': 'الخماسية والتوازن', 'element': 'الروح'},
      {'number': '6', 'name': 'الستة', 'meaning': 'الستية والكمال', 'element': 'الماء'},
      {'number': '7', 'name': 'السبعة', 'meaning': 'السبعية والقدسية', 'element': 'النار'},
      {'number': '8', 'name': 'الثمانية', 'meaning': 'الثمانية والوفرة', 'element': 'التراب'},
      {'number': '9', 'name': 'التسعة', 'meaning': 'التسعية والحكمة', 'element': 'الهواء'},
      {'number': '10', 'name': 'العشرة', 'meaning': 'العشرة والكمال', 'element': 'الروح'},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text(
          'علم الأعداد',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildNumbersChart(numbers),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildSignificanceSection(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildSacredNumbersSection(),
        ],
      ),
    );
  }

  Widget _buildNumbersChart(List<Map<String, dynamic>> numbers) {
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
            'معاني الأعداد الأساسية',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              return _buildNumberCard(numbers[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(Map<String, dynamic> number) {
    final elementColors = {
      'النار': Colors.red,
      'الماء': Colors.blue,
      'الهواء': Colors.grey,
      'التراب': Colors.brown,
      'الروح': AppColors.gold,
    };
    final color = elementColors[number['element']] ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.4),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number['number'] as String,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            number['name'] as String,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignificanceSection() {
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
            'دلالة الأعداد',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildSignificanceItem('1-9', 'الأعداد الأساسية', 'تمثل الصفات الأساسية'),
          _buildSignificanceItem('10-99', 'الأعداد المركبة', 'تمثل تجارب الحياة'),
          _buildSignificanceItem('100+', 'الأعداد الكبرى', 'تمثل الحكمة والكمال'),
        ],
      ),
    );
  }

  Widget _buildSignificanceItem(String range, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              range,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSacredNumbersSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.1),
            AppColors.primaryNavy.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الأعداد المقدسة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildSacredNumberItem('7', 'عدد الكمال في الإسلام'),
          _buildSacredNumberItem('12', 'عدد أشهر السنة والأسبوع'),
          _buildSacredNumberItem('19', 'عدد حراس النار'),
          _buildSacredNumberItem('99', 'عدد الأسماء الحسنى'),
          _buildSacredNumberItem('313', 'عدد جيش المهدي'),
        ],
      ),
    );
  }

  Widget _buildSacredNumberItem(String number, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}