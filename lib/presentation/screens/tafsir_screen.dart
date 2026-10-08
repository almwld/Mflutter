import 'package:flutter/material.dart';

class TafsirScreen extends StatelessWidget {
  final String verseText;
  final String surahName;
  final int ayahNumber;

  const TafsirScreen({
    super.key,
    required this.verseText,
    required this.surahName,
    required this.ayahNumber,
  });

  static const Map<String, String> _tafsirDB = {
    'الفاتحة:1': 'افتتح الله كتابه بالبسملة، وهي آية عظيمة تقال في بداية كل أمر.',
    'البقرة:255': 'آية الكرسي أعظم آية في القرآن. فيها توحيد خالص وإثبات صفات الكمال لله.',
    'الإخلاص:1': 'سورة الإخلاص تعدل ثلث القرآن. تثبت وحدانية الله.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final key = '$surahName:$ayahNumber';
    final tafsir = _tafsirDB[key] ??
        'تفسير هذه الآية غير متوفر في قاعدة البيانات الحالية.';

    return Scaffold(
      appBar: AppBar(title: const Text('التفسير')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                '﴿$verseText﴾',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Amiri',
                  height: 1.9,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'سورة $surahName • الآية $ayahNumber',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                tafsir,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
