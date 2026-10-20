import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SurahBanner extends StatelessWidget {
  final String surahName;
  final bool showBismillah;

  const SurahBanner({
    super.key,
    required this.surahName,
    this.showBismillah = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // البانر الذهبي
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryNavy, AppColors.primaryNavyLight, AppColors.primaryNavy],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: AppColors.gold),
              const SizedBox(width: 16),
              Text(
                'سُورَةُ $surahName',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 40, height: 1, color: AppColors.gold),
            ],
          ),
        ),
        // البسملة
        if (showBismillah) ...[
          const SizedBox(height: 12),
          const Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
