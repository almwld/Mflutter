import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../providers/theme_provider.dart';

class CustomizeScreen extends StatelessWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('تخصيص المظهر')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'ألوان التطبيق',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ThemeService.themeNames.map((name) {
              final palette = ThemeService.getTheme(name);
              final selected = state.selectedTheme == name;
              return Semantics(
                button: true,
                selected: selected,
                label: 'ثيم ${ThemeService.labelFor(name)}',
                child: InkWell(
                  onTap: () => context.read<ThemeProvider>().setTheme(name),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: palette['surface'],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? colors.primary : colors.outlineVariant,
                        width: selected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 7,
                          decoration: BoxDecoration(
                            color: palette['secondary'],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ThemeService.labelFor(name),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: palette['secondary'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle, size: 16, color: palette['secondary']),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Text(
            'خط التطبيق',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Amiri', label: Text('أميري'), icon: Icon(Icons.text_fields)),
              ButtonSegment(value: 'Musnad', label: Text('المسند'), icon: Icon(Icons.auto_awesome)),
            ],
            selected: {state.fontFamily},
            onSelectionChanged: (selection) =>
                context.read<ThemeProvider>().setFont(selection.first),
          ),
          const SizedBox(height: 28),
          Text(
            'حجم الخط العام: ${state.fontSize.round()}',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: state.fontSize,
            min: 14,
            max: 36,
            divisions: 22,
            label: state.fontSize.round().toString(),
            onChanged: context.read<ThemeProvider>().setFontSize,
          ),
          Text(
            'تُحفظ هذه الخيارات على الجهاز وتُطبّق على ثيم التطبيق. إعدادات خط المصحف داخل صفحة القراءة تبقى مستقلة حتى لا يتغيّر تخطيط صفحات المصحف المدني.',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withOpacity(.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
