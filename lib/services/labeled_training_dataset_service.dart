import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// Imports an explicitly labelled JSON dataset for the local linear classifier.
/// Quran source text is deliberately not treated as supervised labels.
class LabeledTrainingDatasetService {
  static const int maxFileBytes = 10 * 1024 * 1024;
  static const int maxSamples = 100000;
  static const int minSamples = 6;
  static const Set<String> supportedLabels = <String>{
    'cosmic',
    'tranquil',
    'calculation',
  };

  Future<TrainingDataset?> pickDataset() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['json'],
      withData: false,
    );
    if (result == null) return null;
    final selected = result.files.single;
    final path = selected.path;
    if (path == null || path.isEmpty) {
      throw const FormatException('تعذر الوصول إلى مسار ملف مجموعة البيانات.');
    }
    if (selected.size > maxFileBytes) {
      throw const FormatException('حجم مجموعة البيانات يتجاوز الحد المسموح (10 ميغابايت).');
    }
    final file = File(path);
    if (!await file.exists()) {
      throw const FormatException('ملف مجموعة البيانات غير موجود.');
    }
    final length = await file.length();
    if (length <= 0 || length > maxFileBytes) {
      throw const FormatException('ملف JSON فارغ أو يتجاوز الحد المسموح (10 ميغابايت).');
    }
    final rows = parseJsonDataset(await file.readAsString());
    return TrainingDataset(fileName: selected.name, samples: rows);
  }

  /// Expected format: [{"text":"...","axis_type":"cosmic"}, ...].
  static List<Map<String, dynamic>> parseJsonDataset(String source) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      rethrow;
    }
    if (decoded is! List) {
      throw const FormatException('يجب أن يكون ملف JSON قائمة من العينات.');
    }
    if (decoded.length < minSamples || decoded.length > maxSamples) {
      throw FormatException(
        'عدد العينات يجب أن يكون بين $minSamples و$maxSamples؛ الموجود ${decoded.length}.',
      );
    }

    final rows = <Map<String, dynamic>>[];
    final classCounts = <String, int>{};
    for (var index = 0; index < decoded.length; index++) {
      final row = decoded[index];
      if (row is! Map) {
        throw FormatException('العينة رقم ${index + 1} ليست كائن JSON.');
      }
      final text = row['text'];
      final label = row['axis_type'];
      if (text is! String || text.trim().length < 2 || text.length > 20000) {
        throw FormatException('نص العينة رقم ${index + 1} فارغ أو غير صالح.');
      }
      if (label is! String || !supportedLabels.contains(label)) {
        throw FormatException(
          'تصنيف العينة رقم ${index + 1} غير مدعوم. القيم المسموحة: cosmic, tranquil, calculation.',
        );
      }
      classCounts.update(label, (count) => count + 1, ifAbsent: () => 1);
      rows.add(<String, dynamic>{'text': text.trim(), 'axis_type': label});
    }

    if (classCounts.length < 2) {
      throw const FormatException(
        'لا يمكن تدريب مصنف متعدد الفئات على فئة واحدة فقط؛ أضف عينات من فئتين مختلفتين على الأقل.',
      );
    }
    final underrepresented = classCounts.entries
        .where((entry) => entry.value < 2)
        .map((entry) => entry.key)
        .toList(growable: false);
    if (underrepresented.isNotEmpty) {
      throw FormatException(
        'يجب توفير عينتين على الأقل لكل فئة مستخدمة. الفئات غير الكافية: ${underrepresented.join(', ')}.',
      );
    }
    return List<Map<String, dynamic>>.unmodifiable(rows);
  }
}

class TrainingDataset {
  const TrainingDataset({required this.fileName, required this.samples});

  final String fileName;
  final List<Map<String, dynamic>> samples;

  Map<String, int> get classCounts {
    final counts = <String, int>{};
    for (final sample in samples) {
      final label = sample['axis_type'] as String;
      counts.update(label, (count) => count + 1, ifAbsent: () => 1);
    }
    return Map<String, int>.unmodifiable(counts);
  }
}
