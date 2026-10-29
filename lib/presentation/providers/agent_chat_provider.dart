import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/agent_task.dart';
import '../../domain/entities/agent_ui_intent.dart';
import '../../services/agent_knowledge_service.dart';
import '../../services/agent_ui_coordinator.dart';
import '../../services/nucleus_service.dart';
import '../../services/agent_memory_service.dart';
import '../../services/agent_task_store.dart';
import '../../services/agent_registry.dart';
import '../../services/achievements_service.dart';
import '../../utils/abjad_constants.dart';
import '../../services/quran_loader_service.dart';
import '../../services/quranic_search_engine.dart';

/// Zion-style multi-agent runtime for مُدَبِّر.
/// Agents execute local tools and cite bundled sources; no remote model or
/// simulated shell execution is presented as real inference.
class AgentChatProvider extends ChangeNotifier {
  final AgentKnowledgeService _knowledge = AgentKnowledgeService.instance;
  final AgentMemoryService _memory = AgentMemoryService.instance;
  final AgentTaskStore _taskStore = AgentTaskStore.instance;

  AgentTask? _activeTask;
  final AgentUiCoordinator _uiCoordinator = const AgentUiCoordinator();
  AgentUiIntent? _pendingUiIntent;
  final List<String> _messages = [];
  final Map<String, int> _attemptsByAgent = {};
  bool _paused = false;
  bool _cancelled = false;
  int _executionGeneration = 0;
  bool _initialized = false;
  String? _initializationError;
  String? _selectedAgent;
  String? _selectionError;
  String? _activeTaskVerseSource;

  bool _disposed = false;

  void _notifySafely() {
    if (!_disposed) notifyListeners();
  }

  void _setActiveTask(AgentTask task) {
    _activeTask = task;
    unawaited(_taskStore.save(task).catchError((Object error) {
      debugPrint('AgentChatProvider: task checkpoint save failed: $error');
    }));
  }

  Future<void> _restoreLatestTask() async {
    if (_activeTask != null) return;
    final restored = await _taskStore.loadLatest();
    if (restored == null) return;
    _activeTask = restored;
    if (restored.status == TaskStatus.paused) {
      _messages.add('استُعيدت مهمة محلية غير مكتملة. يمكنك استئنافها من نقطة التوقف؛ الخطوة التي كانت تعمل ستُعاد بأمان.');
      unawaited(_taskStore.save(restored).catchError((Object error) {
        debugPrint('AgentChatProvider: recovered checkpoint save failed: $error');
      }));
    } else if (restored.status == TaskStatus.completed && restored.finalAnswer != null) {
      _messages.add('مُدَبِّر: ${restored.finalAnswer}');
    } else if (restored.status == TaskStatus.failed) {
      _messages.add('استُعيد سجل مهمة سابقة فشلت: ${restored.error ?? 'سبب غير مسجل'}.');
    }
    _notifySafely();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelled = true;
    _paused = false;
    _executionGeneration++;
    unawaited(NucleusService().stopGeneration().catchError((_) {}));
    super.dispose();
  }

  AgentTask? get activeTask => _activeTask;
  AgentUiIntent? get pendingUiIntent => _pendingUiIntent;

  /// Consume a UI action exactly once so provider rebuilds cannot navigate twice.
  void consumeUiIntent(String id) {
    if (_pendingUiIntent?.id != id) return;
    _pendingUiIntent = null;
    _notifySafely();
  }

