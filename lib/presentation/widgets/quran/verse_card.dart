import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/text_styles.dart';
import '../../../domain/entities/verse.dart';

/// =============================================================================
/// VerseCard - بطاقة الآية
/// =============================================================================

class VerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback? onTap;
  final bool showSurahName;
  final bool isSelected;

  const VerseCard({
    super.key,
    required this.verse,
    this.onTap,
    this.showSurahName = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.marginMedium,
          vertical: AppDimensions.marginSmall,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : AppColors.primaryNavy.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNavy.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // رقم الآية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${verse.surahNumber}:${verse.ayahNumber}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
                if (showSurahName)
                  Text(
                    'سورة ${verse.surahNumber}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            // نص الآية
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                verse.textWithDiacritics,
                style: TextStyles.quranText,
                textAlign: TextAlign.right,
              ),
            ),
            // معلومات إضافية
            const SizedBox(height: AppDimensions.spacingSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: verse.isMakki
                        ? AppColors.primaryNavy.withOpacity(0.1)
                        : AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    verse.isMakki ? 'مكية' : 'مدنية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: verse.isMakki
                          ? AppColors.primaryNavy
                          : AppColors.primaryGoldDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'الجزء ${verse.juzNumber}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// =============================================================================
/// SurahListTile - عنصر قائمة السورة
/// =============================================================================

class SurahListTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback? onTap;

  const SurahListTile({
    super.key,
    required this.surah,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      leading: Container(
        width: AppDimensions.surahNumberSize,
        height: AppDimensions.surahNumberSize,
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${surah.number}',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
            ),
          ),
        ),
      ),
      title: Text(
        surah.name,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryNavy,
        ),
      ),
      subtitle: Text(
        surah.info,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        '${surah.ayahCount} آية',
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
    );
  }
}

/// =============================================================================
/// VerseDetailSheet - ورقة تفاصيل الآية
/// =============================================================================

class VerseDetailSheet extends StatelessWidget {
  final Verse verse;

  const VerseDetailSheet({
    super.key,
    required this.verse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // المقبض
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // رقم الآية
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'سورة ${verse.surahNumber} - آية ${verse.ayahNumber}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // نص الآية
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              verse.textWithDiacritics,
              style: TextStyles.quranTextLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          // معلومات الآية
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip('الجزء ${verse.juzNumber}'),
              const SizedBox(width: 12),
              _buildInfoChip('الصفحة ${verse.pageNumber}'),
              const SizedBox(width: 12),
              _buildInfoChip(verse.isMakki ? 'مكية' : 'مدنية'),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: AppColors.primaryNavy,
        ),
      ),
    );
  }
}