import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/training_provider.dart';
import '../../services/quran_loader_service.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🧠 تدريب النموذج', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Consumer<TrainingProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // حالة النموذج
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('📊 حالة النموذج', style: TextStyle(color: AppColors.primaryGold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('النموذج: ${provider.modelLoaded ? "✅ مُحمّل" : "⏳ غير مُحمّل"}',
                          style: const TextStyle(color: Colors.white)),
                      Text('الحالة: ${provider.status}',
                          style: const TextStyle(color: Colors.white70)),
                      if (provider.isTraining) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: provider.progress,
                          backgroundColor: AppColors.surface,
                          color: AppColors.primaryGold,
                        ),
                        Text('${(provider.progress * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.white54)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // أزرار التدريب
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: provider.isTraining
                          ? null
                          : () => _startTraining(context, provider),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('بدء التدريب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.primaryNavy,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: provider.isTraining
                          ? () {} // إيقاف
                          : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('إيقاف'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // سجل التدريب
              if (provider.history.isNotEmpty) ...[
                Card(
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('📈 سجل التدريب', style: TextStyle(color: AppColors.primaryGold, fontSize: 18)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: CustomPaint(
                            painter: LossChartPainter(provider.history),
                            size: const Size(double.infinity, 200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // اختبار سريع
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('🔮 اختبار سريع', style: TextStyle(color: AppColors.primaryGold, fontSize: 18)),
                      const SizedBox(height: 12),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'أدخل آية للاختبار...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (text) {
                          final result = provider.predict(text);
                          _showPredictionDialog(context, result);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _startTraining(BuildContext context, TrainingProvider provider) async {
    // تحميل الآيات
    final ayahs = await QuranLoaderService.loadAllAyahs();
    final versesData = ayahs.map((a) => {
      'text': a.text,
      'axis_type': a.axisType,
    }).toList();

    if (context.mounted) {
      provider.trainOnVerses(versesData, epochs: 50);
    }
  }

  void _showPredictionDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('نتيجة الاستدلال', style: TextStyle(color: AppColors.primaryGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('🏷️ التصنيف: ${result['energy_label']}', style: const TextStyle(color: Colors.white)),
            Text('📊 الثقة: ${(result['confidence'] * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white70)),
            Text('🔢 الجمل: ${result['jummal']?.toInt() ?? 0}', style: const TextStyle(color: Colors.white70)),
            Text('🔮 mod19: ${result['mod19']?.toInt() ?? 0}', style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

/// رسام منحنى الخسارة
class LossChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> history;
  LossChartPainter(this.history);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final losses = history.map((h) => (h['loss'] as num).toDouble()).toList();
    final maxLoss = losses.reduce((a, b) => a > b ? a : b);
    final minLoss = losses.reduce((a, b) => a < b ? a : b);

    final path = Path();
    for (int i = 0; i < losses.length; i++) {
      final x = (i / (losses.length - 1)) * size.width;
      final normalizedY = (losses[i] - minLoss) / (maxLoss - minLoss + 0.001);
      final y = size.height - normalizedY * size.height * 0.8 - 20;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // نقطة البداية والنهاية
    canvas.drawCircle(Offset(0, size.height - 20), 4, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(
      Offset(size.width, size.height - ((losses.last - minLoss) / (maxLoss - minLoss + 0.001)) * size.height * 0.8 - 20),
      4, Paint()..color = Colors.green);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
