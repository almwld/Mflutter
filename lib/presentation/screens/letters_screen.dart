import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// =============================================================================
/// LettersScreen - شاشة علم الحروف
/// =============================================================================

class LettersScreen extends StatelessWidget {
  const LettersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text(
          'علم الحروف',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          _buildAbjadTable(),
          const SizedBox(height: AppDimensions.paddingLarge),
          Expanded(child: _buildLettersGrid()),
        ],
      ),
    );
  }

  Widget _buildAbjadTable() {
    // ترتيب أبجد هوز حطي كلمن سعفص قرشت ثخذ ضظغ وقيمه التقليدية.
    final abjadLetters = [
      ['ا', '1'], ['ب', '2'], ['ج', '3'], ['د', '4'], ['ه', '5'],
      ['و', '6'], ['ز', '7'], ['ح', '8'], ['ط', '9'], ['ي', '10'],
      ['ك', '20'], ['ل', '30'], ['م', '40'], ['ن', '50'], ['س', '60'],
      ['ع', '70'], ['ف', '80'], ['ص', '90'], ['ق', '100'], ['ر', '200'],
      ['ش', '300'], ['ت', '400'], ['ث', '500'], ['خ', '600'], ['ذ', '700'],
      ['ض', '800'], ['ظ', '900'], ['غ', '1000'],
    ];

    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
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
            'جدول الجُمَّل',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'يعرض الجدول نظامًا أبجديًا تاريخيًا للحروف. القيم اصطلاحية ولا تثبت تنبؤات أو خصائص غيبية.',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.2,
            ),
            itemCount: abjadLetters.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      abjadLetters[index][0],
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      abjadLetters[index][1],
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLettersGrid() {
    final letterGroups = [
      {'name': 'الحروف القمرية', 'letters': 'ا، ب، ج، ح، خ، ع، غ، ف، ق، ك، م، هـ، و، ي', 'count': 14},
      {'name': 'الحروف الشمسية', 'letters': 'ت، ث، د، ذ، ر، ز، س، ش، ص، ض، ط، ظ، ل، ن', 'count': 14},
      {'name': 'أمثلة حروف المعاني', 'letters': 'في، على، إلى، عن، من، حتى، ب، ل، ك', 'count': 9},
      {'name': 'حروف القلقلة', 'letters': 'ق، ط، ب، ج، د', 'count': 5},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      itemCount: letterGroups.length,
      itemBuilder: (context, index) {
        final group = letterGroups[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: ExpansionTile(
            title: Text(
              group['name'] as String,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              '${group['count']} حرف',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppColors.gold,
              ),
            ),
            iconColor: AppColors.gold,
            collapsedIconColor: Colors.white70,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Text(
                  group['letters'] as String,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    color: Colors.white70,
                    height: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}