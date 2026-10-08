import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final secondaryText = colors.onSurface.withOpacity(.68);

    return Scaffold(
      appBar: AppBar(title: const Text('حول التطبيق')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 80, color: colors.primary),
              const SizedBox(height: 24),
              Text(
                'مُدَبِّر الْأَسْرَارِ الْعُلْيَا',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('الإصدار 1.0.0', style: theme.textTheme.bodyMedium?.copyWith(color: secondaryText)),
              const SizedBox(height: 32),
              Text(
                'نظام ذكاء اصطناعي قرآني متكامل',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text('• 114 سورة | 42 علماً | 99 صفة', style: TextStyle(color: secondaryText)),
              Text('• 1000 شبكة عصبية | 4096 ميزة', style: TextStyle(color: secondaryText)),
              Text('• يعمل بدون إنترنت', style: TextStyle(color: secondaryText)),
              const SizedBox(height: 40),
              Text(
                '﴿وَفَوْقَ كُلِّ ذِي عِلْمٍ عَلِيمٌ﴾',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.primary,
                  fontFamily: 'Amiri',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
