import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// محرك Python مُدمج داخل Flutter
/// يستخدم NumPy للتدريب والاستدلال على النماذج
class MudabbirPythonEngine {
  static final MudabbirPythonEngine _instance = MudabbirPythonEngine._();
  factory MudabbirPythonEngine() => _instance;
  MudabbirPythonEngine._();

  bool _initialized = false;
  Map<String, dynamic> _modelWeights = {};
  List<Map<String, dynamic>> _trainingHistory = [];

  bool get isInitialized => _initialized;
  Map<String, dynamic> get modelWeights => _modelWeights;
  List<Map<String, dynamic>> get trainingHistory => _trainingHistory;

  /// تهيئة المحرك: تحميل NumPy والنماذج
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Prefer the user's trained checkpoint over bundled starter weights so
      // training persists across restarts and is not silently overwritten.
      if (await loadModelFromDisk()) return;

      // 1. تحميل المفردات (Tokenizer)
      // 2. تحميل أوزان النموذج المُدرّب مسبقاً
      final weightsJson = await rootBundle.loadString('assets/models/mudabbir_weights.json');
      _modelWeights = jsonDecode(weightsJson);

      // 3. تحميل سجل التدريب
      try {
        final historyJson = await rootBundle.loadString('assets/models/training_history.json');
        _trainingHistory = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      } catch (_) {
        _trainingHistory = [];
      }

