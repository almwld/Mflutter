import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/verse.dart';

/// =============================================================================
/// SurahCard - بطاقة السورة
/// =============================================================================

class SurahCard extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const SurahCard({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNavy.withOpacity(0.4),
            AppColors.primaryNavy.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                _buildNumberCircle(),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(child: _buildSurahInfo()),
                _buildArabicName(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCircle() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Center(
        child: Text(
          surah.number.toString(),
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          surah.nameArabic,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          surah.meaning,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildInfoChip('${surah.versesCount} آية'),
            const SizedBox(width: 8),
            if (surah.revelationType.isNotEmpty)
              _buildInfoChip(
                surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildArabicName() {
    return Text(
      surah.nameArabic,
      style: const TextStyle(
        fontFamily: 'Amiri',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
      ),
    );
  }
}