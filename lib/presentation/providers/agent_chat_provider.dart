import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../domain/entities/agent_task.dart';
import '../../services/agent_knowledge_service.dart';
import '../../services/local_gguf_runtime_service.dart';
import '../../services/agent_memory_service.dart';
import '../../services/agent_registry.dart';
import '../../services/on_device_training_service.dart';
import '../../services/quran_loader_service.dart';
import '../../services/quranic_search_engine.dart';

/// Zion-style multi-agent runtime for مُدَبِّر.
/// Agents execute local tools and cite bundled sources; no remote model or
/// simulated shell execution is presented as real inference.
class AgentChatProvider extends ChangeNotifier {
  final OnDeviceTrainingService _training = OnDeviceTrainingService();
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
    final ayahs = await QuranLoaderService.loadAllAyahs();
    QuranicSearchEngine.indexVerses(ayahs
        .map((a) => {
              'id': a.id.toString(),
              'surah': a.surahName,
              'ayah': a.ayahNumber.toString(),
              'text': a.text,
            })
        .toList());
    await _knowledge.initialize();
    _initialized = true;
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
    if (_activeTask == null) return;
    _paused = !_paused;
    _activeTask = _activeTask!.copyWith(
      status: _paused ? TaskStatus.paused : TaskStatus.running,
    );
    notifyListeners();
  }

  bool _isCancelledFor(int generation) =>
      _cancelled || generation != _executionGeneration;

  void _markCancelledIfCurrent(AgentTask task) {
    // An older async run must never overwrite the currently selected task.
    if (_activeTask?.id != task.id) return;
    _activeTask = task.copyWith(status: TaskStatus.cancelled);
    notifyListeners();
  }

  void cancel() {
    _cancelled = true;
    _executionGeneration++;
    _paused = false;
    // Stop native generation too; otherwise the task would remain busy until
    // llama.cpp finishes even though the user explicitly cancelled it.
    if (LocalGgufRuntimeService.instance.isGenerating) {
      unawaited(LocalGgufRuntimeService.instance.stopGeneration());
    }
    if (_activeTask != null) {
      _activeTask = _activeTask!.copyWith(status: TaskStatus.cancelled);
      notifyListeners();
    }
  }

  List<AgentStep> _replaceStep(List<AgentStep> steps, int index, AgentStep value) {
    final copy = List<AgentStep>.from(steps);
    copy[index] = value;
    return copy;
  }

  List<AgentDefinition> _route(String query) {
    final result = <AgentDefinition>[];
    void add(String id) {
      final agent = AgentRegistry.byId(id);
      if (agent != null && !result.any((existing) => existing.id == id)) {
        result.add(agent);
      }
    }

    add('planner');
    add('safety');
    add('researcher');
    add('retriever');

    if (_selectedAgent != null) add(_selectedAgent!);
    final normalized = AgentKnowledgeService.normalize(query);
    if (RegExp(r'ايه|قران|سوره|تفسير|معني|النور|الصمد|مسند|هيروغليف|عثمان').hasMatch(normalized)) {
      for (final id in ['ayaat', 'tafsir', 'siyaq']) {
        add(id);
      }
    }
    if (RegExp(r'جمل|عدد|حساب|قيمه').hasMatch(normalized)) add('jummal');
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
        final hits = QuranicSearchEngine.search(query).take(8).toList();
        if (hits.isEmpty) {
          return 'لم يُعثر على تطابق نصي في فهرس القرآن المحلي؛ لم يتم إنشاء آية بديلة.';
        }
        return hits.map((v) =>
            '${v['surah']} ${v['ayah']}: ${v['text']} — المصدر: assets/quran_full.json').join('\n');
      case 'siyaq':
        final hits = QuranicSearchEngine.search(query).take(4).toList();
        if (hits.isEmpty) return 'لم يُعثر على موضع سياقي مطابق في فهرس القرآن المحلي.';
        return hits.map((v) =>
            '${v['surah']} ${v['ayah']}: ${v['text']}').join('\n');
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
        final ayahs = await QuranLoaderService.loadAllAyahs();
        await _training.startTraining(
          verses: ayahs.map((a) => {'text': a.text, 'axis_type': a.axisType}).toList(),
          epochs: 1,
        );
        final trainingStatus = _training.status;
        if (trainingStatus.startsWith('فشل') ||
            trainingStatus.startsWith('تعذر') ||
            trainingStatus.startsWith('أُلغي')) {
          return 'لم يكتمل التدريب. الحالة الفعلية: $trainingStatus';
        }
        return 'حالة التدريب المحلي: $trainingStatus '
            '(العينات المتاحة: ${ayahs.length}). هذا مصنف صغير منفصل؛ '
            'لا يُعد نموذجًا لغويًا توليديًا ولم تتغير أوزان Qwen/GGUF.';
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
    final sourceList = _knowledge.loadedSources.join(', ');
    final runtime = LocalGgufRuntimeService.instance;
    if (runtime.isLoaded) {
      try {
        final boundedEvidence = evidence.length > 12000
            ? '${evidence.substring(0, 12000)}\n[تم اقتطاع بقية الأدلة لتحديد طول السياق]'
            : evidence;
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
