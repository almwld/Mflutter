import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/abjad_provider.dart';
import '../../services/achievements_service.dart';

class AbjadCalculatorScreen extends StatefulWidget {
  const AbjadCalculatorScreen({super.key});
  @override
  State<AbjadCalculatorScreen> createState() => _AbjadCalculatorScreenState();
}

class _AbjadCalculatorScreenState extends State<AbjadCalculatorScreen> {
  final _controller = TextEditingController();

  Future<void> _calculate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل نصًا عربيًا لحساب قيم الحروف.')),
      );
      return;
    }
    if (!RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب أن يحتوي النص على حروف عربية.')),
      );
      return;
    }
    final provider = context.read<AbjadProvider>();
    provider.calculateAbjad(text);
    if (provider.lastResult?.letterResults.isEmpty ?? true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم يُعثر على حروف لها قيمة في جدول أبجد؛ لم يُسجّل الحساب.'),
        ),
      );
      return;
    }
    try {
      await AchievementsService.recordAbjadCalculation();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم الحساب، لكن تعذر تحديث سجل الإنجازات المحلي: $error'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final secondaryText = colors.onSurface.withOpacity(.68);

    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة الجمل')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'القيمة الأساسية هنا مجموع قيم الحروف وفق جدول أبجد التقليدي. المتوسط ونصف المجموع عمليتان حسابيتان موضحتان بالاسم. ربط الناتج بعنصر أو كوكب أو برج أو اسم من قائمة هو اصطلاح رمزي لا قياس علمي ولا تنبؤ.',
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodyLarge,
            maxLength: 120,
            decoration: const InputDecoration(
              hintText: 'أدخل النص لحساب الجمل...',
              prefixIcon: Icon(Icons.calculate_outlined),
              helperText: 'تُحسب الحروف المعروفة في جدول أبجد؛ تُتجاهل المسافات والرموز والحروف غير المدرجة.',
            ),
            onSubmitted: (_) => _calculate(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.functions),
            label: const Text('احسب'),
          ),
          const SizedBox(height: 24),
          Consumer<AbjadProvider>(
            builder: (context, provider, _) {
              final r = provider.lastResult;
              if (r == null) return const SizedBox.shrink();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ResultRow(
                        label: 'مجموع أبجد الكبير',
                        value: r.kabir.toString(),
                        color: colors.primary,
                      ),
                      _ResultRow(
                        label: 'متوسط قيم الحروف',
                        value: r.saghir.toString(),
                        color: colors.onSurface,
                      ),
                      _ResultRow(
                        label: 'نصف المجموع',
                        value: r.wasat.toString(),
                        color: colors.onSurface,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          'تفصيل قيمة كل حرف',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 6,
                        runSpacing: 6,
                        children: r.letterResults
                            .map(
                              (letter) => Chip(
                                label: Text('${letter.letter} = ${letter.value}'),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ارتباطات رمزية تقليدية: العنصر ${r.element} • الكوكب ${r.planet} • البرج ${r.zodiac}',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(color: secondaryText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الاسم حسب ترتيب القائمة الشائعة: ${r.divineName}',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(color: secondaryText),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text('$label: $value', textDirection: TextDirection.rtl,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
  );
}
