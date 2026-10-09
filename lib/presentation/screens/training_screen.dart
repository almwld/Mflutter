import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/training_provider.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('النموذج المحلي والاستدلال',
            style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Consumer<TrainingProvider>(
        builder: (context, provider, _) {
          if (!provider.initialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.initialize();
            });
          }

          final info = provider.modelInfo;
          final inputShape = info['inputShape'];
          final outputShape = info['outputShape'];

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
                      const Text('حالة المحرك المحلي',
                          style: TextStyle(
                              color: AppColors.primaryGold, fontSize: 18)),
                      const SizedBox(height: 10),
                      Text(
                        provider.modelLoaded
                            ? 'النموذج: ${provider.selectedModel}'
                            : 'النموذج: لا يوجد نموذج متوافق محمّل',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 6),
                      Text(provider.status,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.right),
                      if (provider.modelLoaded) ...[
                        const SizedBox(height: 8),
                        Text('شكل المدخل: ${inputShape ?? 'غير متاح'}',
                            style: const TextStyle(color: Colors.white70)),
                        Text('شكل المخرج: ${outputShape ?? 'غير متاح'}',
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        const Text(
                          'تم التحقق من تشغيل TFLite. فهرس المخرج ليس تفسيراً أو تصنيفاً دلالياً ما لم تكن فئات النموذج موثقة.',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                          textAlign: TextAlign.right,
                        ),
                      ],
                      if (provider.error != null) ...[
                        const SizedBox(height: 8),
                        Text(provider.error!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.right),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _importModel(context, provider),
                icon: const Icon(Icons.file_open),
                label: const Text('استيراد نموذج TFLite محلي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'يشترط نموذج float32 بمدخل [1, 4096] ومخرج [1, N] حيث N لا يقل عن 2، ومدرّباً على مستخرج الميزات المستخدم في التطبيق. سيُرفض النموذج غير المتوافق أو الذي يفشل اختبار الاستدلال.',
                style: TextStyle(color: Colors.white60, fontSize: 12),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 18),
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('اختبار استدلال فعلي',
                          style: TextStyle(
                              color: AppColors.primaryGold, fontSize: 18)),
                      const SizedBox(height: 10),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'أدخل نصاً لاختبار النموذج المحلي...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (text) =>
                            _runPrediction(context, provider, text),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                color: AppColors.surface,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('التدريب والتصدير',
                          style: TextStyle(
                              color: AppColors.primaryGold, fontSize: 18)),
                      SizedBox(height: 8),
                      Text(
                        'التدريب الحقيقي غير مفعّل حالياً. مشغّل TFLite المستخدم هنا للاستدلال فقط؛ لن يعرض التطبيق اكتمال تدريب أو تصدير أوزان ما لم تُنفّذ عملية تدريب فعلية وتُحفظ أوزان صالحة.',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.right,
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

  Future<void> _importModel(
      BuildContext context, TrainingProvider provider) async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['tflite'],
        withData: false,
      );
      if (picked == null) return;
      final path = picked.files.single.path;
      if (path == null || path.isEmpty) {
        throw StateError('لم يُرجع منتقي الملفات مساراً قابلاً للقراءة.');
      }
      await provider.importLocalModel(path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحميل النموذج واجتاز اختبار الاستدلال.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم اعتماد النموذج: $e')),
        );
      }
    }
  }

  Future<void> _runPrediction(
    BuildContext context,
    TrainingProvider provider,
    String text,
  ) async {
    if (text.trim().isEmpty) return;
    try {
      final result = await provider.predict(text.trim());
      if (!context.mounted) return;
      final outputs = (result['outputs'] as List)
          .map((v) => (v as num).toStringAsFixed(5))
          .join(', ');
      final confidence = result['confidence'];
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('نتيجة الاستدلال المحلي',
              style: TextStyle(color: AppColors.primaryGold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('النموذج: ${result['model']}',
                  style: const TextStyle(color: Colors.white)),
              Text('فهرس المخرج الأعلى: ${result['predictionIndex']}',
                  style: const TextStyle(color: Colors.white)),
              if (confidence is num)
                Text('الثقة (خرج احتمالي): ${(confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('القيم الخام:',
                  style: TextStyle(color: Colors.white70)),
              SelectableText(outputs,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لم يُنفذ الاستدلال: $e')),
      );
    }
  }
}
