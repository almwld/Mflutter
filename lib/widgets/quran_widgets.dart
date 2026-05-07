import 'package:flutter/material.dart';
import '../services/quran_service.dart';
import '../models/verse.dart';
import '../core/constants/app_colors.dart';

/// =============================================================================
/// SurahListView - قائمة السور
/// =============================================================================

class SurahListView extends StatelessWidget {
  final List<SurahInfo> surahs;
  final Function(int) onSurahTap;
  final int? selectedSurah;

  const SurahListView({
    super.key,
    required this.surahs,
    required this.onSurahTap,
    this.selectedSurah,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        final isSelected = selectedSurah == surah.number;

        return SurahListTile(
          surah: surah,
          isSelected: isSelected,
          onTap: () => onSurahTap(surah.number),
        );
      },
    );
  }
}

/// =============================================================================
/// SurahListTile - عنصر قائمة السورة
/// =============================================================================

class SurahListTile extends StatelessWidget {
  final SurahInfo surah;
  final bool isSelected;
  final VoidCallback onTap;

  const SurahListTile({
    super.key,
    required this.surah,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryGold.withOpacity(0.2)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primaryGold : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // رقم السورة
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.primaryNavy,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primaryNavy
                            : AppColors.primaryGold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // معلومات السورة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.name,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${surah.ayahCount} آية',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // الاسم العربي
                Text(
                  surah.name,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =============================================================================
/// VerseListView - قائمة الآيات
/// =============================================================================

class VerseListView extends StatelessWidget {
  final List<Verse> verses;
  final Function(Verse) onVerseTap;

  const VerseListView({
    super.key,
    required this.verses,
    required this.onVerseTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: verses.length,
      itemBuilder: (context, index) {
        final verse = verses[index];
        return VerseCard(
          verse: verse,
          onTap: () => onVerseTap(verse),
        );
      },
    );
  }
}

/// =============================================================================
/// VerseCard - بطاقة الآية
/// =============================================================================

class VerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback onTap;

  const VerseCard({
    super.key,
    required this.verse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNavy.withOpacity(0.4),
            AppColors.primaryNavy.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        '${verse.surah}:${verse.ayah}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: verse.isMakki
                            ? AppColors.primaryNavy.withOpacity(0.2)
                            : AppColors.primaryGold.withOpacity(0.2),
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
                  ],
                ),
                const SizedBox(height: 12),
                // نص الآية
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    verse.text,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 24,
                      height: 1.8,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                if (verse.translation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      verse.translation,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =============================================================================
/// SurahCard - بطاقة السورة الكبيرة
/// =============================================================================

class SurahCard extends StatelessWidget {
  final SurahInfo surah;
  final VoidCallback onTap;

  const SurahCard({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryNavy, Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  surah.name,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${surah.ayahCount} آية',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}