      _initialized = true;
    } catch (e) {
      _initialized = false;
      if (await loadModelFromDisk()) return;
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // محاكاة NumPy: عمليات المصفوفات في Dart خالص
  // ═══════════════════════════════════════════════════════════

  /// ضرب مصفوفتين: C = A × B
  List<List<double>> matMul(List<List<double>> A, List<List<double>> B) {
    final rowsA = A.length;
    final colsA = A[0].length;
    final colsB = B[0].length;

    final C = List.generate(rowsA, (_) => List.filled(colsB, 0.0));

    for (int i = 0; i < rowsA; i++) {
      for (int j = 0; j < colsB; j++) {
        double sum = 0;
        for (int k = 0; k < colsA; k++) {
          sum += A[i][k] * B[k][j];
        }
        C[i][j] = sum;
      }
    }
    return C;
  }

  /// تبديل مصفوفة
  List<List<double>> transpose(List<List<double>> matrix) {
    final rows = matrix.length;
    final cols = matrix[0].length;
    final result = List.generate(cols, (_) => List.filled(rows, 0.0));
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result[j][i] = matrix[i][j];
      }
    }
    return result;
  }

  /// ReLU
  List<List<double>> relu(List<List<double>> x) {
    return x.map((row) => row.map((v) => v > 0 ? v : 0.0).toList()).toList();
  }

  /// Softmax
  List<double> softmax(List<double> x) {
    final maxVal = x.reduce(max);
    final expVals = x.map((v) => exp(v - maxVal)).toList();
    final sumExp = expVals.reduce((a, b) => a + b);
    return expVals.map((v) => v / sumExp).toList();
  }

  /// توليد أوزان عشوائية (محاكاة np.random.randn)
  List<List<double>> randomWeights(int rows, int cols, {double scale = 0.02}) {
    final random = Random();
    return List.generate(
      rows,
      (_) => List.generate(cols, (_) => (random.nextDouble() * 2 - 1) * scale),
    );
  }

  /// تهيئة أوزان صفرية
  List<List<double>> zeros(int rows, int cols) {
    return List.generate(rows, (_) => List.filled(cols, 0.0));
  }

  // ═══════════════════════════════════════════════════════════
  // شبكة عصبية بسيطة (مُحاكاة NumPy + Keras)
  // ═══════════════════════════════════════════════════════════

  /// تمرير أمامي كامل: Input → Hidden → Output
  List<double> forward(List<double> input) {
    if (!_initialized) {
      throw StateError('محرك مُدَبِّر غير مهيأ: لم يتم تحميل نموذج صالح.');
    }
    if (input.length != 4096 || input.any((value) => !value.isFinite)) {
      throw ArgumentError('يتطلب النموذج 4096 ميزة رقمية صالحة.');
    }

    if (_modelWeights['architecture'] == 'linear_sparse_v2') {
      final weights = (_modelWeights['weights'] as List)
          .map((value) => (value as num).toDouble())
          .toList(growable: false);
      final biases = (_modelWeights['biases'] as List)
          .map((value) => (value as num).toDouble())
          .toList(growable: false);
      if (weights.length != 4096 * 10 || biases.length != 10) {
        throw StateError('أبعاد أوزان المصنف المحلي غير صالحة.');
      }
      final logits = List<double>.from(biases);
      for (var feature = 0; feature < input.length; feature++) {
        final value = input[feature];
        if (value == 0) continue;
        final offset = feature * 10;
        for (var category = 0; category < 10; category++) {
          logits[category] += value * weights[offset + category];
        }
      }
      return softmax(logits);
    }

    // Backward compatibility for previously exported three-layer weights.
    final x = [input];
    final w1 = (_modelWeights['w1'] as List?)?.map((v) => (v as num).toDouble()).toList() ?? [];
    final b1 = (_modelWeights['b1'] as List?)?.map((v) => (v as num).toDouble()).toList() ?? [];
    if (w1.length != 4096 * 512 || b1.length != 512) {
      throw StateError('أوزان النموذج غير متوافقة؛ أعد التدريب أو استورد نموذجًا صالحًا.');
    }
    final w1Matrix = List.generate(4096, (i) => w1.sublist(i * 512, (i + 1) * 512));
    final h1 = matMul(x, w1Matrix)[0];
    for (int i = 0; i < h1.length; i++) {
      h1[i] = (h1[i] + b1[i]).clamp(0, double.infinity);
    }
    final w2 = (_modelWeights['w2'] as List?)?.map((v) => (v as num).toDouble()).toList() ?? [];
    final b2 = (_modelWeights['b2'] as List?)?.map((v) => (v as num).toDouble()).toList() ?? [];
    if (w2.length != 512 * 256 || b2.length != 256) {
      throw StateError('أوزان الطبقة الثانية غير متوافقة.');
    }
    final w2Matrix = List.generate(512, (i) => w2.sublist(i * 256, (i + 1) * 256));
    final h2 = matMul([h1], w2Matrix)[0];
    for (int i = 0; i < h2.length; i++) {
      h2[i] = (h2[i] + b2[i]).clamp(0, double.infinity);
    }
    final w3 = (_modelWeights['w3'] as List?)?.map((v) => (v as num).toDouble()).toList() ?? [];
    final b3 = (_modelWeights['b3'] as List?)?.map((v) => (v as num).toDouble()).toList() ?? [];
    if (w3.length != 256 * 10 || b3.length != 10) {
      throw StateError('أوزان طبقة المخرجات غير متوافقة.');
    }
    final w3Matrix = List.generate(256, (i) => w3.sublist(i * 10, (i + 1) * 10));
    final output = matMul([h2], w3Matrix)[0];
    for (int i = 0; i < output.length; i++) {
      output[i] += b3[i];
    }
    return softmax(output);
  }

  // ═══════════════════════════════════════════════════════════
  // التدريب المحلي: مصنف softmax صغير مع تحديث جميع الأوزان
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> trainModel({
    required List<List<double>> xTrain,
    required List<int> yTrain,
    int epochs = 100,
    double learningRate = 0.001,
    Function(double loss, int epoch)? onProgress,
    bool Function()? shouldCancel,
  }) async {
    if (xTrain.isEmpty || xTrain.length != yTrain.length) {
      throw ArgumentError('بيانات التدريب فارغة أو عدد التصنيفات لا يطابق العينات.');
    }
    if (epochs < 1 || epochs > 500) {
      throw ArgumentError('عدد العصور يجب أن يكون بين 1 و500.');
    }
    if (!learningRate.isFinite || learningRate <= 0 || learningRate > 1) {
      throw ArgumentError('معدل التعلم يجب أن يكون أكبر من صفر ولا يتجاوز 1.');
    }
    for (var i = 0; i < xTrain.length; i++) {
      if (xTrain[i].length != 4096 || xTrain[i].any((v) => !v.isFinite)) {
        throw ArgumentError('عينة التدريب رقم ${i + 1} لا تحتوي 4096 ميزة رقمية صالحة.');
      }
      if (yTrain[i] < 0 || yTrain[i] >= 10) {
        throw ArgumentError('تصنيف العينة رقم ${i + 1} خارج النطاق 0..9.');
      }
    }

    final random = Random(4096 + xTrain.length + epochs);
    final weights = List<double>.generate(
      4096 * 10,
      (_) => (random.nextDouble() * 2 - 1) * 0.002,
    );
    final biases = List<double>.filled(10, 0);
    final history = <Map<String, dynamic>>[];
    final activeFeatures = <List<int>>[
      for (final sample in xTrain)
        [for (var i = 0; i < sample.length; i++) if (sample[i] != 0) i],
    ];

    for (var epoch = 0; epoch < epochs; epoch++) {
      if (shouldCancel?.call() ?? false) {
        throw StateError('أُلغي التدريب قبل اكتماله؛ لم يُعلن نجاح التدريب.');
      }
      var totalLoss = 0.0;
      for (var sampleIndex = 0; sampleIndex < xTrain.length; sampleIndex++) {
        if (shouldCancel?.call() ?? false) {
          throw StateError('أُلغي التدريب قبل اكتماله؛ لم يُعلن نجاح التدريب.');
        }
        final sample = xTrain[sampleIndex];
        final logits = List<double>.from(biases);
        for (final feature in activeFeatures[sampleIndex]) {
          final value = sample[feature];
          final offset = feature * 10;
          for (var category = 0; category < 10; category++) {
            logits[category] += value * weights[offset + category];
          }
        }
        final probabilities = softmax(logits);
        final target = yTrain[sampleIndex];
        totalLoss -= log(max(probabilities[target], 1e-12));
        for (var category = 0; category < 10; category++) {
          final gradient = probabilities[category] - (category == target ? 1.0 : 0.0);
          biases[category] -= learningRate * gradient;
          for (final feature in activeFeatures[sampleIndex]) {
            final index = feature * 10 + category;
            weights[index] -= learningRate * xTrain[sampleIndex][feature] * gradient;
          }
        }
        // Yield periodically so the UI can repaint and cooperative cancellation
        // can be observed instead of freezing the main isolate for an epoch.
        if (sampleIndex % 16 == 15) {
          await Future<void>.delayed(Duration.zero);
        }
      }
      final averageLoss = totalLoss / xTrain.length;
      if (!averageLoss.isFinite) {
        throw StateError('ظهرت خسارة غير صالحة؛ أُوقف التدريب لحماية النموذج.');
      }
      history.add({'epoch': epoch + 1, 'loss': averageLoss});
      onProgress?.call(averageLoss, epoch + 1);
    }

    final previousWeights = _modelWeights;
    _modelWeights = {
      'schema_version': 2,
      'architecture': 'linear_sparse_v2',
      'input_size': 4096,
      'class_count': 10,
      'weights': weights,
      'biases': biases,
    };
    _trainingHistory = history;
    _initialized = true;
    try {
      await _saveModelToDisk();
    } catch (_) {
      _modelWeights = previousWeights;
      _initialized = previousWeights.isNotEmpty;
      rethrow;
    }
    return {
      'status': 'completed',
      'architecture': 'linear_sparse_v2',
      'epochs': epochs,
      'samples': xTrain.length,
      'final_loss': history.last['loss'],
      'weights_size': weights.length + biases.length,
    };
  }

  Future<void> _saveModelToDisk() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelFile = File('${dir.path}/mudabbir_trained_weights.json');
    final historyFile = File('${dir.path}/training_history.json');
    final modelTemp = File('${modelFile.path}.tmp');
    final historyTemp = File('${historyFile.path}.tmp');
    await modelTemp.writeAsString(jsonEncode(_modelWeights), flush: true);
    await historyTemp.writeAsString(jsonEncode(_trainingHistory), flush: true);
    await modelTemp.rename(modelFile.path);
    await historyTemp.rename(historyFile.path);
  }

  Future<bool> loadModelFromDisk() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final modelFile = File('${dir.path}/mudabbir_trained_weights.json');
      final historyFile = File('${dir.path}/training_history.json');
      if (!await modelFile.exists()) return false;
      final decoded = jsonDecode(await modelFile.readAsString());
      if (decoded is! Map) return false;
      final candidate = Map<String, dynamic>.from(decoded);
      if (candidate['architecture'] == 'linear_sparse_v2') {
        final weights = candidate['weights'];
        final biases = candidate['biases'];
        if (weights is! List || weights.length != 4096 * 10 ||
            biases is! List || biases.length != 10 ||
            weights.any((v) => v is! num || !v.isFinite) ||
            biases.any((v) => v is! num || !v.isFinite)) {
          return false;
        }
      } else {
        final w1 = candidate['w1'];
        final b1 = candidate['b1'];
        final w2 = candidate['w2'];
        final b2 = candidate['b2'];
        final w3 = candidate['w3'];
        final b3 = candidate['b3'];
        if (w1 is! List || w1.length != 4096 * 512 ||
            b1 is! List || b1.length != 512 ||
            w2 is! List || w2.length != 512 * 256 ||
            b2 is! List || b2.length != 256 ||
            w3 is! List || w3.length != 256 * 10 ||
            b3 is! List || b3.length != 10) {
          return false;
        }
      }
      _modelWeights = candidate;
      if (await historyFile.exists()) {
        final history = jsonDecode(await historyFile.readAsString());
        if (history is List) {
          _trainingHistory = history
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList();
        }
      }
      _initialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // استخراج الميزات (4096 بُعد) من النص
  // ═══════════════════════════════════════════════════════════

  List<double> extractFeatures(String text) {
    final features = List.filled(4096, 0.0);
    final words = text.split(' ');

    // [1-50] أساسية
    features[0] = text.length.toDouble() / 500.0;
    features[1] = words.length.toDouble() / 50.0;
    features[2] = text.runes.length.toDouble() / 300.0;

    // [51-100] الجمل
    int jummal = 0;
    for (final char in text.runes) {
      jummal += char % 1000;
    }
    features[50] = (jummal % 1000).toDouble() / 1000.0;
    features[51] = (jummal % 19).toDouble() / 19.0;
    features[52] = (jummal % 7).toDouble() / 7.0;

    // [101-200] مثلثية
    features[100] = sin(jummal * 0.001);
    features[101] = cos(jummal * 0.001);
    features[102] = sin(jummal * 0.01) * cos(jummal * 0.001);

    // [201-600] علوم 42
    final scienceKeywords = [
      'فلك', 'سماء', 'نجم', 'أرض', 'جبل', 'بحر', 'نور', 'ظلمة',
      'خلق', 'نطفة', 'جنين', 'ماء', 'رياح', 'سحاب', 'مطر',
      'شمس', 'قمر', 'كوكب', 'رزق', 'شفاء', 'مرض', 'قلب', 'روح',
      'علم', 'حكمة', 'عدد', 'حساب', 'زمن', 'وقت', 'حركة', 'سكون',
    ];
    for (int i = 0; i < scienceKeywords.length && i < 42; i++) {
      features[200 + i * 10] = text.contains(scienceKeywords[i]) ? 1.0 : 0.0;
    }

    // [2501-4096] روحانية
    features[2500] = (jummal % 19 == 0) ? 1.0 : 0.0;
    features[2501] = (jummal % 7 == 0) ? 1.0 : 0.0;
    features[2502] = sin(jummal * 0.001 * 1.61803398875); // النسبة الذهبية

    // الطاقة الإجمالية
    features[4095] = features.sublist(0, 4095).reduce((a, b) => a + b.abs()) / 4095.0;

    return features;
  }

  // ═══════════════════════════════════════════════════════════
  // الاستدلال: توقع الطاقة والموضوع
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic> predict(String text) {
    final features = extractFeatures(text);
    final output = forward(features);

    var maxIdx = 0;
    for (var i = 1; i < output.length; i++) {
      if (output[i] > output[maxIdx]) maxIdx = i;
    }

    return {
      'class_index': maxIdx,
      'confidence': output[maxIdx],
      'class_probabilities': output,
      'interpretation':
          'مخرج مصنف رقمي محلي فقط؛ فهرس الفئة ليس اسم طاقة أو معنى روحيًا أو تفسيرًا للقرآن.',
    };
  }
}