  /// Publishes a presentation schema built from trusted domain-service results.
  /// This is the hand-off point for Quran, astronomy, abjad, and nucleus services.
  /// It intentionally accepts prepared values and performs no data fabrication.
  bool presentSchemaPayload({
    required String templateId,
    required String title,
    required String domain,
    required List<Map<String, dynamic>> blocks,
    required String source,
    String? originalQuery,
  }) {
    final intent = _uiCoordinator.resolveSchemaPayload(
      templateId: templateId,
      title: title,
      domain: domain,
      blocks: blocks,
      source: source,
      originalQuery: originalQuery,
    );
    if (intent == null) return false;
    _pendingUiIntent = intent;
    _notifySafely();
    return true;
  }
  List<String> get messages => List.unmodifiable(_messages);
  bool get paused => _paused || _activeTask?.status == TaskStatus.paused;
  bool get initialized => _initialized;
  String? get initializationError => _initializationError;
  String? get selectedAgent => _selectedAgent;
  String? get selectionError => _selectionError;
  int get agentCount => AgentRegistry.all.length;
  int get indexedDocumentCount => _knowledge.documentCount;
  List<String> get loadedKnowledgeSources => _knowledge.loadedSources;

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
      // Do not cache a failed initialization future; the next screen/task
      // entry must be able to retry loading and indexing the local corpus.
      if (identical(_initializing, attempt)) _initializing = null;
      rethrow;
    }
  }

  Future<void> _initializeOnce() async {
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      QuranicSearchEngine.indexVerses(ayahs
          .map((a) => {
                'id': a.id.toString(),
                'surah': a.surahName,
                'ayah': a.ayahNumber.toString(),
                'text': a.text,
              })
          .toList(growable: false));
      await _knowledge.initialize();
      try {
        await _restoreLatestTask();
      } catch (storageError) {
        // Task recovery is optional for boot: a platform storage failure must
        // not prevent the local Quran index and knowledge engine from starting.
        debugPrint('AgentChatProvider: task recovery unavailable: $storageError');
      }
      _initialized = true;
      _initializationError = null;
    } catch (error) {
      // Startup is initiated by the screen without awaiting a Future. Keep
      // initialization failures visible in provider state instead of leaking
      // an unhandled async exception; executeTask checks readiness before work.
      _initialized = false;
      _initializationError = error.toString();
    } finally {
      _initializing = null;
      _notifySafely();
    }
  }


  /// Builds schema blocks only from real local domain services.
  Future<AgentUiIntent?> _resolveTrustedSchemaIntent(String query) async {
    final normalized = AgentKnowledgeService.normalize(query);

    final abjadMatch = RegExp(
      r'(?:احسب|حساب|قيمة)\s+(?:الجمل|ابجد|ابجدي)\s+(?:لكلمه\s+|لكلمة\s+|للاسم\s+)?(.+)$',
    ).firstMatch(normalized);
    if (abjadMatch != null) {
      final input = abjadMatch.group(1)?.trim() ?? '';
      final cleaned = AbjadConstants.normalizeArabic(input)
          .replaceAll(RegExp(r'[^\u0621-\u064A]'), '');
      if (cleaned.isEmpty) return null;
      final letters = cleaned.runes
          .map(String.fromCharCode)
          .where(AbjadConstants.abjadSquare.containsKey)
          .toList(growable: false);
      if (letters.isEmpty) return null;
      final rows = <List<String>>[
        for (final letter in letters)
          <String>[letter, AbjadConstants.getValue(letter).toString()],
      ];
      return _uiCoordinator.resolveSchemaPayload(
        templateId: 'abjad_template',
        title: 'حساب الجُمّل: $input',
        domain: 'abjad',
        source: 'AbjadConstants.abjadSquare',
        originalQuery: query,
        blocks: <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'metric',
            'title': 'المجموع وفق جدول القيم المربّع',
            'value': AbjadConstants.calculateTotal(cleaned),
          },
          <String, dynamic>{
            'type': 'table',
            'title': 'تفصيل الحروف والقيم',
            'columns': <String>['الحرف', 'القيمة'],
            'rows': rows,
          },
          <String, dynamic>{
            'type': 'text',
            'title': 'منهجية الحساب',
            'text': 'مجموع قيم الحروف وفق جدول القيم المربّع في التطبيق. هذه عملية حسابية ولا تثبت علاقة غيبية أو تنبؤاً.',
          },
        ],
      );
    }

    final countMatch = RegExp(
      r'(?:كم\s+مره\s+(?:وردت?|ذكرت?|تكررت?)\s+(?:كلمه\s+)?|عدد\s+(?:مرات\s+)?(?:ورود|ذكر)\s+(?:كلمه\s+)?)([\u0621-\u064A]{2,})\s+(?:في\s+)?القران(?:\s+الكريم)?',
    ).firstMatch(normalized);
    if (countMatch != null) {
      final requested = countMatch.group(1) ?? '';
      List<Ayah> canonical;
      try {
        canonical = await QuranLoaderService.loadAllAyahs();
      } catch (error) {
        return _uiCoordinator.resolveSchemaPayload(
          templateId: 'analytics_template',
          title: 'تعذر إكمال العدّ القرآني',
          domain: 'quran_analytics',
          source: 'QuranLoaderService',
          originalQuery: query,
          blocks: <Map<String, dynamic>>[
            <String, dynamic>{
              'type': 'status',
              'title': 'مصدر البيانات',
              'status': 'error',
              'message': 'تعذر تحميل المصحف المحلي والتحقق منه: $error',
            },
          ],
        );
      }
      final target = QuranicSearchEngine.normalize(requested);
      if (target.isEmpty) return null;
      var occurrences = 0;
      final references = <String>[];
      for (final ayah in canonical) {
        final words = QuranicSearchEngine.normalize(ayah.text)
            .split(' ')
            .where((word) => word.isNotEmpty);
        final inAyah = words.where((word) => word == target).length;
        if (inAyah > 0) {
          occurrences += inAyah;
          references.add(ayah.surahNumber.toString() + ':' + ayah.ayahNumber.toString());
        }
      }
      return _uiCoordinator.resolveSchemaPayload(
        templateId: 'analytics_template',
        title: 'تكرار «$requested» في القرآن',
        domain: 'quran_analytics',
        source: 'QuranLoaderService + QuranicSearchEngine.normalize',
        originalQuery: query,
        blocks: <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'metric',
            'title': 'عدد المطابقات اللفظية بعد التطبيع',
            'value': occurrences,
          },
          <String, dynamic>{
            'type': 'metric',
            'title': 'عدد الآيات التي وردت فيها الكلمة',
            'value': references.length,
          },
          <String, dynamic>{
            'type': 'list',
            'title': 'مراجع الآيات (سورة:آية)',
            'items': references,
          },
          <String, dynamic>{
            'type': 'text',
            'title': 'منهجية العد',
            'text': 'عدّ لفظي مطابق للكلمة بعد تطبيع علامات التشكيل وبعض أشكال الحروف؛ ليس تحليلاً للجذور الصرفية. المصدر هو المصحف المحلي المحمّل عبر QuranLoaderService.',
          },
        ],
      );
    }

    if (normalized.contains('حاله النواه') ||
        normalized.contains('حاله النظام') ||
        normalized.contains('حاله الوكلاء')) {
      final nucleus = NucleusService();
      await nucleus.initialize();
      final sourceError = nucleus.error;
      return _uiCoordinator.resolveSchemaPayload(
        templateId: 'graph_template',
        title: 'الحالة الفعلية للنواة',
        domain: 'nucleus',
        source: nucleus.source,
        originalQuery: query,
        blocks: <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'status',
            'title': 'تهيئة النواة',
            'status': nucleus.isInitialized && sourceError == null
                ? 'ready'
                : sourceError != null
                    ? 'error'
                    : 'unknown',
            'message': sourceError ??
                (nucleus.isInitialized
                    ? 'تمت تهيئة بيانات النواة.'
                    : 'حالة التهيئة غير مؤكدة.'),
          },
          <String, dynamic>{
            'type': 'status',
            'title': 'النموذج المحلي',
            'status': nucleus.isModelLoaded
                ? 'ready'
                : nucleus.isModelBusy
                    ? 'busy'
                    : 'unknown',
            'message': nucleus.isModelLoaded
                ? 'النموذج محمّل: ' + (nucleus.loadedModelPath ?? 'المسار غير معلن') + '.'
                : nucleus.isModelBusy
                    ? 'النموذج مشغول حالياً.'
                    : 'لا يوجد نموذج محمّل وفق حالة مشغّل النموذج.',
          },
          <String, dynamic>{
            'type': 'metric',
            'title': 'الوكلاء المسجلون',
            'value': nucleus.registeredAgentCount,
          },
          <String, dynamic>{
            'type': 'metric',
            'title': 'مستندات المعرفة المفهرسة',
            'value': nucleus.indexedDocumentCount,
          },
          <String, dynamic>{
            'type': 'list',
            'title': 'مصادر المعرفة المحمّلة',
            'items': nucleus.loadedKnowledgeSources,
          },
        ],
      );
    }
    return null;
  }

  /// through to the generic knowledge-search handler.
  void selectAgent(String? id) {
    if (id == null) {
      _selectedAgent = null;
      _selectionError = null;
      _notifySafely();
      return;
    }
    final agent = AgentRegistry.byId(id);
    if (agent == null) {
      _selectionError = 'تعذر اختيار الوكيل؛ المعرّف «$id» غير مسجل.';
      _notifySafely();
      return;
    }
    _selectedAgent = agent.id;
    _selectionError = null;
    _notifySafely();
  }

  /// Clears only the visible conversation/task. Persisted local memory runs
  /// and vault notes are intentionally retained.
  void clearConversation() {
    final status = _activeTask?.status;
    if (status == TaskStatus.running || status == TaskStatus.paused) return;
    _activeTask = null;
    _messages.clear();
    _cancelled = false;
    _paused = false;
    _notifySafely();
  }

  Future<void> executeTask(String query) => _runTask(query);

  /// Resumes the most recent paused checkpoint. Completed steps are preserved;
  /// only pending/paused/in-flight steps are executed again.
  Future<void> resumeTask() async {
    final task = _activeTask;
    if (task == null || task.status != TaskStatus.paused) return;
    await _runTask(task.userQuery, resumeFrom: task);
  }

  Future<void> _runTask(String query, {AgentTask? resumeFrom}) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    final oldStatus = _activeTask?.status;
    if (resumeFrom == null &&
        (oldStatus == TaskStatus.running || oldStatus == TaskStatus.paused)) return;
    final nucleusContext = NucleusService();
    _pendingUiIntent = await _resolveTrustedSchemaIntent(clean) ??
        _uiCoordinator.resolve(
          clean,
          currentSurahNumber: nucleusContext.currentSurahNumber,
          currentAyahNumber: nucleusContext.currentAyahNumber,
        );

    final generation = ++_executionGeneration;
    final nucleusAtStart = NucleusService();
    final contextSurahNumber = nucleusAtStart.currentSurahNumber;
    final contextAyahNumber = nucleusAtStart.currentAyahNumber;
    final contextVerseText = nucleusAtStart.currentVerseText;
    final hasContextAtStart = contextSurahNumber != null &&
        contextAyahNumber != null &&
        contextVerseText != null &&
        contextVerseText.trim().isNotEmpty;
    _activeTaskVerseSource = hasContextAtStart
        ? 'القرآن الكريم $contextSurahNumber:$contextAyahNumber'
        : null;
    _cancelled = false;
    _paused = false;
    _attemptsByAgent.clear();

    final agents = resumeFrom == null
        ? _route(clean)
        : resumeFrom.steps
            .map((step) => AgentRegistry.byId(step.agentName))
            .whereType<AgentDefinition>()
            .toList(growable: false);
    if (resumeFrom != null &&
        (agents.length != resumeFrom.steps.length || agents.isEmpty)) {
      _selectionError = 'تعذر استئناف المهمة: أحد الوكلاء المحفوظين لم يعد مسجلًا.';
      _notifySafely();
      return;
    }
    var task = resumeFrom ?? AgentTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userQuery: clean,
      createdAt: DateTime.now(),
      status: TaskStatus.running,
      steps: agents.asMap().entries
          .map((entry) => AgentStep(
                number: entry.key + 1,
                agentName: entry.value.id,
                title: entry.value.name,
                subtitle: entry.value.description,
              ))
          .toList(),
    );
    task = task.copyWith(status: TaskStatus.running);
    _setActiveTask(task);
    if (resumeFrom == null) {
      _messages.add('المستخدم: $clean');
    } else {
      _messages.add('استئناف المهمة المحفوظة: $clean');
    }
    _notifySafely();

    try {
      await initialize();
      if (!_initialized) {
        throw StateError(
          'تعذر تهيئة المعرفة المحلية: ${_initializationError ?? 'خطأ غير محدد'}',
        );
      }
      for (var i = 0; i < agents.length; i++) {
        // Keep completed checkpoint steps immutable during resume.
        if (task.steps[i].status == StepStatus.done) continue;
        if (_isCancelledFor(generation)) {
          _markCancelledIfCurrent(task);
          return;
        }
        while (_paused && !_isCancelledFor(generation)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        if (_isCancelledFor(generation)) {
          _markCancelledIfCurrent(task);
          return;
        }

        _currentStepNumber = i + 1;
        var step = task.steps[i].copyWith(
          status: StepStatus.running,
          startedAt: DateTime.now(),
        );
        task = task.copyWith(steps: _replaceStep(task.steps, i, step));
        _setActiveTask(task);
        _notifySafely();

        try {
          final result = await _executeWithRetries(agents[i], clean, generation: generation);
          step = step.copyWith(
            status: StepStatus.done,
            progress: 1,
            details: _detailsFor(agents[i], result),
            result: result,
            completedAt: DateTime.now(),
          );
          task = task.copyWith(steps: _replaceStep(task.steps, i, step));
          _setActiveTask(task);
          _notifySafely();
        } catch (error) {
          // The runtime may throw when stopGeneration interrupts native
          // inference. Preserve cancellation instead of marking this step as
          // failed and allowing retries or a false failure state.
          if (_isCancelledFor(generation)) {
            _markCancelledIfCurrent(task);
            return;
          }
          step = step.copyWith(
            status: StepStatus.failed,
            result: error.toString(),
            details: [
              StepDetail('المحاولات', '${_attemptsByAgent[agents[i].id] ?? 1} من 3'),
              const StepDetail('الحالة', 'فشل فعلي؛ لم تُستبدل النتيجة بمخرجات وهمية'),
            ],
            completedAt: DateTime.now(),
          );
          task = task.copyWith(
            status: TaskStatus.failed,
            steps: _replaceStep(task.steps, i, step),
            error: error.toString(),
          );
          _setActiveTask(task);
          _notifySafely();
          return;
        }
      }

      final answer = await _composeAnswer(
        task,
        contextSurahNumber: contextSurahNumber,
        contextAyahNumber: contextAyahNumber,
        contextVerseText: contextVerseText,
      );
      // Local GGUF generation can run while the final answer is composed.
      // If the user cancels during that phase, do not report a completed task
      // or persist a cancelled run as a successful answer.
      if (_isCancelledFor(generation)) {
        _markCancelledIfCurrent(task);
        return;
      }
      task = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        finalAnswer: answer,
      );
      _setActiveTask(task);
      _messages.add('مُدَبِّر: $answer');
      try {
        await _memory.saveRun(
          query: clean,
          answer: answer,
          sources: _sourcesFromTask(task),
        );
      } catch (memoryError) {
        // A persistence failure must not rewrite a successfully completed
        // inference/retrieval task as failed. Surface the storage issue
        // separately while preserving the actual result and task status.
        _messages.add('تنبيه: اكتملت المهمة، لكن تعذر حفظ سجلها محليًا: $memoryError');
      }
      try {
        await AchievementsService.recordCompletedInsight();
      } catch (achievementError) {
        // Optional achievement bookkeeping must not turn a successful local
        // retrieval/inference run into a failed task.
        _messages.add('تنبيه: اكتملت المهمة، لكن تعذر تحديث سجل الإنجازات المحلي: $achievementError');
      }
      _notifySafely();
    } catch (error) {
      // Cancellation wins over an initialization/generation error. A native
      // stop can surface as an exception; it must not turn a cancelled task
      // into a failed one or append a misleading failure message.
      if (_isCancelledFor(generation)) {
        _markCancelledIfCurrent(task);
        return;
      }
      task = task.copyWith(status: TaskStatus.failed, error: error.toString());
      _setActiveTask(task);
      _messages.add('تعذر إكمال المهمة: $error');
      _notifySafely();
    }
  }

  void pauseOrResume() {
    final task = _activeTask;
    if (task == null ||
        (task.status != TaskStatus.running &&
            task.status != TaskStatus.paused)) {
      return;
    }
    // A restored checkpoint has paused task status but no live execution loop.
    // Route that case through the resumable runner instead of merely flipping
    // a boolean that no loop is waiting on.
    if (task.status == TaskStatus.paused && !_paused) {
      unawaited(resumeTask());
      return;
    }
    _paused = !_paused;
    // This cooperative pause takes effect at the next step boundary; an
    // already-running local lookup/inference is not falsely marked as stopped.
    _setActiveTask(task.copyWith(
      status: _paused ? TaskStatus.paused : TaskStatus.running,
    ));
    _notifySafely();
  }

  bool _isCancelledFor(int generation) =>
      _cancelled || generation != _executionGeneration;

  void _markCancelledIfCurrent(AgentTask task) {
    // An older async run must never overwrite the currently selected task.
    // Use the latest provider snapshot, not the caller's stale local copy, so
    // cancellation cannot discard completed steps or leave a running step
    // visually stuck after the task has already been cancelled.
    final current = _activeTask;
    if (current == null || current.id != task.id) return;
    final now = DateTime.now();
    final steps = current.steps.map((step) {
      if (step.status != StepStatus.pending &&
          step.status != StepStatus.running &&
          step.status != StepStatus.paused) {
        return step;
      }
      return step.copyWith(
        status: StepStatus.cancelled,
        completedAt: now,
      );
    }).toList(growable: false);
    _setActiveTask(current.copyWith(
      status: TaskStatus.cancelled,
      steps: steps,
      completedAt: now,
    ));
    _notifySafely();
  }

  void cancel() {
    final task = _activeTask;
    if (task == null ||
        (task.status != TaskStatus.running &&
            task.status != TaskStatus.paused)) {
      return;
    }
    _cancelled = true;
    _executionGeneration++;
    _paused = false;
    // Stop native generation too; otherwise the task would remain busy until
    // llama.cpp finishes even though the user explicitly cancelled it.
    if (NucleusService().isGenerating) {
      unawaited(NucleusService().stopGeneration().catchError((Object error) {
        debugPrint('AgentChatProvider: native generation stop failed: $error');
      }));
    }
    _markCancelledIfCurrent(task);
  }

  List<AgentStep> _replaceStep(List<AgentStep> steps, int index, AgentStep value) {
    final copy = List<AgentStep>.from(steps);
    copy[index] = value;
    return copy;
  }

  /// Parses only the numeric syntax; range validation happens against the
  /// canonical local Quran index so an invalid reference gets an explicit error.
  @visibleForTesting
  static ({int surah, int ayah})? parseVerseReference(String query) {
    // Arabic-Indic (٠١٢) and Eastern Arabic/Persian (۰۱۲) digits are common
    // in Arabic input; normalize only digits before strict syntax validation.
    final normalized = query.trim().replaceAllMapped(
      RegExp(r'[\u0660-\u0669\u06F0-\u06F9]'),
      (match) {
        final code = match.group(0)!.codeUnitAt(0);
        final digit = code >= 0x06F0 ? code - 0x06F0 : code - 0x0660;
        return String.fromCharCode(0x30 + digit);
      },
    );
    final match = RegExp(r'^([0-9]{1,3}) *[:/] *([0-9]{1,3})$')
        .firstMatch(normalized);
    if (match == null) return null;
    final surah = int.tryParse(match.group(1)!);
    final ayah = int.tryParse(match.group(2)!);
    if (surah == null || ayah == null) return null;
    return (surah: surah, ayah: ayah);
  }

  List<AgentDefinition> _route(String query) {
    final result = <AgentDefinition>[];
    void add(String id) {
      final agent = AgentRegistry.byId(id);
      if (agent != null && !result.any((existing) => existing.id == id)) {
        result.add(agent);
      }
    }

    // A bare verse reference is a lookup request, not a text-search query.
    // Keep this deterministic path independent of any selected general agent.
    if (parseVerseReference(query) != null) {
      add('ayaat');
      add('verifier');
      return result;
    }

    // An explicit agent selection is an execution constraint, not just an
    // extra entry in the default pipeline. Run the selected specialist between
    // the shared safety/planning stages and the critic/verifier stages.
    // This avoids silently running the full multi-agent pipeline when the
    // user deliberately chose one agent from the console.
    final selectedId = _selectedAgent;
    if (selectedId != null) {
      add('planner');
      add('safety');
      add(selectedId);
      add('critic');
      add('verifier');
      return result;
    }

    add('planner');
    add('safety');
    add('researcher');
    add('retriever');

    final normalized = AgentKnowledgeService.normalize(query);
    if (RegExp(r'ايه|قران|سوره|تفسير|معني|النور|الصمد|مسند|هيروغليف|عثمان').hasMatch(normalized)) {
      for (final id in ['ayaat', 'tafsir', 'siyaq']) {
        add(id);
      }
    }
    if (RegExp(r'جمل|ابجد').hasMatch(normalized)) add('jummal');
    if (RegExp(r'عدد|تكرار|مره|كم|احصاء|كلمه').hasMatch(normalized)) {
      add('adadi');
    }
    if (RegExp(r'ذاكره|سابق|تذكر|ملاحظه|دفتر|محفوظ|مخزن').hasMatch(normalized)) add('memory');
    add('overthinker');
    add('loop_engineering');
    add('critic');
    add('damj');
    add('verifier');
    add('obsidian');
    return result;
  }

  Future<String> _executeWithRetries(
    AgentDefinition agent,
    String query, {
    required int generation,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      if (_isCancelledFor(generation)) {
        throw StateError('أُلغي تنفيذ الوكيل ${agent.name}.');
      }
      _attemptsByAgent[agent.id] = attempt;
      try {
        final result = await _executeAgent(agent, query);
        if (_isCancelledFor(generation)) {
          throw StateError('أُلغي تنفيذ الوكيل ${agent.name}.');
        }
        return result;
      } catch (error) {
        if (_isCancelledFor(generation)) rethrow;
        lastError = error;
        if (attempt < 3) {
          await Future<void>.delayed(Duration(milliseconds: 150 * attempt));
        }
      }
    }
    throw StateError('الوكيل ${agent.name} فشل بعد 3 محاولات: $lastError');
  }

  Future<String> _executeAgent(AgentDefinition agent, String query) async {
    switch (agent.id) {
      case 'planner':
      case 'muwajjih':
        return _buildExecutionPlan(query);
      case 'safety':
        return 'فحص الأمان: البحث محلي وقراءة فقط؛ لا اتصال بخدمة بعيدة، '
            'ولا ادعاء بتشغيل نموذج توليدي أو أوامر نظام.';
      case 'researcher':
      case 'retriever':
      case 'tafsir':
      case 'rabet':
      case 'tibyan':
      case 'tadabbur':
      case 'asrar_maknuna':
      case 'khabir':
      case 'adham':
      case 'mutashabih':
      case 'overthinker':
      case 'critic':
      case 'narrator':
        return _searchKnowledge(agent, query);
      case 'ayaat':
        final reference = parseVerseReference(query);
        if (reference != null) {
          final surahNumber = reference.surah;
          final ayahNumber = reference.ayah;
          if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
            return 'مرجع الآية خارج النطاق الصحيح؛ استخدم رقم السورة من 1 إلى 114 ورقم آية موجبًا.';
          }
          final grouped = await QuranLoaderService.loadBySurah();
          final candidates = grouped[surahNumber]
                  ?.where((ayah) => ayah.ayahNumber == ayahNumber)
                  .toList() ??
              const [];
          if (candidates.isEmpty) {
            return 'لم يُعثر على الآية ' + surahNumber.toString() + ':' +
                ayahNumber.toString() + ' في مصدر المصحف المحلي.';
          }
          final verse = candidates.first;
          return 'الآية ' + surahNumber.toString() + ':' +
              ayahNumber.toString() + ' (' + verse.surahName + '): ' +
              verse.text + ' — المصدر: assets/quran_full.json';
        }
        final hits = QuranicSearchEngine.search(query).take(8).toList();
        if (hits.isEmpty) {
          return 'لم يعثر البحث المحلي على شاهد قرآني مطابق؛ لا تُنشأ آية بديلة. '
            'يمكن متابعة الإجابة العامة عن السؤال دون نسبة نص إلى القرآن.';
        }
        return hits.map((v) =>
            '${v['surah']} ${v['ayah']}: ${v['text']} — المصدر: assets/quran_full.json').join('\n');
      case 'siyaq':
        final hits = QuranicSearchEngine.search(query).take(4).toList();
        if (hits.isEmpty) return 'لم يعثر البحث المحلي على موضع سياقي مطابق؛ هذا لا يمنع معالجة السؤال العام، '
            'ولا يجيز نسبة نص غير موثق إلى القرآن.';
        return hits.map((v) =>
            '${v['surah']} ${v['ayah']}: ${v['text']}').join('\n');
      case 'adadi':
        final normalizedQuery = QuranicSearchEngine.normalize(query);
        final frequencies = QuranicSearchEngine.getWordFrequency();
        const ignoredTerms = <String>{
          'كم', 'مره', 'عدد', 'تكرار', 'احصاء', 'احصائي', 'كلمه', 'كلمات',
          'القران', 'في', 'من', 'عن', 'هو', 'هي', 'ما', 'ورد', 'وردت',
          'مرات', 'احسب', 'احص', 'لي', 'هل', 'كل', 'الذي', 'التي',
        };
        final candidates = normalizedQuery
            .split(' ')
            .where((term) => term.length >= 2 && !ignoredTerms.contains(term))
            .toSet();
        final matched = candidates
            .where(frequencies.containsKey)
            .toList(growable: false);
        if (matched.isEmpty) {
          return 'لم أجد كلمة محددة قابلة للعدّ الحرفي في السؤال. '
              'حدّد الكلمة المطلوبة، مثل: كم مرة وردت كلمة الله في القرآن؟ '
              'لا يُقدَّم إجمالي كلمات المصحف من فهرس التكرار الجزئي.';
        }
        matched.sort((a, b) => a.compareTo(b));
        final lines = matched.map((word) =>
            '$word: ${frequencies[word]} تكرارًا في فهرس الكلمات المحلي');
        return 'إحصاء حرفي للكلمات المطابقة بعد تطبيع البحث العربي '
            '(إزالة التشكيل وتوحيد بعض صور الألف/الياء/التاء المربوطة):\n'
            '${lines.join('\n')}\n'
            'المصدر: فهرس الآيات المحلي المبني من assets/quran_full.json. '
            'هذا عدّ نصي وفق قواعد التطبيع المذكورة، وليس استنتاجًا تفسيريًا.';
      case 'jummal':
        return 'حساب أبجد للنص المدخل = ${_abjad(query)}. '
            'هذا حساب حرفي وفق جدول أبجد المضمّن، وليس استنتاجًا غيبيًا.';
      case 'loop_engineering':
        return 'سياسة هندسة الحلقة مفعّلة: حتى 3 محاولات لكل خطوة، '
            'مع تسجيل الخطأ النهائي وعدم اختلاق نتيجة بديلة. '
            'محاولات هذه الخطوة: ${_attemptsByAgent[agent.id] ?? 1}.';
      case 'memory':
        final notes = await _memory.searchVault(query, limit: 5);
        final runs = await _memory.recentRuns(limit: 5);
        if (notes.isEmpty && runs.isEmpty) {
          return 'لا توجد ملاحظات أو جلسات سابقة محفوظة محليًا بعد.';
        }
        final sections = <String>[];
        if (notes.isNotEmpty) {
          sections.add(
            'ملاحظات دفتر المعرفة المطابقة (محلية):\n' +
                notes.map((row) {
                  final title = (row['title'] ?? 'ملاحظة بلا عنوان').toString();
                  final content = (row['content'] ?? '').toString();
                  final sources = row['sources'] is List
                      ? (row['sources'] as List).whereType<String>().join(', ')
                      : '';
                  final createdAt = (row['createdAt'] ?? '').toString();
                  final snippet = content.length > 1200
                      ? '${content.substring(0, 1200)}…'
                      : content;
                  return 'العنوان: $title\nالتاريخ: $createdAt\nالمصادر: ${sources.isEmpty ? 'غير مسجلة' : sources}\n$snippet';
                }).join('\n\n'),
          );
        }
        if (runs.isNotEmpty) {
          sections.add(
            'جلسات التنفيذ الأخيرة:\n' +
                runs.map((row) =>
                    'سابقًا: ${row['query']}\nالملخص: ${row['answer']}').join('\n\n'),
          );
        }
        return sections.join('\n\n---\n\n');
      case 'obsidian':
        final evidence = _activeTask?.steps
                .where((step) => step.result != null && step.result!.trim().isNotEmpty)
                .map((step) => '${step.agentName}: ${step.result}')
                .join('\n\n') ??
            '';
        final note = await _memory.saveVaultNote(
          title: query,
          content: evidence.isEmpty ? 'لا توجد أدلة سابقة لإرفاقها.' : evidence,
          sources: _sourcesFromTask(_activeTask),
        );
        return 'دفتر المعرفة المحلي: تم الحفظ ثم القراءة للتحقق. '
            'نجاح الحفظ: ${note['saved']}؛ نجاح القراءة الراجعة: ${note['readBack']}؛ '
            'المعرّف: ${(note['note'] as Map)['id']}.';
      case 'damj':
        final previous = _activeTask?.steps
                .where((step) => step.result != null && step.result!.trim().isNotEmpty)
                .map((step) => step.result!)
                .toList() ??
            const <String>[];
        return previous.isEmpty
            ? 'لا توجد نتائج سابقة لدمجها.'
            : 'دمج ${previous.length} مخرجات فعلية للوكلاء. '
                'لم يُضف الدمج أدلة جديدة خارج النتائج السابقة.';
      case 'verifier':
      case 'ikhtibar':
        final prior = _activeTask?.steps
                .where((step) => step.number < (_currentStepNumber ?? 999) &&
                    step.status == StepStatus.done)
                .toList() ??
            const <AgentStep>[];
        final withResults = prior.where((step) => (step.result ?? '').trim().isNotEmpty).length;
        final sources = _sourcesFromSteps(prior);
        final verificationVerdict = sources.isEmpty
            ? 'الحكم: اكتمال شكلي فقط؛ لا توجد إحالات مصدرية يمكن تتبعها.'
            : 'الحكم: توجد إحالات مصدرية تحتاج مراجعة مقابل الأصول.';
        return 'التحقق المستقل: ${withResults} خطوة سابقة لديها مخرجات غير فارغة؛ '
            'المصادر المسجلة: ${sources.isEmpty ? 'لا توجد مصادر موثقة' : sources.join(', ')}. '
            '$verificationVerdict هذا فحص اكتمال ومصدر، وليس تصديقًا تلقائيًا على صحة الاستنتاج أو التفسير.';
      case 'tadrib':
        // The canonical Quran corpus is source material, not a user-labelled
        // supervised dataset. Never turn its metadata into training labels or
        // report a training run from the agent console.
        return 'لم يبدأ التدريب: لا يجوز تحويل نص المصحف تلقائيًا إلى بيانات تدريب مصنّفة. '
            'افتح شاشة التدريب واستورد ملف JSON يحتوي على عينات مُعنونة يدويًا '
            'بتصنيفات مدعومة ومتوازنة. التدريب المتاح يخص المصنّف المحلي الصغير فقط؛ '
            'ولا يدرّب أوزان Qwen أو GGUF.';
      case 'muraqib':
        final task = _activeTask;
        return 'مراقبة التنفيذ: الحالة=${task?.status.name ?? 'غير متاحة'}؛ '
            'الخطوات المكتملة=${task?.steps.where((s) => s.status == StepStatus.done).length ?? 0}.';
      default:
        return _searchKnowledge(agent, query);
    }
  }

  int? _currentStepNumber;

  /// Produces an honest, query-specific execution outline from the same
  /// deterministic routing rules used by the runner. This is a real plan of
  /// registered handlers, not a claim that the language model generated it.
  String _buildExecutionPlan(String query) {
    final routed = _route(query)
        .where((agent) =>
            agent.id != 'planner' &&
            agent.id != 'muwajjih' &&
            agent.id != 'safety')
        .toList(growable: false);
    if (routed.isEmpty) {
      return 'تعذر تكوين خطة قابلة للتنفيذ: لم يُنتج موجّه المهام أي معالج مسجل. '
          'لم يبدأ تنفيذ بديل غير موثق.';
    }

    final intent = parseVerseReference(query) != null
        ? 'استرجاع آية محددة والتحقق من مرجعها'
        : RegExp(r'جمل|ابجد').hasMatch(AgentKnowledgeService.normalize(query))
            ? 'حساب أبجد وفق الجدول المحلي ومراجعة النتيجة'
            : RegExp(r'عدد|تكرار|مره|احصاء|كلمه')
                    .hasMatch(AgentKnowledgeService.normalize(query))
                ? 'إجراء بحث أو إحصاء نصي من البيانات المحلية'
                : 'استرجاع أدلة محلية ومراجعة حدود الاستنتاج';
    final stages = routed.asMap().entries.map((entry) {
      final agent = entry.value;
      return '${entry.key + 1}. ${agent.name} (${agent.id}): ${agent.description}';
    }).join('\n');
    return 'خطة تنفيذ محلية مبنية على قواعد التوجيه الفعلية.\n'
        'الهدف المصنّف: $intent.\n'
        'المعالجات المسجلة التي سيحاول المسار تشغيلها:\n$stages\n'
        'مصدر الخطة: قواعد التوجيه المحلية وسجل الوكلاء؛ '
        'لم تُستخدم خدمة تخطيط بعيدة، ولا تعني الخطة أن الخطوات قد نُفّذت بعد.';
  }

  Future<String> _searchKnowledge(AgentDefinition agent, String query) async {
    final includeVariants = RegExp(r'مسند|هيروغليف|عثمان|خط|صيغة').hasMatch(query);
    final hits = await _knowledge.search(
      query,
      limit: agent.id == 'overthinker' || agent.id == 'critic' ? 4 : 6,
      includeScriptVariants: includeVariants,
    );
    if (hits.isEmpty) {
      if (agent.id == 'overthinker') {
        return 'مراجعة المخاطر: لم يظهر دليل مطابق في الأصول المفهرسة؛ '
            'يجب تضييق السؤال أو إضافة ملف معرفة مناسب. لا يمكن إثبات النتيجة من البيانات الحالية.';
      }
      if (agent.id == 'critic') {
        return 'المراجعة النقدية: لا توجد نتيجة مصدرية مطابقة يمكن تدقيقها؛ '
            'تُترك المسألة غير محسومة بدلًا من اختلاق معلومات.';
      }
      return 'لم يُعثر على مقاطع مطابقة في المعرفة المحلية لهذا الطلب. '
          'المصادر المفحوصة فعليًا: ${_knowledge.loadedSources.join(', ')}.';
    }
    final output = hits.map((doc) {
      final snippet = doc.content.length > 700 ? '${doc.content.substring(0, 700)}…' : doc.content;
      return 'المقطع: ${doc.title}\nالمصدر: ${doc.source}\n$snippet';
    }).join('\n\n');
    if (agent.id == 'overthinker') {
      return 'مراجعة متعمقة مبنية على ${hits.length} مقاطع محلية. '
          'تحقق من سياق كل مقطع؛ تطابق الكلمات وحده لا يثبت علاقة سببية أو تفسيرًا.\n\n$output';
    }
    if (agent.id == 'critic') {
      return 'مراجعة نقدية للأدلة: ${hits.length} مقاطع مسترجعة. '
          'قد يكون التطابق لفظيًا فقط؛ لم تُضف ادعاءات غير موجودة في المقاطع.\n\n$output';
    }
    return 'نتائج مسترجعة بواسطة ${agent.name} من الأصول المضمّنة:\n\n$output';
  }

  List<StepDetail> _detailsFor(AgentDefinition agent, String result) {
    const explicitHandlers = <String>{
      'muwajjih', 'planner', 'safety', 'researcher', 'retriever',
      'tafsir', 'rabet', 'tibyan', 'tadabbur', 'overthinker',
      'critic', 'narrator', 'ayaat', 'siyaq', 'jummal', 'adadi',
      'memory', 'loop_engineering', 'verifier', 'damj', 'obsidian',
    };
    return [
      StepDetail('الوكيل', agent.name),
      StepDetail('الطبقة', agent.layer),
      StepDetail(
        'مسار التنفيذ',
        explicitHandlers.contains(agent.id)
            ? 'معالج مسجل لهذا المعرّف'
            : 'استرجاع عام من المعرفة المحلية؛ لا توجد معالجة تخصصية مستقلة لهذا المعرّف بعد',
      ),
      StepDetail('المحاولات', '${_attemptsByAgent[agent.id] ?? 1} من 3'),
      StepDetail('الأصول المحمّلة', _knowledge.loadedSources.length.toString()),
      StepDetail('المصادر', _sourcesFromText(result).join(', ').isEmpty
          ? 'لا يوجد مصدر مذكور في هذه النتيجة'
          : _sourcesFromText(result).join(', ')),
    ];
  }

  Future<String> _composeAnswer(
    AgentTask task, {
    required int? contextSurahNumber,
    required int? contextAyahNumber,
    required String? contextVerseText,
  }) async {
    final results = task.steps
        .where((step) => step.result != null && step.result!.trim().isNotEmpty)
        .map((step) => '${step.title}:\n${step.result}')
        .toList();
    if (results.isEmpty) {
      return 'اكتمل المسار دون نتائج؛ لم يتم اختلاق إجابة.';
    }

    final evidence = results.join('\n\n');
    final hasVerseContext = contextVerseText != null &&
        contextVerseText.trim().isNotEmpty &&
        contextSurahNumber != null &&
        contextAyahNumber != null;
    final verseSource = hasVerseContext
        ? 'القرآن الكريم $contextSurahNumber:$contextAyahNumber'
        : null;
    final contextualEvidence = !hasVerseContext
        ? evidence
        : evidence + '\n\nالسياق المحدد في المصحف (' +
            contextSurahNumber.toString() + ':' +
            contextAyahNumber.toString() + '):\n' + contextVerseText!;
    final sourceList = <String>{
      ..._knowledge.loadedSources,
      if (verseSource != null) verseSource,
    }.join(', ');
    final runtime = NucleusService();
    if (runtime.isModelLoaded) {
      try {
        final boundedEvidence = contextualEvidence.length > 12000
            ? '${contextualEvidence.substring(0, 12000)}\n[تم اقتطاع بقية الأدلة لتحديد طول السياق]'
            : contextualEvidence;
        final generated = await runtime.generateGroundedAnswer(
          question: task.userQuery,
          evidence: boundedEvidence,
          maxTokens: 512,
        );
        return 'إجابة مولّدة محليًا بواسطة نموذج GGUF المحمّل (ليست نصًا قرآنيًا):\n'
            '$generated\n\n'
            'الأدلة والسياق المحلي المحدد، للرجوع والتحقق:\n$contextualEvidence\n\n'
            'المصادر المحمّلة: $sourceList. يجب التحقق من أي استنتاج مولّد مقابل النصوص المصدرية.';
      } catch (error) {
        return 'تعذر الاستدلال بالنموذج المحلي؛ لم أستبدل ذلك بإجابة مولّدة وهمية.\n\n'
            'تقرير الأدلة والسياق المحلي:\n$contextualEvidence\n\n'
            'سبب تعذر النموذج: $error\nالمصادر: $sourceList.';
      }
    }

    return 'تقرير الوكلاء المحلي:\n\n$contextualEvidence\n\n'
        'المصادر المحمّلة: $sourceList. '
        'هذه نتائج استرجاع وفحوص محلية؛ لم يُشغّل نموذج توليدي لأن GGUF غير محمّل.';
  }

  List<String> _sourcesFromText(String text) {
    final known = _knowledge.loadedSources.toList();
    return known.where(text.contains).toList(growable: false);
  }

  List<String> _sourcesFromSteps(List<AgentStep>? steps) {
    if (steps == null) return const [];
    final sources = <String>{};
    for (final step in steps) {
      if (step.result != null) sources.addAll(_sourcesFromText(step.result!));
    }
    return sources.toList(growable: false);
  }

  List<String> _sourcesFromTask(AgentTask? task) {
    if (task == null) return const <String>[];
    final sources = _sourcesFromSteps(task.steps).toSet();
    final verseSource = _activeTaskVerseSource;
    if (verseSource != null) sources.add(verseSource);
    return sources.toList(growable: false);
  }

  int _abjad(String text) {
    var total = 0;
    for (final rune in text.runes) {
      total += AbjadConstants.getValue(String.fromCharCode(rune));
    }
    return total;
  }

  String exportJson() {
    final task = _activeTask;
    if (task == null) return '{}';
    return const JsonEncoder.withIndent('  ').convert({
      'id': task.id,
      'query': task.userQuery,
      'status': task.status.name,
      'progress': task.progress,
      'sources': _sourcesFromTask(task),
      'steps': task.steps
          .map((step) => {
                'agent': step.agentName,
                'title': step.title,
                'status': step.status.name,
                'attempts': _attemptsByAgent[step.agentName] ?? 0,
                'result': step.result,
                'details': step.details.map((d) => {'label': d.label, 'value': d.value}).toList(),
              })
          .toList(),
      'answer': task.finalAnswer,
    });
  }
}
,
    ).firstMatch(normalized);
    if (abjadMatch != null) {
      final input = abjadMatch.group(1)?.trim() ?? '';
      if (input.isEmpty) return null;
      final cleaned = AbjadConstants.normalizeArabic(input)
          .replaceAll(RegExp(r'[^\u0621-\u064A]'), '');
      if (cleaned.isEmpty) return null;
      final letters = cleaned.runes
          .map(String.fromCharCode)
          .where((letter) => AbjadConstants.abjadSquare.containsKey(letter))
          .toList(growable: false);
      if (letters.isEmpty) return null;
      final rows = <List<String>>[
        for (final letter in letters)
          <String>[letter, AbjadConstants.getValue(letter).toString()],
      ];
      final total = AbjadConstants.calculateTotal(cleaned);
      return _uiCoordinator.resolveSchemaPayload(
        templateId: 'abjad_template',
        title: 'حساب الجُمّل: $input',
        domain: 'abjad',
        source: 'AbjadConstants.abjadSquare',
        originalQuery: query,
        blocks: <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'metric',
            'title': 'المجموع وفق جدول القيم المربّع',
            'value': total,
          },
          <String, dynamic>{
            'type': 'table',
            'title': 'تفصيل الحروف والقيم',
            'columns': <String>['الحرف', 'القيمة'],
            'rows': rows,
          },
          <String, dynamic>{
            'type': 'text',
            'title': 'طريقة الحساب',
            'text': 'الحساب ناتج عن جمع قيم الحروف وفق الجدول المربّع المعرّف في التطبيق؛ لا يثبت علاقة غيبية أو تنبؤاً.',
          },
        ],
      );
    }

    final countMatch = RegExp(
      r'(?:كم\s+مره\s+(?:وردت?|ذُكرت?|ذكر|تكررت?)\s+(?:كلمه\s+)?|عدد\s+(?:مرات\s+)?(?:ورود|ذكر)\s+(?:كلمه\s+)?)([\u0621-\u064A]{2,})\s+(?:في\s+)?(?:القران|القران\s+الكريم)',
    ).firstMatch(normalized);
    if (countMatch != null) {
      final requested = countMatch.group(1) ?? '';
      final canonical = await QuranLoaderService.loadAllAyahs();
      final normalizedTarget = QuranicSearchEngine.normalize(requested);
      if (normalizedTarget.isEmpty) return null;
      var occurrences = 0;
      final references = <String>[];
      for (final ayah in canonical) {
        final words = QuranicSearchEngine.normalize(ayah.text)
            .split(' ')
            .where((word) => word.isNotEmpty);
        final inAyah = words.where((word) => word == normalizedTarget).length;
        if (inAyah > 0) {
          occurrences += inAyah;
          references.add('${ayah.surahNumber}:${ayah.ayahNumber}');
        }
      }
      return _uiCoordinator.resolveSchemaPayload(
        templateId: 'analytics_template',
        title: 'تكرار «$requested» في القرآن',
        domain: 'quran_analytics',
        source: 'QuranLoaderService + QuranicSearchEngine.normalize',
        originalQuery: query,
        blocks: <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'metric',
            'title': 'عدد المطابقات اللفظية بعد التطبيع',
            'value': occurrences,
          },
          <String, dynamic>{
            'type': 'metric',
            'title': 'عدد الآيات التي وردت فيها الكلمة',
            'value': references.length,
          },
          <String, dynamic>{
            'type': 'list',
            'title': 'مراجع الآيات (سورة:آية)',
            'items': references,
          },
          <String, dynamic>{
            'type': 'text',
            'title': 'منهجية العد',
            'text': 'عدّ لفظي مطابق للكلمة بعد تطبيع علامات التشكيل وبعض أشكال الحروف؛ ليس تحليلاً للجذور الصرفية. المصدر: المصحف المحلي الذي اجتاز تحقق QuranLoaderService.',
          },
        ],
      );
    }

    if (normalized.contains('حاله النواه') ||
        normalized.contains('حاله النظام') ||
        normalized.contains('حاله الوكلاء')) {
      final nucleus = NucleusService();
      await nucleus.initialize();
      final sourceError = nucleus.error;
      return _uiCoordinator.resolveSchemaPayload(
        templateId: 'graph_template',
        title: 'الحالة الفعلية للنواة',
        domain: 'nucleus',
        source: nucleus.source,
        originalQuery: query,
        blocks: <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'status',
            'title': 'تهيئة النواة',
            'status': nucleus.isInitialized && sourceError == null
                ? 'ready'
                : sourceError != null
                    ? 'error'
                    : 'unknown',
            'message': sourceError ?? (nucleus.isInitialized
                ? 'تمت تهيئة بيانات النواة.'
                : 'حالة التهيئة غير مؤكدة.'),
          },
          <String, dynamic>{
            'type': 'status',
            'title': 'النموذج المحلي',
            'status': nucleus.isModelLoaded
                ? 'ready'
                : nucleus.isModelBusy
                    ? 'busy'
                    : 'unknown',
            'message': nucleus.isModelLoaded
                ? 'النموذج محمّل: ${nucleus.loadedModelPath ?? 'المسار غير معلن'}.'
                : nucleus.isModelBusy
                    ? 'النموذج مشغول حالياً.'
                    : 'لا يوجد نموذج محمّل وفق حالة مشغّل النموذج.',
          },
          <String, dynamic>{
            'type': 'metric',
            'title': 'الوكلاء المسجلون',
            'value': nucleus.registeredAgentCount,
          },
          <String, dynamic>{
            'type': 'metric',
            'title': 'مستندات المعرفة المفهرسة',
            'value': nucleus.indexedDocumentCount,
          },
          <String, dynamic>{
            'type': 'list',
            'title': 'مصادر المعرفة المحمّلة',
            'items': nucleus.loadedKnowledgeSources,
          },
        ],
      );
    }

    return null;
  }

  /// Selects only registered agents. Invalid/stale IDs never silently fall
  /// through to the generic knowledge-search handler.
  void selectAgent(String? id) {
    if (id == null) {
      _selectedAgent = null;
      _selectionError = null;
      _notifySafely();
      return;
    }
    final agent = AgentRegistry.byId(id);
    if (agent == null) {
      _selectionError = 'تعذر اختيار الوكيل؛ المعرّف «$id» غير مسجل.';
      _notifySafely();
      return;
    }
    _selectedAgent = agent.id;
    _selectionError = null;
    _notifySafely();
  }

  /// Clears only the visible conversation/task. Persisted local memory runs
  /// and vault notes are intentionally retained.
  void clearConversation() {
    final status = _activeTask?.status;
    if (status == TaskStatus.running || status == TaskStatus.paused) return;
    _activeTask = null;
    _messages.clear();
    _cancelled = false;
    _paused = false;
    _notifySafely();
  }

  Future<void> executeTask(String query) => _runTask(query);

  /// Resumes the most recent paused checkpoint. Completed steps are preserved;
  /// only pending/paused/in-flight steps are executed again.
  Future<void> resumeTask() async {
    final task = _activeTask;
    if (task == null || task.status != TaskStatus.paused) return;
    await _runTask(task.userQuery, resumeFrom: task);
  }

  Future<void> _runTask(String query, {AgentTask? resumeFrom}) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    final oldStatus = _activeTask?.status;
    if (resumeFrom == null &&
        (oldStatus == TaskStatus.running || oldStatus == TaskStatus.paused)) return;
    final nucleusContext = NucleusService();
    _pendingUiIntent = await _resolveTrustedSchemaIntent(clean) ??
        _uiCoordinator.resolve(
          clean,
          currentSurahNumber: nucleusContext.currentSurahNumber,
          currentAyahNumber: nucleusContext.currentAyahNumber,
        );

    final generation = ++_executionGeneration;
    final nucleusAtStart = NucleusService();
    final contextSurahNumber = nucleusAtStart.currentSurahNumber;
    final contextAyahNumber = nucleusAtStart.currentAyahNumber;
    final contextVerseText = nucleusAtStart.currentVerseText;
    final hasContextAtStart = contextSurahNumber != null &&
        contextAyahNumber != null &&
        contextVerseText != null &&
        contextVerseText.trim().isNotEmpty;
    _activeTaskVerseSource = hasContextAtStart
        ? 'القرآن الكريم $contextSurahNumber:$contextAyahNumber'
        : null;
    _cancelled = false;
    _paused = false;
    _attemptsByAgent.clear();

    final agents = resumeFrom == null
        ? _route(clean)
        : resumeFrom.steps
            .map((step) => AgentRegistry.byId(step.agentName))
            .whereType<AgentDefinition>()
            .toList(growable: false);
    if (resumeFrom != null &&
        (agents.length != resumeFrom.steps.length || agents.isEmpty)) {
      _selectionError = 'تعذر استئناف المهمة: أحد الوكلاء المحفوظين لم يعد مسجلًا.';
      _notifySafely();
      return;
    }
    var task = resumeFrom ?? AgentTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userQuery: clean,
      createdAt: DateTime.now(),
      status: TaskStatus.running,
      steps: agents.asMap().entries
          .map((entry) => AgentStep(
                number: entry.key + 1,
                agentName: entry.value.id,
                title: entry.value.name,
                subtitle: entry.value.description,
              ))
          .toList(),
    );
    task = task.copyWith(status: TaskStatus.running);
    _setActiveTask(task);
    if (resumeFrom == null) {
      _messages.add('المستخدم: $clean');
    } else {
      _messages.add('استئناف المهمة المحفوظة: $clean');
    }
    _notifySafely();

    try {
      await initialize();
      if (!_initialized) {
        throw StateError(
          'تعذر تهيئة المعرفة المحلية: ${_initializationError ?? 'خطأ غير محدد'}',
        );
      }
      for (var i = 0; i < agents.length; i++) {
        // Keep completed checkpoint steps immutable during resume.
        if (task.steps[i].status == StepStatus.done) continue;
        if (_isCancelledFor(generation)) {
          _markCancelledIfCurrent(task);
          return;
        }
        while (_paused && !_isCancelledFor(generation)) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
        if (_isCancelledFor(generation)) {
          _markCancelledIfCurrent(task);
          return;
        }

        _currentStepNumber = i + 1;
        var step = task.steps[i].copyWith(
          status: StepStatus.running,
          startedAt: DateTime.now(),
        );
        task = task.copyWith(steps: _replaceStep(task.steps, i, step));
        _setActiveTask(task);
        _notifySafely();

        try {
          final result = await _executeWithRetries(agents[i], clean, generation: generation);
          step = step.copyWith(
            status: StepStatus.done,
            progress: 1,
            details: _detailsFor(agents[i], result),
            result: result,
            completedAt: DateTime.now(),
          );
          task = task.copyWith(steps: _replaceStep(task.steps, i, step));
          _setActiveTask(task);
          _notifySafely();
        } catch (error) {
          // The runtime may throw when stopGeneration interrupts native
          // inference. Preserve cancellation instead of marking this step as
          // failed and allowing retries or a false failure state.
          if (_isCancelledFor(generation)) {
            _markCancelledIfCurrent(task);
            return;
          }
          step = step.copyWith(
            status: StepStatus.failed,
            result: error.toString(),
            details: [
              StepDetail('المحاولات', '${_attemptsByAgent[agents[i].id] ?? 1} من 3'),
              const StepDetail('الحالة', 'فشل فعلي؛ لم تُستبدل النتيجة بمخرجات وهمية'),
            ],
            completedAt: DateTime.now(),
          );
          task = task.copyWith(
            status: TaskStatus.failed,
            steps: _replaceStep(task.steps, i, step),
            error: error.toString(),
          );
          _setActiveTask(task);
          _notifySafely();
          return;
        }
      }

      final answer = await _composeAnswer(
        task,
        contextSurahNumber: contextSurahNumber,
        contextAyahNumber: contextAyahNumber,
        contextVerseText: contextVerseText,
      );
      // Local GGUF generation can run while the final answer is composed.
      // If the user cancels during that phase, do not report a completed task
      // or persist a cancelled run as a successful answer.
      if (_isCancelledFor(generation)) {
        _markCancelledIfCurrent(task);
        return;
      }
      task = task.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
        finalAnswer: answer,
      );
      _setActiveTask(task);
      _messages.add('مُدَبِّر: $answer');
      try {
        await _memory.saveRun(
          query: clean,
          answer: answer,
          sources: _sourcesFromTask(task),
        );
      } catch (memoryError) {
        // A persistence failure must not rewrite a successfully completed
        // inference/retrieval task as failed. Surface the storage issue
        // separately while preserving the actual result and task status.
        _messages.add('تنبيه: اكتملت المهمة، لكن تعذر حفظ سجلها محليًا: $memoryError');
      }
      try {
        await AchievementsService.recordCompletedInsight();
      } catch (achievementError) {
        // Optional achievement bookkeeping must not turn a successful local
        // retrieval/inference run into a failed task.
        _messages.add('تنبيه: اكتملت المهمة، لكن تعذر تحديث سجل الإنجازات المحلي: $achievementError');
      }
      _notifySafely();
    } catch (error) {
      // Cancellation wins over an initialization/generation error. A native
      // stop can surface as an exception; it must not turn a cancelled task
      // into a failed one or append a misleading failure message.
      if (_isCancelledFor(generation)) {
        _markCancelledIfCurrent(task);
        return;
      }
      task = task.copyWith(status: TaskStatus.failed, error: error.toString());
      _setActiveTask(task);
      _messages.add('تعذر إكمال المهمة: $error');
      _notifySafely();
    }
  }

  void pauseOrResume() {
    final task = _activeTask;
    if (task == null ||
        (task.status != TaskStatus.running &&
            task.status != TaskStatus.paused)) {
      return;
    }
    // A restored checkpoint has paused task status but no live execution loop.
    // Route that case through the resumable runner instead of merely flipping
    // a boolean that no loop is waiting on.
    if (task.status == TaskStatus.paused && !_paused) {
      unawaited(resumeTask());
      return;
    }
    _paused = !_paused;
    // This cooperative pause takes effect at the next step boundary; an
    // already-running local lookup/inference is not falsely marked as stopped.
    _setActiveTask(task.copyWith(
      status: _paused ? TaskStatus.paused : TaskStatus.running,
    ));
    _notifySafely();
  }

  bool _isCancelledFor(int generation) =>
      _cancelled || generation != _executionGeneration;

  void _markCancelledIfCurrent(AgentTask task) {
    // An older async run must never overwrite the currently selected task.
    // Use the latest provider snapshot, not the caller's stale local copy, so
    // cancellation cannot discard completed steps or leave a running step
    // visually stuck after the task has already been cancelled.
    final current = _activeTask;
    if (current == null || current.id != task.id) return;
    final now = DateTime.now();
    final steps = current.steps.map((step) {
      if (step.status != StepStatus.pending &&
          step.status != StepStatus.running &&
          step.status != StepStatus.paused) {
        return step;
      }
      return step.copyWith(
        status: StepStatus.cancelled,
        completedAt: now,
      );
    }).toList(growable: false);
    _setActiveTask(current.copyWith(
      status: TaskStatus.cancelled,
      steps: steps,
      completedAt: now,
    ));
    _notifySafely();
  }

  void cancel() {
    final task = _activeTask;
    if (task == null ||
        (task.status != TaskStatus.running &&
            task.status != TaskStatus.paused)) {
      return;
    }
    _cancelled = true;
    _executionGeneration++;
    _paused = false;
    // Stop native generation too; otherwise the task would remain busy until
    // llama.cpp finishes even though the user explicitly cancelled it.
    if (NucleusService().isGenerating) {
      unawaited(NucleusService().stopGeneration().catchError((Object error) {
        debugPrint('AgentChatProvider: native generation stop failed: $error');
      }));
    }
    _markCancelledIfCurrent(task);
  }

  List<AgentStep> _replaceStep(List<AgentStep> steps, int index, AgentStep value) {
    final copy = List<AgentStep>.from(steps);
    copy[index] = value;
    return copy;
  }

  /// Parses only the numeric syntax; range validation happens against the
  /// canonical local Quran index so an invalid reference gets an explicit error.
  @visibleForTesting
  static ({int surah, int ayah})? parseVerseReference(String query) {
    // Arabic-Indic (٠١٢) and Eastern Arabic/Persian (۰۱۲) digits are common
    // in Arabic input; normalize only digits before strict syntax validation.
    final normalized = query.trim().replaceAllMapped(
      RegExp(r'[\u0660-\u0669\u06F0-\u06F9]'),
      (match) {
        final code = match.group(0)!.codeUnitAt(0);
        final digit = code >= 0x06F0 ? code - 0x06F0 : code - 0x0660;
        return String.fromCharCode(0x30 + digit);
      },
    );
    final match = RegExp(r'^([0-9]{1,3}) *[:/] *([0-9]{1,3})$')
        .firstMatch(normalized);
    if (match == null) return null;
    final surah = int.tryParse(match.group(1)!);
    final ayah = int.tryParse(match.group(2)!);
    if (surah == null || ayah == null) return null;
    return (surah: surah, ayah: ayah);
  }

  List<AgentDefinition> _route(String query) {
    final result = <AgentDefinition>[];
    void add(String id) {
      final agent = AgentRegistry.byId(id);
      if (agent != null && !result.any((existing) => existing.id == id)) {
        result.add(agent);
      }
    }

    // A bare verse reference is a lookup request, not a text-search query.
    // Keep this deterministic path independent of any selected general agent.
    if (parseVerseReference(query) != null) {
      add('ayaat');
      add('verifier');
      return result;
    }

    // An explicit agent selection is an execution constraint, not just an
    // extra entry in the default pipeline. Run the selected specialist between
    // the shared safety/planning stages and the critic/verifier stages.
    // This avoids silently running the full multi-agent pipeline when the
    // user deliberately chose one agent from the console.
    final selectedId = _selectedAgent;
    if (selectedId != null) {
      add('planner');
      add('safety');
      add(selectedId);
      add('critic');
      add('verifier');
      return result;
    }

    add('planner');
    add('safety');
    add('researcher');
    add('retriever');

    final normalized = AgentKnowledgeService.normalize(query);
    if (RegExp(r'ايه|قران|سوره|تفسير|معني|النور|الصمد|مسند|هيروغليف|عثمان').hasMatch(normalized)) {
      for (final id in ['ayaat', 'tafsir', 'siyaq']) {
        add(id);
      }
    }
    if (RegExp(r'جمل|ابجد').hasMatch(normalized)) add('jummal');
    if (RegExp(r'عدد|تكرار|مره|كم|احصاء|كلمه').hasMatch(normalized)) {
      add('adadi');
    }
    if (RegExp(r'ذاكره|سابق|تذكر|ملاحظه|دفتر|محفوظ|مخزن').hasMatch(normalized)) add('memory');
    add('overthinker');
    add('loop_engineering');
    add('critic');
    add('damj');
    add('verifier');
    add('obsidian');
    return result;
  }

  Future<String> _executeWithRetries(
    AgentDefinition agent,
    String query, {
    required int generation,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      if (_isCancelledFor(generation)) {
        throw StateError('أُلغي تنفيذ الوكيل ${agent.name}.');
      }
      _attemptsByAgent[agent.id] = attempt;
      try {
        final result = await _executeAgent(agent, query);
        if (_isCancelledFor(generation)) {
          throw StateError('أُلغي تنفيذ الوكيل ${agent.name}.');
        }
        return result;
      } catch (error) {
        if (_isCancelledFor(generation)) rethrow;
        lastError = error;
        if (attempt < 3) {
          await Future<void>.delayed(Duration(milliseconds: 150 * attempt));
        }
      }
    }
    throw StateError('الوكيل ${agent.name} فشل بعد 3 محاولات: $lastError');
  }

  Future<String> _executeAgent(AgentDefinition agent, String query) async {
    switch (agent.id) {
      case 'planner':
      case 'muwajjih':
        return _buildExecutionPlan(query);
      case 'safety':
        return 'فحص الأمان: البحث محلي وقراءة فقط؛ لا اتصال بخدمة بعيدة، '
            'ولا ادعاء بتشغيل نموذج توليدي أو أوامر نظام.';
      case 'researcher':
      case 'retriever':
      case 'tafsir':
      case 'rabet':
      case 'tibyan':
      case 'tadabbur':
      case 'asrar_maknuna':
      case 'khabir':
      case 'adham':
      case 'mutashabih':
      case 'overthinker':
      case 'critic':
      case 'narrator':
        return _searchKnowledge(agent, query);
      case 'ayaat':
        final reference = parseVerseReference(query);
        if (reference != null) {
          final surahNumber = reference.surah;
          final ayahNumber = reference.ayah;
          if (surahNumber < 1 || surahNumber > 114 || ayahNumber < 1) {
            return 'مرجع الآية خارج النطاق الصحيح؛ استخدم رقم السورة من 1 إلى 114 ورقم آية موجبًا.';
          }
          final grouped = await QuranLoaderService.loadBySurah();
          final candidates = grouped[surahNumber]
                  ?.where((ayah) => ayah.ayahNumber == ayahNumber)
                  .toList() ??
              const [];
          if (candidates.isEmpty) {
            return 'لم يُعثر على الآية ' + surahNumber.toString() + ':' +
                ayahNumber.toString() + ' في مصدر المصحف المحلي.';
          }
          final verse = candidates.first;
          return 'الآية ' + surahNumber.toString() + ':' +
              ayahNumber.toString() + ' (' + verse.surahName + '): ' +
              verse.text + ' — المصدر: assets/quran_full.json';
        }
        final hits = QuranicSearchEngine.search(query).take(8).toList();
        if (hits.isEmpty) {
          return 'لم يعثر البحث المحلي على شاهد قرآني مطابق؛ لا تُنشأ آية بديلة. '
            'يمكن متابعة الإجابة العامة عن السؤال دون نسبة نص إلى القرآن.';
        }
        return hits.map((v) =>
            '${v['surah']} ${v['ayah']}: ${v['text']} — المصدر: assets/quran_full.json').join('\n');
      case 'siyaq':
        final hits = QuranicSearchEngine.search(query).take(4).toList();
        if (hits.isEmpty) return 'لم يعثر البحث المحلي على موضع سياقي مطابق؛ هذا لا يمنع معالجة السؤال العام، '
            'ولا يجيز نسبة نص غير موثق إلى القرآن.';
        return hits.map((v) =>
            '${v['surah']} ${v['ayah']}: ${v['text']}').join('\n');
      case 'adadi':
        final normalizedQuery = QuranicSearchEngine.normalize(query);
        final frequencies = QuranicSearchEngine.getWordFrequency();
        const ignoredTerms = <String>{
          'كم', 'مره', 'عدد', 'تكرار', 'احصاء', 'احصائي', 'كلمه', 'كلمات',
          'القران', 'في', 'من', 'عن', 'هو', 'هي', 'ما', 'ورد', 'وردت',
          'مرات', 'احسب', 'احص', 'لي', 'هل', 'كل', 'الذي', 'التي',
        };
        final candidates = normalizedQuery
            .split(' ')
            .where((term) => term.length >= 2 && !ignoredTerms.contains(term))
            .toSet();
        final matched = candidates
            .where(frequencies.containsKey)
            .toList(growable: false);
        if (matched.isEmpty) {
          return 'لم أجد كلمة محددة قابلة للعدّ الحرفي في السؤال. '
              'حدّد الكلمة المطلوبة، مثل: كم مرة وردت كلمة الله في القرآن؟ '
              'لا يُقدَّم إجمالي كلمات المصحف من فهرس التكرار الجزئي.';
        }
        matched.sort((a, b) => a.compareTo(b));
        final lines = matched.map((word) =>
            '$word: ${frequencies[word]} تكرارًا في فهرس الكلمات المحلي');
        return 'إحصاء حرفي للكلمات المطابقة بعد تطبيع البحث العربي '
            '(إزالة التشكيل وتوحيد بعض صور الألف/الياء/التاء المربوطة):\n'
            '${lines.join('\n')}\n'
            'المصدر: فهرس الآيات المحلي المبني من assets/quran_full.json. '
            'هذا عدّ نصي وفق قواعد التطبيع المذكورة، وليس استنتاجًا تفسيريًا.';
      case 'jummal':
        return 'حساب أبجد للنص المدخل = ${_abjad(query)}. '
            'هذا حساب حرفي وفق جدول أبجد المضمّن، وليس استنتاجًا غيبيًا.';
      case 'loop_engineering':
        return 'سياسة هندسة الحلقة مفعّلة: حتى 3 محاولات لكل خطوة، '
            'مع تسجيل الخطأ النهائي وعدم اختلاق نتيجة بديلة. '
            'محاولات هذه الخطوة: ${_attemptsByAgent[agent.id] ?? 1}.';
      case 'memory':
        final notes = await _memory.searchVault(query, limit: 5);
        final runs = await _memory.recentRuns(limit: 5);
        if (notes.isEmpty && runs.isEmpty) {
          return 'لا توجد ملاحظات أو جلسات سابقة محفوظة محليًا بعد.';
        }
        final sections = <String>[];
        if (notes.isNotEmpty) {
          sections.add(
            'ملاحظات دفتر المعرفة المطابقة (محلية):\n' +
                notes.map((row) {
                  final title = (row['title'] ?? 'ملاحظة بلا عنوان').toString();
                  final content = (row['content'] ?? '').toString();
                  final sources = row['sources'] is List
                      ? (row['sources'] as List).whereType<String>().join(', ')
                      : '';
                  final createdAt = (row['createdAt'] ?? '').toString();
                  final snippet = content.length > 1200
                      ? '${content.substring(0, 1200)}…'
                      : content;
                  return 'العنوان: $title\nالتاريخ: $createdAt\nالمصادر: ${sources.isEmpty ? 'غير مسجلة' : sources}\n$snippet';
                }).join('\n\n'),
          );
        }
        if (runs.isNotEmpty) {
          sections.add(
            'جلسات التنفيذ الأخيرة:\n' +
                runs.map((row) =>
                    'سابقًا: ${row['query']}\nالملخص: ${row['answer']}').join('\n\n'),
          );
        }
        return sections.join('\n\n---\n\n');
      case 'obsidian':
        final evidence = _activeTask?.steps
                .where((step) => step.result != null && step.result!.trim().isNotEmpty)
                .map((step) => '${step.agentName}: ${step.result}')
                .join('\n\n') ??
            '';
        final note = await _memory.saveVaultNote(
          title: query,
          content: evidence.isEmpty ? 'لا توجد أدلة سابقة لإرفاقها.' : evidence,
          sources: _sourcesFromTask(_activeTask),
        );
        return 'دفتر المعرفة المحلي: تم الحفظ ثم القراءة للتحقق. '
            'نجاح الحفظ: ${note['saved']}؛ نجاح القراءة الراجعة: ${note['readBack']}؛ '
            'المعرّف: ${(note['note'] as Map)['id']}.';
      case 'damj':
        final previous = _activeTask?.steps
                .where((step) => step.result != null && step.result!.trim().isNotEmpty)
                .map((step) => step.result!)
                .toList() ??
            const <String>[];
        return previous.isEmpty
            ? 'لا توجد نتائج سابقة لدمجها.'
            : 'دمج ${previous.length} مخرجات فعلية للوكلاء. '
                'لم يُضف الدمج أدلة جديدة خارج النتائج السابقة.';
      case 'verifier':
      case 'ikhtibar':
        final prior = _activeTask?.steps
                .where((step) => step.number < (_currentStepNumber ?? 999) &&
                    step.status == StepStatus.done)
                .toList() ??
            const <AgentStep>[];
        final withResults = prior.where((step) => (step.result ?? '').trim().isNotEmpty).length;
        final sources = _sourcesFromSteps(prior);
        final verificationVerdict = sources.isEmpty
            ? 'الحكم: اكتمال شكلي فقط؛ لا توجد إحالات مصدرية يمكن تتبعها.'
            : 'الحكم: توجد إحالات مصدرية تحتاج مراجعة مقابل الأصول.';
        return 'التحقق المستقل: ${withResults} خطوة سابقة لديها مخرجات غير فارغة؛ '
            'المصادر المسجلة: ${sources.isEmpty ? 'لا توجد مصادر موثقة' : sources.join(', ')}. '
            '$verificationVerdict هذا فحص اكتمال ومصدر، وليس تصديقًا تلقائيًا على صحة الاستنتاج أو التفسير.';
      case 'tadrib':
        // The canonical Quran corpus is source material, not a user-labelled
        // supervised dataset. Never turn its metadata into training labels or
        // report a training run from the agent console.
        return 'لم يبدأ التدريب: لا يجوز تحويل نص المصحف تلقائيًا إلى بيانات تدريب مصنّفة. '
            'افتح شاشة التدريب واستورد ملف JSON يحتوي على عينات مُعنونة يدويًا '
            'بتصنيفات مدعومة ومتوازنة. التدريب المتاح يخص المصنّف المحلي الصغير فقط؛ '
            'ولا يدرّب أوزان Qwen أو GGUF.';
      case 'muraqib':
        final task = _activeTask;
        return 'مراقبة التنفيذ: الحالة=${task?.status.name ?? 'غير متاحة'}؛ '
            'الخطوات المكتملة=${task?.steps.where((s) => s.status == StepStatus.done).length ?? 0}.';
      default:
        return _searchKnowledge(agent, query);
    }
  }

  int? _currentStepNumber;

  /// Produces an honest, query-specific execution outline from the same
  /// deterministic routing rules used by the runner. This is a real plan of
  /// registered handlers, not a claim that the language model generated it.
  String _buildExecutionPlan(String query) {
    final routed = _route(query)
        .where((agent) =>
            agent.id != 'planner' &&
            agent.id != 'muwajjih' &&
            agent.id != 'safety')
        .toList(growable: false);
    if (routed.isEmpty) {
      return 'تعذر تكوين خطة قابلة للتنفيذ: لم يُنتج موجّه المهام أي معالج مسجل. '
          'لم يبدأ تنفيذ بديل غير موثق.';
    }

    final intent = parseVerseReference(query) != null
        ? 'استرجاع آية محددة والتحقق من مرجعها'
        : RegExp(r'جمل|ابجد').hasMatch(AgentKnowledgeService.normalize(query))
            ? 'حساب أبجد وفق الجدول المحلي ومراجعة النتيجة'
            : RegExp(r'عدد|تكرار|مره|احصاء|كلمه')
                    .hasMatch(AgentKnowledgeService.normalize(query))
                ? 'إجراء بحث أو إحصاء نصي من البيانات المحلية'
                : 'استرجاع أدلة محلية ومراجعة حدود الاستنتاج';
    final stages = routed.asMap().entries.map((entry) {
      final agent = entry.value;
      return '${entry.key + 1}. ${agent.name} (${agent.id}): ${agent.description}';
    }).join('\n');
    return 'خطة تنفيذ محلية مبنية على قواعد التوجيه الفعلية.\n'
        'الهدف المصنّف: $intent.\n'
        'المعالجات المسجلة التي سيحاول المسار تشغيلها:\n$stages\n'
        'مصدر الخطة: قواعد التوجيه المحلية وسجل الوكلاء؛ '
        'لم تُستخدم خدمة تخطيط بعيدة، ولا تعني الخطة أن الخطوات قد نُفّذت بعد.';
  }

  Future<String> _searchKnowledge(AgentDefinition agent, String query) async {
    final includeVariants = RegExp(r'مسند|هيروغليف|عثمان|خط|صيغة').hasMatch(query);
    final hits = await _knowledge.search(
      query,
      limit: agent.id == 'overthinker' || agent.id == 'critic' ? 4 : 6,
      includeScriptVariants: includeVariants,
    );
    if (hits.isEmpty) {
      if (agent.id == 'overthinker') {
        return 'مراجعة المخاطر: لم يظهر دليل مطابق في الأصول المفهرسة؛ '
            'يجب تضييق السؤال أو إضافة ملف معرفة مناسب. لا يمكن إثبات النتيجة من البيانات الحالية.';
      }
      if (agent.id == 'critic') {
        return 'المراجعة النقدية: لا توجد نتيجة مصدرية مطابقة يمكن تدقيقها؛ '
            'تُترك المسألة غير محسومة بدلًا من اختلاق معلومات.';
      }
      return 'لم يُعثر على مقاطع مطابقة في المعرفة المحلية لهذا الطلب. '
          'المصادر المفحوصة فعليًا: ${_knowledge.loadedSources.join(', ')}.';
    }
    final output = hits.map((doc) {
      final snippet = doc.content.length > 700 ? '${doc.content.substring(0, 700)}…' : doc.content;
      return 'المقطع: ${doc.title}\nالمصدر: ${doc.source}\n$snippet';
    }).join('\n\n');
    if (agent.id == 'overthinker') {
      return 'مراجعة متعمقة مبنية على ${hits.length} مقاطع محلية. '
          'تحقق من سياق كل مقطع؛ تطابق الكلمات وحده لا يثبت علاقة سببية أو تفسيرًا.\n\n$output';
    }
    if (agent.id == 'critic') {
      return 'مراجعة نقدية للأدلة: ${hits.length} مقاطع مسترجعة. '
          'قد يكون التطابق لفظيًا فقط؛ لم تُضف ادعاءات غير موجودة في المقاطع.\n\n$output';
    }
    return 'نتائج مسترجعة بواسطة ${agent.name} من الأصول المضمّنة:\n\n$output';
  }

  List<StepDetail> _detailsFor(AgentDefinition agent, String result) {
    const explicitHandlers = <String>{
      'muwajjih', 'planner', 'safety', 'researcher', 'retriever',
      'tafsir', 'rabet', 'tibyan', 'tadabbur', 'overthinker',
      'critic', 'narrator', 'ayaat', 'siyaq', 'jummal', 'adadi',
      'memory', 'loop_engineering', 'verifier', 'damj', 'obsidian',
    };
    return [
      StepDetail('الوكيل', agent.name),
      StepDetail('الطبقة', agent.layer),
      StepDetail(
        'مسار التنفيذ',
        explicitHandlers.contains(agent.id)
            ? 'معالج مسجل لهذا المعرّف'
            : 'استرجاع عام من المعرفة المحلية؛ لا توجد معالجة تخصصية مستقلة لهذا المعرّف بعد',
      ),
      StepDetail('المحاولات', '${_attemptsByAgent[agent.id] ?? 1} من 3'),
      StepDetail('الأصول المحمّلة', _knowledge.loadedSources.length.toString()),
      StepDetail('المصادر', _sourcesFromText(result).join(', ').isEmpty
          ? 'لا يوجد مصدر مذكور في هذه النتيجة'
          : _sourcesFromText(result).join(', ')),
    ];
  }

  Future<String> _composeAnswer(
    AgentTask task, {
    required int? contextSurahNumber,
    required int? contextAyahNumber,
    required String? contextVerseText,
  }) async {
    final results = task.steps
        .where((step) => step.result != null && step.result!.trim().isNotEmpty)
        .map((step) => '${step.title}:\n${step.result}')
        .toList();
    if (results.isEmpty) {
      return 'اكتمل المسار دون نتائج؛ لم يتم اختلاق إجابة.';
    }

    final evidence = results.join('\n\n');
    final hasVerseContext = contextVerseText != null &&
        contextVerseText.trim().isNotEmpty &&
        contextSurahNumber != null &&
        contextAyahNumber != null;
    final verseSource = hasVerseContext
        ? 'القرآن الكريم $contextSurahNumber:$contextAyahNumber'
        : null;
    final contextualEvidence = !hasVerseContext
        ? evidence
        : evidence + '\n\nالسياق المحدد في المصحف (' +
            contextSurahNumber.toString() + ':' +
            contextAyahNumber.toString() + '):\n' + contextVerseText!;
    final sourceList = <String>{
      ..._knowledge.loadedSources,
      if (verseSource != null) verseSource,
    }.join(', ');
    final runtime = NucleusService();
    if (runtime.isModelLoaded) {
      try {
        final boundedEvidence = contextualEvidence.length > 12000
            ? '${contextualEvidence.substring(0, 12000)}\n[تم اقتطاع بقية الأدلة لتحديد طول السياق]'
            : contextualEvidence;
        final generated = await runtime.generateGroundedAnswer(
          question: task.userQuery,
          evidence: boundedEvidence,
          maxTokens: 512,
        );
        return 'إجابة مولّدة محليًا بواسطة نموذج GGUF المحمّل (ليست نصًا قرآنيًا):\n'
            '$generated\n\n'
            'الأدلة والسياق المحلي المحدد، للرجوع والتحقق:\n$contextualEvidence\n\n'
            'المصادر المحمّلة: $sourceList. يجب التحقق من أي استنتاج مولّد مقابل النصوص المصدرية.';
      } catch (error) {
        return 'تعذر الاستدلال بالنموذج المحلي؛ لم أستبدل ذلك بإجابة مولّدة وهمية.\n\n'
            'تقرير الأدلة والسياق المحلي:\n$contextualEvidence\n\n'
            'سبب تعذر النموذج: $error\nالمصادر: $sourceList.';
      }
    }

    return 'تقرير الوكلاء المحلي:\n\n$contextualEvidence\n\n'
        'المصادر المحمّلة: $sourceList. '
        'هذه نتائج استرجاع وفحوص محلية؛ لم يُشغّل نموذج توليدي لأن GGUF غير محمّل.';
  }

  List<String> _sourcesFromText(String text) {
    final known = _knowledge.loadedSources.toList();
    return known.where(text.contains).toList(growable: false);
  }

  List<String> _sourcesFromSteps(List<AgentStep>? steps) {
    if (steps == null) return const [];
    final sources = <String>{};
    for (final step in steps) {
      if (step.result != null) sources.addAll(_sourcesFromText(step.result!));
    }
    return sources.toList(growable: false);
  }

  List<String> _sourcesFromTask(AgentTask? task) {
    if (task == null) return const <String>[];
    final sources = _sourcesFromSteps(task.steps).toSet();
    final verseSource = _activeTaskVerseSource;
    if (verseSource != null) sources.add(verseSource);
    return sources.toList(growable: false);
  }

  int _abjad(String text) {
    var total = 0;
    for (final rune in text.runes) {
      total += AbjadConstants.getValue(String.fromCharCode(rune));
    }
    return total;
  }

  String exportJson() {
    final task = _activeTask;
    if (task == null) return '{}';
    return const JsonEncoder.withIndent('  ').convert({
      'id': task.id,
      'query': task.userQuery,
      'status': task.status.name,
      'progress': task.progress,
      'sources': _sourcesFromTask(task),
      'steps': task.steps
          .map((step) => {
                'agent': step.agentName,
                'title': step.title,
                'status': step.status.name,
                'attempts': _attemptsByAgent[step.agentName] ?? 0,
                'result': step.result,
                'details': step.details.map((d) => {'label': d.label, 'value': d.value}).toList(),
              })
          .toList(),
      'answer': task.finalAnswer,
    });
  }
}
