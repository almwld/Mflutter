import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'agent_knowledge_service.dart';
import 'agent_registry.dart';
import 'local_gguf_runtime_service.dart';

/// Shared local-first core for Mudabbir.
///
/// The nucleus owns application-level readiness and context. The GGUF runtime
/// remains the sole owner of native model lifecycle, so UI state cannot claim
/// inference is available before llama.cpp has loaded a model successfully.
class NucleusService extends ChangeNotifier {
  static final NucleusService _instance = NucleusService._internal();
  factory NucleusService() => _instance;

  NucleusService._internal() {
    _runtime.addListener(_onRuntimeChanged);
  }

  static const String bundledAsset = 'assets/nucleus.json';

  final LocalGgufRuntimeService _runtime = LocalGgufRuntimeService.instance;
  final AgentKnowledgeService _knowledge = AgentKnowledgeService.instance;

  Map<String, dynamic>? _nucleusData;
  Future<void>? _initializing;
  bool _initialized = false;
  bool _isInitializing = false;
  bool _knowledgeReady = false;
  String _source = 'لم تُحمّل بيانات النواة بعد';
  String? _error;
  int? _surahNumber;
  int? _ayahNumber;
  String? _verseText;
  double _visualEnergy = 0;

  bool get isInitialized => _initialized;
  bool get isInitializing => _isInitializing;
  bool get knowledgeReady => _knowledgeReady;
  String get source => _source;
  String? get error => _error;
  bool get isModelLoaded => _runtime.isLoaded;
  bool get isModelBusy => _runtime.isBusy;
  bool get isGenerating => _runtime.isGenerating;
  String get modelStatus => _runtime.status;
  String? get loadedModelPath => _runtime.loadedPath;
  int get registeredAgentCount => AgentRegistry.all.length;
  int get uniqueAgentCount => AgentRegistry.all.map((agent) => agent.id).toSet().length;
  int get indexedDocumentCount => _knowledge.documentCount;
  List<String> get loadedKnowledgeSources => _knowledge.loadedSources;
  int? get currentSurahNumber => _surahNumber;
  int? get currentAyahNumber => _ayahNumber;
  String? get currentVerseText => _verseText;

  /// This is a UI-derived scalar only; it is not a biological or spiritual
  /// measurement. No sensor or "frequency" is inferred without real input.
  double get visualEnergy => _visualEnergy;

  Map<String, dynamic> getNucleusData() =>
      Map<String, dynamic>.unmodifiable(_nucleusData ?? _defaultNucleus);

  T? getValue<T>(String key) {
    final value = (_nucleusData ?? _defaultNucleus)[key];
    return value is T ? value : null;
  }

  Map<String, dynamic> getModelSettings() =>
      _asStringMap((_nucleusData ?? _defaultNucleus)['models']);

  Map<String, dynamic> getUISettings() =>
      _asStringMap((_nucleusData ?? _defaultNucleus)['ui']);

  List<Map<String, dynamic>> getSciences() {
    final value = (_nucleusData ?? _defaultNucleus)['sciences'];
    if (value is! List) return const [];
    return value.whereType<Map>().map(_asStringMap).toList(growable: false);
  }

  List<String> getDivineNames() {
    final value = (_nucleusData ?? _defaultNucleus)['divine_names'];
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  Map<String, int> getColors() {
    final colors = _asStringMap((_nucleusData ?? _defaultNucleus)['colors']);
    return colors.map((key, value) => MapEntry(
          key,
          value is int ? value : int.tryParse(value.toString()) ?? 0,
        ));
  }

  Future<void> initialize() async {
    if (_initialized) return;
    final pending = _initializing;
    if (pending != null) {
      await pending;
      return;
    }

    final attempt = _initializeOnce();
    _initializing = attempt;
    try {
      await attempt;
    } catch (_) {
      _initializing = null;
      rethrow;
    }
  }

  Future<void> _initializeOnce() async {
    _isInitializing = true;
    _error = null;
    notifyListeners();
    try {
      final raw = await rootBundle.loadString(bundledAsset);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const FormatException('يجب أن تكون بيانات النواة كائن JSON.');
      }
      final data = _asStringMap(decoded);
      final version = data['schema_version'];
      if (version is! int || version < 1) {
        throw const FormatException('إصدار مخطط النواة غير صالح.');
      }
      _nucleusData = data;
      _source = bundledAsset;
    } catch (error) {
      _nucleusData = _defaultNucleus;
      _source = 'البيانات الافتراضية المضمّنة';
      _error = 'تعذر تحميل $bundledAsset: $error';
    }

    // Knowledge is local and optional for boot readiness. A knowledge-index
    // error is reported separately and never represented as a successful load.
    try {
      await _knowledge.initialize();
      _knowledgeReady = true;
    } catch (error) {
      _knowledgeReady = false;
      _error = _error == null
          ? 'تعذر تجهيز فهرس المعرفة المحلي: $error'
          : '$_error\nتعذر تجهيز فهرس المعرفة المحلي: $error';
    }

    _initialized = true;
    _isInitializing = false;
    _initializing = null;
    notifyListeners();
  }

