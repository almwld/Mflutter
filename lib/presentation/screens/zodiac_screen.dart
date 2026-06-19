import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// =============================================================================
/// ZodiacScreen - شاشة علم الأبراج
/// =============================================================================

class ZodiacScreen extends StatelessWidget {
  const ZodiacScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signs = [
      {'name': 'الحمل', 'symbol': '♈', 'element': 'النار', 'quality': 'المتحرك', 'range': '21 مارس - 19 أبريل'},
      {'name': 'الثور', 'symbol': '♉', 'element': 'التراب', 'quality': 'الثابت', 'range': '20 أبريل - 20 مايو'},
      {'name': 'الجوزاء', 'symbol': '♊', 'element': 'الهواء', 'quality': 'المتحرك', 'range': '21 مايو - 20 يونيو'},
      {'name': 'السرطان', 'symbol': '♋', 'element': 'الماء', 'quality': 'الثابت', 'range': '21 يونيو - 22 يوليو'},
      {'name': 'الأسد', 'symbol': '♌', 'element': 'النار', 'quality': 'المتحرك', 'range': '23 يوليو - 22 أغسطس'},
      {'name': 'العذراء', 'symbol': '♍', 'element': 'التراب', 'quality': 'الثابت', 'range': '23 أغسطس - 22 سبتمبر'},
      {'name': 'الميزان', 'symbol': '♎', 'element': 'الهواء', 'quality': 'المتحرك', 'range': '23 سبتمبر - 22 أكتوبر'},
      {'name': 'العقرب', 'symbol': '♏', 'element': 'الماء', 'quality': 'الثابت', 'range': '23 أكتوبر - 21 نوفمبر'},
      {'name': 'القوس', 'symbol': '♐', 'element': 'النار', 'quality': 'المتحرك', 'range': '22 نوفمبر - 21 ديسمبر'},
      {'name': 'الجدي', 'symbol': '♑', 'element': 'التراب', 'quality': 'الثابت', 'range': '22 ديسمبر - 19 يناير'},
      {'name': 'الدلو', 'symbol': '♒', 'element': 'الهواء', 'quality': 'المتحرك', 'range': '20 يناير - 18 فبراير'},
      {'name': 'الحوت', 'symbol': '♓', 'element': 'الماء', 'quality': 'المتحرك', 'range': '19 فبراير - 20 مارس'},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text(
          'علم الأبراج',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildElementsLegend(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildZodiacCircle(signs),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildSignsGrid(signs),
        ],
      ),
    );
  }

  Widget _buildElementsLegend() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('النار', Colors.red),
          _buildLegendItem('التراب', Colors.brown),
          _buildLegendItem('الهواء', Colors.grey),
          _buildLegendItem('الماء', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String element, Color color) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          element,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildZodiacCircle(List<Map<String, dynamic>> signs) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryNavy.withOpacity(0.5),
            AppColors.backgroundDark,
          ],
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(12, (index) {
            final angle = (index * 30 - 90) * 3.14159 / 180;
            final x = 75 * _cos(angle);
            final y = 75 * _sin(angle);
            return Positioned(
              left: 100 + x - 15,
              top: 100 + y - 15,
              child: Text(
                signs[index]['symbol'] as String,
                style: const TextStyle(fontSize: 24),
              ),
            );
          }),
          const Center(
            child: Text(
              'بروج',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _cos(double angle) => _cosApprox(angle);
  double _sin(double angle) => _sinApprox(angle);

  double _cosApprox(double x) {
    x = x % (2 * 3.14159);
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _sinApprox(double x) {
    x = x % (2 * 3.14159);
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  Widget _buildSignsGrid(List<Map<String, dynamic>> signs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.paddingSmall,
        crossAxisSpacing: AppDimensions.paddingSmall,
        childAspectRatio: 1.5,
      ),
      itemCount: signs.length,
      itemBuilder: (context, index) {
        return _buildSignCard(signs[index]);
      },
    );
  }

  Widget _buildSignCard(Map<String, dynamic> sign) {
    final elementColors = {
      'النار': Colors.red,
      'التراب': Colors.brown,
      'الهواء': Colors.grey,
      'الماء': Colors.blue,
    };
    final color = elementColors[sign['element']] ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sign['symbol'] as String,
                  style: TextStyle(fontSize: 20, color: color),
                ),
                const SizedBox(width: 4),
                Text(
                  sign['name'] as String,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sign['range'] as String,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${sign['element']} - ${sign['quality']}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}