import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class GazeTrackingScreen extends StatelessWidget {
  const GazeTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('تتبع النظر')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'تتبع النظر غير مفعّل في هذا الإصدار. لم يتم تشغيل محاكاة أو نتائج وهمية.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
      ),
    ),
  );
}
