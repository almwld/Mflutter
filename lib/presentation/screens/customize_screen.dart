import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key});

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  String _selectedTheme = 'default';
  double _fontSize = 18;
  bool _autoNight = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('تخصيص المظهر')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'الثيمات المتاحة',
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
              final selected = _selectedTheme == name;
              return Semantics(
                button: true,
                selected: selected,
                label: 'ثيم $name',
                child: InkWell(
                  onTap: () => setState(() => _selectedTheme = name),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 82,
                    height: 82,
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
                          width: 28,
                          height: 7,
                          decoration: BoxDecoration(
                            color: palette['secondary'],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
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
          const SizedBox(height: 12),
          Text(
            'المحدد للمعاينة: $_selectedTheme',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withOpacity(.65),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'حجم الخط',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: _fontSize,
            min: 14,
            max: 28,
            label: '${_fontSize.toInt()}',
            onChanged: (value) => setState(() => _fontSize = value),
          ),
          Text(
            '${_fontSize.toInt()} px',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(.7),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'الوضع الليلي التلقائي',
            textDirection: TextDirection.rtl,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _autoNight,
            title: const Text('تفعيل تلقائي'),
            subtitle: const Text('إعداد تجريبي؛ لم يُربط بعد بجدولة شروق الشمس وغروبها.'),
            onChanged: (value) => setState(() => _autoNight = value),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'ملاحظة: اختيار الثيم وحجم الخط والوضع التلقائي في هذه الشاشة معاينة محلية حاليًا، ولا تُغيّر ثيم التطبيق بالكامل أو تُحفظ بعد إغلاقه بعد.',
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withOpacity(.7),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
