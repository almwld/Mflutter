import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/abjad_provider.dart';

class AbjadCalculatorScreen extends StatefulWidget {
  const AbjadCalculatorScreen({super.key});
  @override
  State<AbjadCalculatorScreen> createState() => _AbjadCalculatorScreenState();
}

class _AbjadCalculatorScreenState extends State<AbjadCalculatorScreen> {
  final _controller = TextEditingController();

  void _calculate() {
    context.read<AbjadProvider>().calculateAbjad(_controller.text);
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
          TextField(
            controller: _controller,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'أدخل النص لحساب الجمل...',
              prefixIcon: Icon(Icons.calculate_outlined),
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
                      _ResultRow(label: 'الجمل الكبير', value: r.kabir.toString(), color: colors.primary),
                      _ResultRow(label: 'الجمل الصغير', value: r.saghir.toString(), color: colors.onSurface),
                      _ResultRow(label: 'الجمل الوسط', value: r.wasat.toString(), color: colors.onSurface),
                      const SizedBox(height: 8),
                      Text('العنصر: ${r.element} | الكوكب: ${r.planet} | البرج: ${r.zodiac}', textAlign: TextAlign.right, style: TextStyle(color: secondaryText)),
                      Text('الطاقة: ${r.energy.toStringAsFixed(3)}', style: TextStyle(color: secondaryText)),
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
