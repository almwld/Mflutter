import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ARLensScreen extends StatelessWidget {
  const ARLensScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('عدسة التدبر AR')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'العدسة المعززة غير مهيأة في الإصدار الحالي. لم يتم عرض نتائج أو علامات وهمية.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
      ),
    ),
  );
}
