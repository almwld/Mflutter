import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/theme_provider.dart';
import '../../../services/theme_service.dart';
import '../about_screen.dart';
import '../customize_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _header(context),
          const SizedBox(height: 22),
          _heading(context, 'المظهر', Icons.palette_outlined),
          _group(context, [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
              child: Text('وضع العرض', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            _mode(context, 'حسب إعداد الجهاز', 'يتغير تلقائيًا مع وضع النظام', Icons.settings_suggest_outlined, ThemeMode.system, state.themeMode),
            _mode(context, 'فاتح', 'خلفية فاتحة للقراءة نهارًا', Icons.light_mode_outlined, ThemeMode.light, state.themeMode),
            _mode(context, 'داكن', 'ألوان هادئة في الإضاءة المنخفضة', Icons.dark_mode_outlined, ThemeMode.dark, state.themeMode),
            const SizedBox(height: 8),
          ]),
          const SizedBox(height: 18),
          _group(context, [
            ListTile(leading: Icon(Icons.color_lens_outlined, color: colors.primary), title: const Text('لوحة الألوان'), subtitle: Text(ThemeService.labelFor(state.selectedTheme))),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Wrap(
                spacing: 10, runSpacing: 10,
                children: ThemeService.themeNames.map((name) {
                  final palette = ThemeService.getTheme(name);
                  final active = state.selectedTheme == name;
                  return Tooltip(
                    message: ThemeService.labelFor(name),
                    child: Semantics(
                      button: true, selected: active, label: ThemeService.labelFor(name),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => context.read<ThemeProvider>().setTheme(name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: palette['surface'],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: active ? colors.primary : colors.outlineVariant, width: active ? 3 : 1),
                          ),
                          child: Center(child: Container(
                            width: 25, height: 25,
                            decoration: BoxDecoration(color: palette['secondary'], shape: BoxShape.circle),
                            child: active ? Icon(Icons.check, size: 17, color: palette['primary']) : null,
                          )),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
          const SizedBox(height: 18),
          _heading(context, 'القراءة والخطوط', Icons.menu_book_outlined),
          _group(context, [
            ListTile(
              leading: Icon(Icons.text_fields_rounded, color: colors.primary),
              title: const Text('تخصيص الخط وحجمه'),
              subtitle: Text((state.fontFamily == 'Amiri' ? 'أميري' : 'المسند اليمني') + ' • ' + state.fontSize.round().toString()),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomizeScreen())),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text('يؤثر الخط العام في واجهات التطبيق. يبقى خط المصحف وتخطيط صفحاته مستقلين للحفاظ على مواضع الآيات.', style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.68), height: 1.5)),
            ),
          ]),
          const SizedBox(height: 18),
          _heading(context, 'التطبيق', Icons.info_outline_rounded),
          _group(context, [
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: colors.primary),
              title: const Text('حول مُدَبِّر الأسرار العليا'),
              subtitle: const Text('معلومات التطبيق'),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            ListTile(
              leading: Icon(Icons.restart_alt_rounded, color: colors.primary),
              title: const Text('استعادة إعدادات المظهر الافتراضية'),
              subtitle: const Text('إرجاع الوضع الداكن والثيم والخط إلى القيم الأصلية'),
              onTap: () => _confirmReset(context),
            ),
          ]),
          const SizedBox(height: 14),
          Text('تُحفظ تفضيلات المظهر والخط على هذا الجهاز.', textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.58))),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: colors.outlineVariant.withOpacity(.7))),
      child: Row(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: colors.primary.withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: Icon(Icons.tune_rounded, color: colors.primary, size: 27)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('تجربة مُدَبِّر', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('وحّد ألوان التطبيق واضبط القراءة بما يناسبك.', style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface.withOpacity(.7))),
        ])),
      ]),
    );
  }

  Widget _heading(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      ]),
    );
  }

  Widget _group(BuildContext context, List<Widget> children) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.outlineVariant.withOpacity(.7))),
      child: Column(children: children),
    );
  }

  Widget _mode(BuildContext context, String title, String subtitle, IconData icon, ThemeMode value, ThemeMode selected) {
    final colors = Theme.of(context).colorScheme;
    final active = value == selected;
    return ListTile(
      leading: Icon(icon, color: active ? colors.primary : colors.onSurface.withOpacity(.6)),
      title: Text(title), subtitle: Text(subtitle),
      trailing: active ? Icon(Icons.check_circle_rounded, color: colors.primary) : const Icon(Icons.circle_outlined),
      onTap: () => context.read<ThemeProvider>().setThemeMode(value),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('استعادة الإعدادات الافتراضية؟'),
        content: const Text('سيتم إعادة وضع العرض والثيم والخط وحجم الخط فقط. لن تُحذف بيانات المصحف أو العلامات المرجعية.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('استعادة')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<ThemeProvider>().resetToDefaults();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت استعادة إعدادات المظهر الافتراضية')));
  }
}
