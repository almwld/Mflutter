import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حاسبة الجمل', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'أدخل النص لحساب الجمل...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
              child: const Text('احسب', style: TextStyle(color: AppColors.primaryNavy)),
            ),
            const SizedBox(height: 24),
            Consumer<AbjadProvider>(
              builder: (context, provider, _) {
                final r = provider.lastResult;
                if (r == null) return const SizedBox();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('الجمل الكبير: ${r.kabir}', style: const TextStyle(color: AppColors.primaryGold, fontSize: 24)),
                    Text('الجمل الصغير: ${r.saghir}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                    Text('الجمل الوسط: ${r.wasat}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('العنصر: ${r.element} | الكوكب: ${r.planet} | البرج: ${r.zodiac}', style: const TextStyle(color: Colors.white54)),
                    Text('الطاقة: ${r.energy.toStringAsFixed(3)}', style: const TextStyle(color: Colors.white54)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
