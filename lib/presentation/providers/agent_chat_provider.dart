import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/agent_task.dart';
import '../../services/agent_knowledge_service.dart';
import '../../services/nucleus_service.dart';
import '../../services/agent_memory_service.dart';
import '../../services/agent_registry.dart';
import '../../services/quran_loader_service.dart';
import '../../services/quranic_search_engine.dart';

/// Zion-style multi-agent runtime for مُدَبِّر.
/// Agents execute local tools and cite bundled sources; no remote model or
/// simulated shell execution is presented as real inference.
class AgentChatProvider extends ChangeNotifier {
  final AgentKnowledgeService _knowledge = AgentKnowledgeService.instance;
  final AgentMemoryService _memory = AgentMemoryService.instance;

  AgentTask? _activeTask;
  final List<String> _messages = [];
  final Map<String, int> _attemptsByAgent = {};
  bool _paused = false;
  bool _cancelled = false;
  int _executionGeneration = 0;
  bool _initialized = false;
  String? _selectedAgent;

  AgentTask? get activeTask => _activeTask;
  List<String> get messages => List.unmodifiable(_messages);
  bool get paused => _paused;
  String? get selectedAgent => _selectedAgent;
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
    _initialized = true;
    _initializing = null;
    notifyListeners();
  }

  void selectAgent(String? id) {
    _selectedAgent = id;
    notifyListeners();
  }

  Future<void> executeTask(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    final oldStatus = _activeTask?.status;
    if (oldStatus == TaskStatus.running || oldStatus == TaskStatus.paused) return;

    final generation = ++_executionGeneration;
    _cancelled = false;
    _paused = false;
    _attemptsByAgent.clear();

    final agents = _route(clean);
    var task = AgentTask(
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
    _activeTask = task;
    _messages.add('المستخدم: $clean');
    notifyListeners();

    try {
      await initialize();
      for (var i = 0; i < agents.length; i++) {
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
        _activeTask = task;
        notifyListeners();

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
          _activeTask = task;
          notifyListeners();
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
          _activeTask = task;
          notifyListeners();
          return;
        }
      }

      final answer = await _composeAnswer(task);
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
      _activeTask = task;
      _messages.add('مُدَبِّر: $answer');
      await _memory.saveRun(
        query: clean,
        answer: answer,
        sources: _sourcesFromTask(task),
      );
      notifyListeners();
    } catch (error) {
      // Cancellation wins over an initialization/generation error. A native
      // stop can surface as an exception; it must not turn a cancelled task
      // into a failed one or append a misleading failure message.
      if (_isCancelledFor(generation)) {
        _markCancelledIfCurrent(task);
        return;
      }
      task = task.copyWith(status: TaskStatus.failed, error: error.toString());
      _activeTask = task;
      _messages.add('تعذر إكمال المهمة: $error');
      notifyListeners();
    }
  }

  void pauseOrResume() {
    final task = _activeTask;
    if (task == null ||
        (task.status != TaskStatus.running &&
            task.status != TaskStatus.paused)) {
      return;
    }
    _paused = !_paused;
    _activeTask = task.copyWith(
      status: _paused ? TaskStatus.paused : TaskStatus.running,
    );
    notifyListeners();
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
      if (step.status != StepStatus.running &&
          step.status != StepStatus.paused) {
        return step;
      }
      return step.copyWith(
        status: StepStatus.cancelled,
        completedAt: now,
      );
    }).toList(growable: false);
    _activeTask = current.copyWith(
      status: TaskStatus.cancelled,
      steps: steps,
      completedAt: now,
    );
    notifyListeners();
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
      unawaited(NucleusService().stopGeneration());
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
    if (RegExp(r'ذاكرة|سابق|تذكر|ملاحظة|دفتر').hasMatch(normalized)) add('memory');
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
        return 'الخطة: (1) تحديد النطاق، (2) استرجاع أدلة من assets، '
            '(3) فحص النواقص والتناقضات، (4) التحقق من المصادر، (5) حفظ ملخص محلي. '
            'لا تُنفّذ أدوات خارجية غير متاحة.';
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
        final runs = await _memory.recentRuns(limit: 5);
        if (runs.isEmpty) return 'لا توجد جلسات سابقة محفوظة محليًا بعد.';
        return runs.map((row) =>
            'سابقًا: ${row['query']}\nالملخص: ${row['answer']}').join('\n\n');
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
        return 'التحقق المستقل: ${withResults} خطوة سابقة لديها مخرجات غير فارغة؛ '
            'المصادر المسجلة: ${sources.isEmpty ? 'لا توجد مصادر موثقة' : sources.join(', ')}. '
            'هذا فحص اكتمال/مصدر، وليس حكمًا بصحة التفسير.';
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

  List<StepDetail> _detailsFor(AgentDefinition agent, String result) => [
        StepDetail('الوكيل', agent.name),
        StepDetail('الطبقة', agent.layer),
        StepDetail('المحاولات', '${_attemptsByAgent[agent.id] ?? 1} من 3'),
        StepDetail('الأصول المحمّلة', _knowledge.loadedSources.length.toString()),
        StepDetail('المصادر', _sourcesFromText(result).join(', ').isEmpty
            ? 'لا يوجد مصدر مذكور في هذه النتيجة'
            : _sourcesFromText(result).join(', ')),
      ];

  Future<String> _composeAnswer(AgentTask task) async {
    final results = task.steps
        .where((step) => step.result != null && step.result!.trim().isNotEmpty)
        .map((step) => '${step.title}:\n${step.result}')
        .toList();
    if (results.isEmpty) {
      return 'اكتمل المسار دون نتائج؛ لم يتم اختلاق إجابة.';
    }

    final evidence = results.join('\n\n');
    final nucleus = NucleusService();
    final verseContext = nucleus.currentVerseText;
    final contextualEvidence = verseContext == null || verseContext.trim().isEmpty
        ? evidence
        : evidence + '\n\nالسياق المحدد في المصحف (' +
            nucleus.currentSurahNumber.toString() + ':' +
            nucleus.currentAyahNumber.toString() + '):\n' + verseContext;
    final sourceList = _knowledge.loadedSources.join(', ');
    final runtime = nucleus;
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
            'الأدلة المسترجعة من التطبيق، للرجوع والتحقق:\n$evidence\n\n'
            'المصادر المحمّلة: $sourceList. يجب التحقق من أي استنتاج مولّد مقابل النصوص المصدرية.';
      } catch (error) {
        return 'تعذر الاستدلال بالنموذج المحلي؛ لم أستبدل ذلك بإجابة مولّدة وهمية.\n\n'
            'تقرير الأدلة المحلية:\n$evidence\n\n'
            'سبب تعذر النموذج: $error\nالمصادر: $sourceList.';
      }
    }

    return 'تقرير الوكلاء المحلي:\n\n$evidence\n\n'
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

  List<String> _sourcesFromTask(AgentTask? task) =>
      _sourcesFromSteps(task?.steps);

  int _abjad(String text) {
    const values = {
      'ا': 1, 'أ': 1, 'إ': 1, 'آ': 1, 'ب': 2, 'ج': 3, 'د': 4,
      'ه': 5, 'ة': 5, 'و': 6, 'ز': 7, 'ح': 8, 'ط': 9, 'ي': 10,
      'ى': 10, 'ك': 20, 'ل': 30, 'م': 40, 'ن': 50, 'س': 60,
      'ع': 70, 'ف': 80, 'ص': 90, 'ق': 100, 'ر': 200, 'ش': 300,
      'ت': 400, 'ث': 500, 'خ': 600, 'ذ': 700, 'ض': 800, 'ظ': 900,
      'غ': 1000,
    };
    var total = 0;
    for (final rune in text.runes) {
      total += values[String.fromCharCode(rune)] ?? 0;
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
