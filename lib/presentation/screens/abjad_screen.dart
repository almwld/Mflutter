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
  final TextEditingController _controller = TextEditingController();

  void _calculate() {
    if (_controller.text.trim().isEmpty) return;
    context.read<AbjadProvider>().calculateAbjad(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('حاسبة الجمل', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: Colors.white, fontSize: 24),
              decoration: InputDecoration(
                hintText: 'اكتب النص العربي هنا...',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: Text('احسب الجمل', style: TextStyle(color: AppColors.primaryNavy, fontSize: 18)),
            ),
            SizedBox(height: 24),
            Consumer<AbjadProvider>(
              builder: (context, provider, child) {
                final r = provider.lastResult;
                if (r == null) return SizedBox();
                return Card(
                  color: AppColors.surface,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text('الجمل الكبير: ${r.kabir}', style: TextStyle(color: AppColors.primaryGold, fontSize: 24)),
                        Text('الجمل الصغير: ${r.saghir}', style: TextStyle(color: Colors.white, fontSize: 18)),
                        Text('الجمل الوسط: ${r.wasat}', style: TextStyle(color: Colors.white70, fontSize: 18)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
