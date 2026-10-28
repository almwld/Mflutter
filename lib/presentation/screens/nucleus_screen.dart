import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// A stable placeholder while the local Tadabbur engine is being completed.
/// This screen intentionally does not start an endless provider-loading state.
class NucleusScreen extends StatelessWidget {
  const NucleusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'نواة التدبر',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.psychology_alt_rounded,
                size: 76,
                color: AppColors.primaryGold,
              ),
              const SizedBox(height: 20),
              const Text(
                'نواة التدبر',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'هذه الوحدة قيد التطوير. ستُتاح عند اكتمال محركها المحلي؛ '
                'لن تبقى الشاشة سوداء أو في حالة تحميل لا تنتهي.',
                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.7),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
