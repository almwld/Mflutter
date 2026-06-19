import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// =============================================================================
/// DailyVerseCard - بطاقة الآية اليومية
/// =============================================================================

class DailyVerseCard extends StatelessWidget {
  final String verse;
  final String surah;
  final int verseNumber;
  final VoidCallback? onTap;

  const DailyVerseCard({
    super.key,
    required this.verse,
    required this.surah,
    required this.verseNumber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.marginMedium,
        vertical: AppDimensions.marginSmall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNavy.withOpacity(0.6),
            AppColors.primaryNavy.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildVerse(),
                const SizedBox(height: AppDimensions.paddingMedium),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                size: 14,
                color: AppColors.gold,
              ),
              SizedBox(width: 4),
              Text(
                'آية اليوم',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerse() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text(
        verse,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 22,
          height: 2,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$surah - آية $verseNumber',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}