  /// Optional compatibility loader for a user-supplied nucleus JSON.
  /// The bundled, versioned asset remains the default source.
  Future<bool> loadNucleusFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      _error = 'ملف النواة غير موجود: $path';
      notifyListeners();
      return false;
    }
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) throw const FormatException('ملف النواة ليس كائن JSON.');
      final data = _asStringMap(decoded);
      if (data['schema_version'] is! int) {
        throw const FormatException('ملف النواة لا يحتوي schema_version صحيحًا.');
      }
      _nucleusData = data;
      _source = file.path;
      _error = null;
      _initialized = true;
      notifyListeners();
      return true;
    } catch (error) {
      _error = 'فشل التحقق من ملف النواة: $error';
      notifyListeners();
      return false;
    }
  }

  void setQuranContext({
    required int surahNumber,
    required int ayahNumber,
    String? verseText,
  }) {
    if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
      throw ArgumentError('مرجع السورة أو الآية خارج الحدود.');
    }
    _surahNumber = surahNumber;
    _ayahNumber = ayahNumber;
    _verseText = verseText;
    notifyListeners();
  }

  void clearQuranContext() {
    _surahNumber = null;
    _ayahNumber = null;
    _verseText = null;
    notifyListeners();
  }

  void setVisualEnergy(double value) {
    if (!value.isFinite) throw ArgumentError.value(value, 'value');
    _visualEnergy = value.clamp(0.0, 1.0).toDouble();
    notifyListeners();
  }

  Future<File> importModel(String sourcePath) =>
      _runtime.importModel(sourcePath);

  Future<void> loadModel({int threads = 4, int contextSize = 1024}) =>
      _runtime.loadModel(threads: threads, contextSize: contextSize);

  Future<File> importAndLoadModel(
    String sourcePath, {
    int threads = 4,
    int contextSize = 1024,
  }) async {
    await _runtime.importModel(sourcePath);
    await _runtime.loadModel(threads: threads, contextSize: contextSize);
    return File(_runtime.loadedPath!);
  }

  Future<String> generateGroundedAnswer({
    required String question,
    required String evidence,
    int maxTokens = 512,
  }) =>
      _runtime.generateGroundedAnswer(
        question: question,
        evidence: evidence,
        maxTokens: maxTokens,
      );

  void _onRuntimeChanged() => notifyListeners();

  static Map<String, dynamic> _asStringMap(dynamic value) {
    if (value is! Map) return <String, dynamic>{};
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static final Map<String, dynamic> _defaultNucleus = <String, dynamic>{
    'schema_version': 1,
    'name': 'Mudabbir Visual Core',
    'models': <String, dynamic>{
      'local_gguf': <String, dynamic>{'enabled': true, 'runtime': 'llama.cpp'},
    },
    'ui': <String, dynamic>{'theme': 'dark', 'language': 'ar', 'fontScale': 1.0},
    'sciences': const <Map<String, dynamic>>[],
    'divine_names': const <String>[],
    'colors': <String, int>{
      'primary': 0xFF1A237E,
      'gold': 0xFFFFD700,
      'surface': 0xFF0D1B2A,
      'onSurface': 0xFFE0E1DD,
    },
  };
}
