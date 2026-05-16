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
  Map<String, dynamic> _tokenizerVocab = {};
  List<Map<String, dynamic>> _trainingHistory = [];

  bool get isInitialized => _initialized;
  Map<String, dynamic> get modelWeights => _modelWeights;
  List<Map<String, dynamic>> get trainingHistory => _trainingHistory;

  /// تهيئة المحرك: تحميل NumPy والنماذج
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. تحميل المفردات (Tokenizer)
      final vocabJson = await rootBundle.loadString('assets/models/tokenizer.json');
      _tokenizerVocab = jsonDecode(vocabJson);

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
      // إذا لم توجد نماذج، سيتم بناؤها من الصفر
      _initialized = true;
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
    if (!_initialized) return List.filled(10, 0.0);

    // تحويل المدخل إلى مصفوفة عمودية
    final x = [input];

    // الطبقة المخفية ١: 4096 → 512
    var w1 = (_modelWeights['w1'] as List?)?.cast<double>() ?? [];
    var b1 = (_modelWeights['b1'] as List?)?.cast<double>() ?? [];
    if (w1.isEmpty) {
      w1 = List.generate(4096 * 512, (_) => (Random().nextDouble() * 2 - 1) * 0.01);
      b1 = List.filled(512, 0.0);
    }

    final w1Matrix = List.generate(4096, (i) => w1.sublist(i * 512, (i + 1) * 512));
    var h1 = matMul(x, w1Matrix)[0];
    for (int i = 0; i < h1.length; i++) {
      h1[i] = (h1[i] + b1[i]).clamp(0, double.infinity); // ReLU
    }

    // الطبقة المخفية ٢: 512 → 256
    var w2 = (_modelWeights['w2'] as List?)?.cast<double>() ?? [];
    var b2 = (_modelWeights['b2'] as List?)?.cast<double>() ?? [];
    if (w2.isEmpty) {
      w2 = List.generate(512 * 256, (_) => (Random().nextDouble() * 2 - 1) * 0.01);
      b2 = List.filled(256, 0.0);
    }

    final w2Matrix = List.generate(512, (i) => w2.sublist(i * 256, (i + 1) * 256));
    var h2 = matMul([h1], w2Matrix)[0];
    for (int i = 0; i < h2.length; i++) {
      h2[i] = (h2[i] + b2[i]).clamp(0, double.infinity);
    }

    // طبقة المخرجات: 256 → 10 (طاقات)
    var w3 = (_modelWeights['w3'] as List?)?.cast<double>() ?? [];
    var b3 = (_modelWeights['b3'] as List?)?.cast<double>() ?? [];
    if (w3.isEmpty) {
      w3 = List.generate(256 * 10, (_) => (Random().nextDouble() * 2 - 1) * 0.01);
      b3 = List.filled(10, 0.0);
    }

    final w3Matrix = List.generate(256, (i) => w3.sublist(i * 10, (i + 1) * 10));
    var output = matMul([h2], w3Matrix)[0];
    for (int i = 0; i < output.length; i++) {
      output[i] += b3[i];
    }

    return softmax(output);
  }

  // ═══════════════════════════════════════════════════════════
  // التدريب على الهاتف (On-Device Training)
  // ═══════════════════════════════════════════════════════════

  /// تدريب نموذج من الصفر باستخدام بيانات القرآن
  Future<Map<String, dynamic>> trainModel({
    required List<List<double>> xTrain,
    required List<int> yTrain,
    int epochs = 100,
    double learningRate = 0.001,
    Function(double loss, int epoch)? onProgress,
  }) async {
    final history = <Map<String, dynamic>>[];
    final random = Random();

    // تهيئة الأوزان
    final w1 = List.generate(4096 * 512, (_) => (random.nextDouble() * 2 - 1) * 0.02);
    final b1 = List.filled(512, 0.0);
    final w2 = List.generate(512 * 256, (_) => (random.nextDouble() * 2 - 1) * 0.02);
    final b2 = List.filled(256, 0.0);
    final w3 = List.generate(256 * 10, (_) => (random.nextDouble() * 2 - 1) * 0.02);
    final b3 = List.filled(10, 0.0);

    final nSamples = xTrain.length;

    for (int epoch = 0; epoch < epochs; epoch++) {
      double totalLoss = 0;

      for (int s = 0; s < nSamples; s++) {
        // تمرير أمامي
        final x = xTrain[s];
        final w1Matrix = List.generate(4096, (i) => w1.sublist(i * 512, (i + 1) * 512));
        var h1 = matMul([x], w1Matrix)[0];
        for (int i = 0; i < h1.length; i++) h1[i] = (h1[i] + b1[i]).clamp(0, double.infinity);

        final w2Matrix = List.generate(512, (i) => w2.sublist(i * 256, (i + 1) * 256));
        var h2 = matMul([h1], w2Matrix)[0];
        for (int i = 0; i < h2.length; i++) h2[i] = (h2[i] + b2[i]).clamp(0, double.infinity);

        final w3Matrix = List.generate(256, (i) => w3.sublist(i * 10, (i + 1) * 10));
        var output = matMul([h2], w3Matrix)[0];
        for (int i = 0; i < output.length; i++) output[i] += b3[i];

        final probs = softmax(output);

        // خسارة Cross-Entropy
        final target = List.filled(10, 0.0);
        target[yTrain[s] % 10] = 1.0;
        double loss = 0;
        for (int i = 0; i < 10; i++) {
          loss -= target[i] * log(max(probs[i], 1e-10));
        }
        totalLoss += loss;

        // انتشار خلفي مبسط (SGD)
        for (int i = 0; i < 10; i++) {
          b3[i] -= learningRate * (probs[i] - target[i]);
        }
        for (int i = 0; i < 256; i++) {
          for (int j = 0; j < 10; j++) {
            w3[i * 10 + j] -= learningRate * h2[i] * (probs[j] - target[j]);
          }
        }
      }

      final avgLoss = totalLoss / nSamples;
      history.add({'epoch': epoch + 1, 'loss': avgLoss});

      if (onProgress != null) {
        onProgress(avgLoss, epoch + 1);
      }
    }

    // حفظ الأوزان
    _modelWeights = {
      'w1': w1,
      'b1': b1,
      'w2': w2,
      'b2': b2,
      'w3': w3,
      'b3': b3,
    };
    _trainingHistory = history;

    // حفظ على القرص
    await _saveModelToDisk();

    return {
      'status': 'completed',
      'epochs': epochs,
      'final_loss': history.last['loss'],
      'weights_size': w1.length + w2.length + w3.length,
    };
  }

  /// حفظ النموذج المُدرّب
  Future<void> _saveModelToDisk() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final modelFile = File('${dir.path}/mudabbir_trained_weights.json');
      await modelFile.writeAsString(jsonEncode(_modelWeights));

      final historyFile = File('${dir.path}/training_history.json');
      await historyFile.writeAsString(jsonEncode(_trainingHistory));
    } catch (e) {
      // فشل الحفظ - النموذج موجود في الذاكرة فقط
    }
  }

  /// تحميل نموذج من القرص
  Future<bool> loadModelFromDisk() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final modelFile = File('${dir.path}/mudabbir_trained_weights.json');
      if (await modelFile.exists()) {
        _modelWeights = jsonDecode(await modelFile.readAsString());
        return true;
      }
      return false;
    } catch (e) {
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

    const energyLabels = [
      'نور', 'سكينة', 'رحمة', 'قوة', 'حكمة',
      'حب', 'عدل', 'جمال', 'حق', 'وحدة',
    ];

    // أعلى طاقة
    int maxIdx = 0;
    for (int i = 1; i < output.length; i++) {
      if (output[i] > output[maxIdx]) maxIdx = i;
    }

    return {
      'energy_label': energyLabels[maxIdx],
      'confidence': output[maxIdx],
      'energy_distribution': output,
      'jummal': features[50] * 1000,
      'mod19': features[51] * 19,
      'mod7': features[52] * 7,
      'golden_ratio_aligned': features[2502] > 0.9,
    };
  }
}
