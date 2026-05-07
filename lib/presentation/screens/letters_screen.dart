import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../providers/abjad_provider.dart';
import 'package:provider/provider.dart';

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
    final abjadLetters = [
      ['أ', '1'], ['ب', '2'], ['ت', '3'], ['ث', '4'], ['ج', '5'],
      ['ح', '6'], ['خ', '7'], ['د', '8'], ['ذ', '9'], ['ر', '10'],
      ['ز', '11'], ['س', '12'], ['ش', '13'], ['ص', '14'], ['ض', '15'],
      ['ط', '16'], ['ظ', '17'], ['ع', '18'], ['غ', '19'], ['ف', '20'],
      ['ق', '21'], ['ك', '22'], ['ل', '23'], ['م', '24'], ['ن', '25'],
      ['هـ', '26'], ['و', '27'], ['ي', '28'],
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
      {'name': 'الحروف القمرية', 'letters': 'أ، ب، ت، ث، ج، ح، خ، د، ذ، ر، ز، س، ش، ص، ض، ط، ظ، ع، غ، ف، ق، ك، ل، م، ن، هـ، و، ي', 'count': 14},
      {'name': 'الحروف الشمسية', 'letters': 'ت، ث، ج، ح، خ، د، ذ، ر، ز، س، ش، ص، ض، ط، ظ', 'count': 14},
      {'name': 'حروف المعاني', 'letters': 'في، على، إلى، عن، من، إلى، حتى، ب، ل، ك', 'count': 10},
      {'name': 'حروف القلقلة', 'letters': 'ص، ض، ط، ظ، ق، ب، ت، ج', 'count': 8},
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