import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final sections = <(IconData, String, String)>[
      (Icons.menu_book_outlined, 'المحادثة', 'اكتب سؤالًا أو استفسارًا داخل المحادثة.'),
      (Icons.calculate_outlined, 'الجُمّل', 'أدخل نصًا عربيًا لعرض نتائج الحاسبة المتاحة.'),
      (Icons.auto_stories_outlined, 'القرآن', 'تصفح السور والآيات وانتقل إلى موضع الآية.'),
      (Icons.search_outlined, 'البحث', 'استخدم البحث للعثور على الكلمات والآيات.'),
      (Icons.lightbulb_outline, 'التدبر', 'اقرأ الآيات وتأمل معانيها وسياقها.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('المساعدة')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(section.$1, color: colors.primary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          section.$2,
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          section.$3,
                          textDirection: TextDirection.rtl,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withOpacity(.75),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
