import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class QwenMergeResult {
  final bool merged;
  final String status;
  final String? outputPath;
  final String? error;
  const QwenMergeResult({required this.merged, required this.status, this.outputPath, this.error});
}

class QwenMergeService {
  static final QwenMergeService _instance = QwenMergeService._();
  factory QwenMergeService() => _instance;
  QwenMergeService._();

  bool _merging = false;
  String _status = 'جاهز';
  bool get isMerging => _merging;
  String get status => _status;

  Future<QwenMergeResult> mergeAdapter({
    required String adapterPath,
    String baseModel = 'Qwen/Qwen2.5-0.5B-Instruct',
    String modelName = 'mudabbir-qwen',
    String? outputPath,
  }) async {
    if (_merging) return const QwenMergeResult(merged: false, status: 'عملية دمج أخرى جارية');
    final adapter = Directory(adapterPath);
    if (!await adapter.exists()) {
      return QwenMergeResult(merged: false, status: 'لم يتم العثور على LoRA adapter', error: adapterPath);
    }
    _merging = true;
    _status = 'جاري دمج أوزان LoRA داخل Qwen...';
    try {
      final dir = await getApplicationDocumentsDirectory();
      final output = outputPath ?? (dir.path + '/qwen_merged');
      final script = await _findMergeScript();
      if (script == null) {
        throw StateError('عامل دمج Qwen غير متاح. شغّل tool/merge_qwen_lora.py على جهاز التدريب.');
      }
      final result = await Process.run('python3', [
        script, '--base', baseModel, '--adapter', adapter.path,
        '--output', output, '--ollama', '--model-name', modelName,
      ]);
      if (result.exitCode != 0) throw StateError('فشل دمج Qwen: ' + result.stderr.toString());
      final manifest = File(output + '/mudabbir_merge_manifest.json');
      if (!await manifest.exists()) throw StateError('لم ينشأ manifest للوزن المدموج.');
      _status = 'تم دمج الأوزان وتسجيل ' + modelName + ' في Ollama';
      final response = QwenMergeResult(merged: true, status: _status, outputPath: output);
      await saveMergeState(response);
      return response;
    } catch (e) {
      _status = 'فشل الدمج';
      final response = QwenMergeResult(merged: false, status: _status, error: e.toString());
      await saveMergeState(response);
      return response;
    } finally {
      _merging = false;
    }
  }

  Future<String?> _findMergeScript() async {
    final candidates = <String>[Directory.current.path + '/tool/merge_qwen_lora.py'];
    for (final path in candidates) {
      if (await File(path).exists()) return path;
    }
    return null;
  }

  Future<void> saveMergeState(QwenMergeResult result) async {
    final dir = await getApplicationDocumentsDirectory();
    await File(dir.path + '/qwen_merge_state.json').writeAsString(jsonEncode({
      'merged': result.merged, 'status': result.status, 'outputPath': result.outputPath,
      'error': result.error, 'updatedAt': DateTime.now().toIso8601String(),
    }));
  }
}
