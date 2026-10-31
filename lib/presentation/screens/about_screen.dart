import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final secondaryText = colors.onSurface.withOpacity(.72);

    return Scaffold(
      appBar: AppBar(title: const Text('حول التطبيق')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories_rounded, size: 76, color: colors.primary),
              const SizedBox(height: 22),
              Text(
                'مُدَبِّر الْأَسْرَارِ الْعُلْيَا',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'مساحة محلية للقراءة والتدبر وأدوات المساعدة',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: secondaryText),
              ),
              const SizedBox(height: 28),
              _AboutItem(
                icon: Icons.menu_book_rounded,
                title: 'المصحف والقراءة',
                description:
                    'تصفح النص القرآني المتاح في أصول التطبيق، والبحث في الآيات، وحفظ مواضع القراءة والعلامات.',
              ),
              _AboutItem(
                icon: Icons.psychology_alt_rounded,
                title: 'المساعد المحلي',
                description:
                    'يمكن استخدام نموذج GGUF متوافق بعد استيراده وتحميله. توفر الإجابات يعتمد على النموذج المحمّل وموارده؛ وجود الواجهة وحده لا يعني أن النموذج يعمل.',
              ),
              _AboutItem(
                icon: Icons.insights_rounded,
                title: 'التقدم والذاكرة',
                description:
                    'تعرض الإحصاءات سجل القراءة المحلي والبيانات التي تم تسجيلها بالفعل. قد لا تكون بعض الميزات متاحة قبل تهيئة خدماتها.',
              ),
              _AboutItem(
                icon: Icons.offline_pin_rounded,
                title: 'العمل المحلي والخصوصية',
                description:
                    'تُحفظ بعض التفضيلات والسجلات على الجهاز. لا تفترض أن كل ميزة تعمل دون اتصال أو أن البيانات مشفّرة أو متزامنة سحابيًا؛ راجع وصف كل ميزة وحالتها داخل التطبيق.',
              ),
              const SizedBox(height: 24),
              Text(
                '﴿وَفَوْقَ كُلِّ ذِي عِلْمٍ عَلِيمٌ﴾',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.primary,
                  fontFamily: 'Amiri',
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'هذه الواجهة لا تمثل شهادة بصحة تفسير أو استنتاج ديني؛ ينبغي الرجوع إلى مصادر موثوقة في المسائل الشرعية.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodySmall?.copyWith(color: secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutItem extends StatelessWidget {
  const _AboutItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
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
  }
}
