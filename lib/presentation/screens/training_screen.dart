import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../services/labeled_training_dataset_service.dart';
import '../providers/training_provider.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final _datasetService = LabeledTrainingDatasetService();
  TrainingDataset? _dataset;
  bool _loadingDataset = false;
  String? _datasetError;

  Future<void> _pickDataset() async {
    setState(() {
      _loadingDataset = true;
      _datasetError = null;
    });
    try {
      final dataset = await _datasetService.pickDataset();
      if (!mounted || dataset == null) return;
      setState(() => _dataset = dataset);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم التحقق من ${dataset.samples.length} عينة موسومة.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _datasetError = error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر استيراد بيانات التدريب: $error')),
      );
    } finally {
      if (mounted) setState(() => _loadingDataset = false);
    }
  }

  Future<void> _startTraining(TrainingProvider provider) async {
    final dataset = _dataset;
    if (dataset == null || provider.isTraining) return;
    setState(() => _datasetError = null);
    try {
      await provider.trainOnVerses(dataset.samples, epochs: 50);
      if (!mounted) return;
      final status = provider.status;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _datasetError = 'تعذر بدء التدريب المحلي: $error');
    }
  }

  void _showPredictionDialog(BuildContext context, Map<String, dynamic> result) {
    const classLabels = <int, String>{
      0: 'كوني (cosmic)',
      1: 'سكينة (tranquil)',
      2: 'حسابي (calculation)',
    };
    final rawIndex = result['class_index'];
    final classIndex = rawIndex is num ? rawIndex.toInt() : null;
    final rawConfidence = result['confidence'];
    final confidence = rawConfidence is num && rawConfidence.isFinite
        ? rawConfidence.toDouble().clamp(0.0, 1.0).toDouble()
        : null;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('نتيجة الاستدلال', style: TextStyle(color: AppColors.primaryGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              classIndex == null
                  ? 'الفئة: غير معروفة'
                  : 'الفئة: ${classLabels[classIndex] ?? 'فئة غير مدعومة'} (الفهرس $classIndex)',
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              confidence == null
                  ? 'درجة الثقة: غير متاحة'
                  : 'درجة المصنف العددية: ${(confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              result['interpretation']?.toString() ??
                  'مخرج مصنف رقمي محلي؛ لا يحمل دلالة روحية أو تفسيرية مثبتة.',
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تدريب المصنف المحلي', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Consumer<TrainingProvider>(
        builder: (context, provider, _) {
          final dataset = _dataset;
          final classCounts = dataset?.classCounts ?? const <String, int>{};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('حالة المصنف', style: TextStyle(color: AppColors.primaryGold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        provider.isInitializing
                            ? 'جارٍ فحص النموذج المحلي...'
                            : provider.modelLoaded
                                ? 'المصنف المحلي جاهز للاستدلال'
                                : 'لا يوجد مصنف محمّل — استورد بيانات موسومة لبدء التدريب',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text('الحالة: ${provider.status}', style: const TextStyle(color: Colors.white70)),
                      if (provider.modelInitializationError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'تفاصيل فحص النموذج: ${provider.modelInitializationError}',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                        ),
                      ],
                      if (!provider.modelLoaded &&
                          !provider.isTraining &&
                          !provider.isInitializing) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: OutlinedButton.icon(
                            onPressed: provider.retryInitialize,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('إعادة فحص النموذج المحلي'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Text(
                        'هذا تدريب إشرافي لمصنف خطي صغير فقط، وليس تدريبًا لنموذج GGUF أو Qwen. لا تُستخدم آيات القرآن تلقائيًا كبيانات موسومة.',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(color: Colors.white70),
                      ),
                      if (provider.isTraining) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: provider.progress.clamp(0.0, 1.0).toDouble(),
                          backgroundColor: AppColors.background,
                          color: AppColors.primaryGold,
                        ),
                        Text('${(provider.progress * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white54)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('مجموعة البيانات الموسومة', style: TextStyle(color: AppColors.primaryGold, fontSize: 18)),
                      const SizedBox(height: 6),
                      const Text(
                        'يمكن تدريب المصنف الخطي المحلي على العينات الموسومة المستوردة. لا يدرّب هذا الإجراء نموذج GGUF أو Qwen ولا يستخدم نص القرآن تلقائيًا كتصنيفات.',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'استورد ملف JSON يحتوي على قائمة عينات، وكل عينة تتضمن text و axis_type. التصنيفات المقبولة: cosmic و tranquil و calculation. يلزم 6 عينات على الأقل، مع عينتين أو أكثر لكل فئة من الفئات الثلاث كلها: cosmic و tranquil و calculation.',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loadingDataset || provider.isTraining ? null : _pickDataset,
                          icon: _loadingDataset
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.file_open),
                          label: Text(_loadingDataset ? 'جارٍ فحص الملف...' : 'استيراد مجموعة بيانات JSON'),
                        ),
                      ),
                      if (dataset != null) ...[
                        const SizedBox(height: 8),
                        Text('الملف: ${dataset.fileName}', style: const TextStyle(color: Colors.white)),
                        Text('عدد العينات: ${dataset.samples.length}', style: const TextStyle(color: Colors.white70)),
                        for (final label in const <String>[
                          'cosmic',
                          'tranquil',
                          'calculation',
                        ])
                          Text(
                            '$label: ${classCounts[label] ?? 0}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                      ],
                      if (_datasetError != null) ...[
                        const SizedBox(height: 8),
                        Text(_datasetError!, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.redAccent)),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: dataset == null || provider.isTraining
                              ? null
                              : () => _startTraining(provider),
                          icon: provider.isTraining
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.play_arrow),
                          label: Text(provider.isTraining
                              ? 'التدريب جارٍ...'
                              : 'بدء تدريب المصنف المحلي'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.primaryNavy,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: provider.isTraining ? provider.stopTraining : null,
                          icon: const Icon(Icons.stop),
                          label: const Text('إيقاف التدريب'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.history.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('سجل خسارة التدريب', style: TextStyle(color: AppColors.primaryGold, fontSize: 18)),
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
              const SizedBox(height: 12),
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('اختبار المصنف', style: TextStyle(color: AppColors.primaryGold, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text(
                        'تظهر النتيجة كمخرج رقمي للمصنف ولا تعني تفسيرًا للآية أو دلالة روحية.',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        enabled: provider.modelLoaded && !provider.isTraining,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'أدخل نصًا للاختبار...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (text) {
                          try {
                            _showPredictionDialog(context, provider.predict(text));
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تعذر تنفيذ الاستدلال: $error')),
                            );
                          }
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
}

class LossChartPainter extends CustomPainter {
  LossChartPainter(this.history);

  final List<Map<String, dynamic>> history;

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty || size.width <= 0 || size.height <= 0) return;
    final losses = history
        .map((entry) => entry['loss'])
        .whereType<num>()
        .map((value) => value.toDouble())
        .where((value) => value.isFinite)
        .toList(growable: false);
    if (losses.isEmpty) return;

    final maxLoss = losses.reduce((a, b) => a > b ? a : b);
    final minLoss = losses.reduce((a, b) => a < b ? a : b);
    final span = maxLoss - minLoss;
    final path = Path();
    for (var i = 0; i < losses.length; i++) {
      final x = losses.length == 1 ? size.width / 2 : i / (losses.length - 1) * size.width;
      final normalized = span == 0 ? 0.5 : (losses[i] - minLoss) / span;
      final y = size.height - normalized * size.height * 0.8 - 10;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primaryGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final finalNormalized = span == 0 ? 0.5 : (losses.last - minLoss) / span;
    canvas.drawCircle(
      Offset(losses.length == 1 ? size.width / 2 : size.width, size.height - finalNormalized * size.height * 0.8 - 10),
      4,
      Paint()..color = Colors.green,
    );
  }

  @override
  bool shouldRepaint(covariant LossChartPainter oldDelegate) => !identical(oldDelegate.history, history);
}
