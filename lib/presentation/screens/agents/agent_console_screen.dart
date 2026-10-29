import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/agent_task.dart';
import '../../../services/agent_registry.dart';
import '../../../services/agent_knowledge_service.dart';
import '../../../services/nucleus_service.dart';
import '../../providers/agent_chat_provider.dart';
import '../../../services/external_asset_service.dart';
import '../nucleus_screen.dart';
import '../miracles_screen.dart';
import '../compare_screen.dart';
import '../quran_page_screen.dart';

class AgentConsoleScreen extends StatelessWidget {
  const AgentConsoleScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => AgentChatProvider()..initialize(),
        child: const _AgentConsoleView(),
      );
}

class _AgentConsoleView extends StatefulWidget {
  const _AgentConsoleView();

  @override
  State<_AgentConsoleView> createState() => _AgentConsoleViewState();
}

class _AgentConsoleViewState extends State<_AgentConsoleView> {
  final _controller = TextEditingController();
  final _agentSearchController = TextEditingController();
  final NucleusService _nucleus = NucleusService();
  late bool _modelLoaded;
  String _agentQuery = '';
  String _layer = 'الكل';
  String? _scheduledUiIntentId;

  @override
  void initState() {
    super.initState();
    _modelLoaded = _nucleus.isModelLoaded;
    _nucleus.addListener(_onNucleusChanged);
  }

  void _onNucleusChanged() {
    final loaded = _nucleus.isModelLoaded;
    if (mounted && loaded != _modelLoaded) {
      setState(() => _modelLoaded = loaded);
    }
  }

  void _scheduleAdaptiveNavigation(AgentChatProvider provider) {
    final intent = provider.pendingUiIntent;
    if (intent == null || intent.id == _scheduledUiIntentId) return;
    _scheduledUiIntentId = intent.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      provider.consumeUiIntent(intent.id);
      const allowedTemplates = <String, String>{
        'miracles_screen': 'analytics_template',
        'compare_screen': 'comparison_template',
        'nucleus_screen': 'graph_template',
        'quran_page_screen': 'reader_template',
      };
      if (allowedTemplates[intent.targetScreen] != intent.templateId) {
        return;
      }
      final Map<String, dynamic> payload = intent.payload;
      final Widget? destination;
      switch (intent.targetScreen) {
        case 'miracles_screen':
          destination = MiraclesScreen(
            initialQuery: payload['first_word']?.toString(),
            initialComparisonQuery: payload['second_word']?.toString(),
          );
          break;
        case 'compare_screen':
          destination = CompareScreen(
            agentQuery: payload['comparison_query']?.toString(),
          );
          break;
        case 'nucleus_screen':
          destination = const NucleusScreen();
          break;
        case 'quran_page_screen':
          final surah = (payload['surah_number'] as num?)?.toInt() ?? 1;
          destination = QuranPageScreen(
            surahNumber: surah,
            surahName: surah == 1 ? 'الفاتحة' : 'السورة $surah',
            initialAyahNumber: (payload['ayah_number'] as num?)?.toInt() ?? 1,
          );
          break;
        default:
          destination = null;
      }
      if (destination == null) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: RouteSettings(
            name: '/agent-adaptive/${intent.targetScreen}',
            arguments: intent.toJson(),
          ),
          builder: (_) => destination!,
        ),
      );
    });
  }

  Future<void> _importOptionalAssets() async {
    try {
      final imported = await ExternalAssetService.instance.pickAndImportOptionalAssets();
      if (!mounted || imported.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم استيراد ${imported.length} ملفًا اختياريًا إلى مساحة التطبيق.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر استيراد الأصول: $error')),
      );
    }
  }

  @override
  void dispose() {
    _nucleus.removeListener(_onNucleusChanged);
    _controller.dispose();
    _agentSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgentChatProvider>();
    final task = provider.activeTask;
    _scheduleAdaptiveNavigation(provider);
    final layers = <String>{'الكل', ...AgentRegistry.all.map((a) => a.layer)};
    final normalizedAgentQuery = AgentKnowledgeService.normalize(_agentQuery);
    final agents = AgentRegistry.all.where((agent) {
      final matchesLayer = _layer == 'الكل' || agent.layer == _layer;
      final searchable = AgentKnowledgeService.normalize(
        '${agent.name} ${agent.id} ${agent.layer} ${agent.description}',
      );
      return matchesLayer &&
          (normalizedAgentQuery.isEmpty ||
              searchable.contains(normalizedAgentQuery));
    }).toList(growable: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مُدَبِّر', style: TextStyle(fontWeight: FontWeight.w800)),
              Text('مساحة الوكلاء الفائقين',
                  style: TextStyle(fontSize: 11, color: Colors.white60)),
            ],
          ),
          actions: [
            if (task != null)
              IconButton(
                tooltip: 'نسخ تقرير المهمة بصيغة JSON',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: provider.exportJson()));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ تقرير المهمة JSON إلى الحافظة.')),
                  );
                },
                icon: const Icon(Icons.data_object_rounded),
              ),
            IconButton(
              tooltip: 'مسح المحادثة الحالية',
              onPressed: task == null ||
                      task.status == TaskStatus.running ||
                      task.status == TaskStatus.paused
                  ? null
                  : () async {
                      final clear = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('مسح المحادثة الحالية؟'),
                          content: const Text(
                            'سيُمسح سجل العرض والمهمة الحالية فقط. '
                            'ستبقى جلسات الذاكرة والملاحظات المحفوظة محليًا دون تغيير.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('إلغاء'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: const Text('مسح'),
                            ),
                          ],
                        ),
                      );
                      if (clear == true && context.mounted) {
                        provider.clearConversation();
                      }
                    },
              icon: const Icon(Icons.cleaning_services_outlined),
            ),
            IconButton(
              tooltip: 'استيراد أصول OCR / ML Kit والنماذج المحلية',
              onPressed: _importOptionalAssets,
              icon: const Icon(Icons.folder_open_outlined),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: Center(
                child: Text('${AgentRegistry.all.length} تعريف وكيل',
                    style: const TextStyle(color: AppColors.primaryGold)),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _WorkspaceHero(
                documentCount: provider.indexedDocumentCount,
                sourceCount: provider.loadedKnowledgeSources.length,
                initialized: provider.initialized,
                initializationError: provider.initializationError,
                modelLoaded: _modelLoaded,
                onRetry: provider.initialize,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: TextField(
                  controller: _agentSearchController,
                  textDirection: TextDirection.rtl,
                  onChanged: (value) => setState(() => _agentQuery = value),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن وكيل بالاسم أو المعرّف أو الوصف',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                    prefixIcon: const Icon(Icons.search_rounded, size: 19,
                        color: AppColors.primaryGold),
                    suffixIcon: _agentQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'مسح بحث الوكلاء',
                            onPressed: () {
                              _agentSearchController.clear();
                              setState(() => _agentQuery = '');
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                    filled: true,
                    fillColor: AppColors.surface,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: Text(
                          '${agents.length} نتيجة',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => setState(() => _layer = value),
                      itemBuilder: (_) => layers
                          .map((value) => PopupMenuItem(
                              value: value,
                              child: Text(value == 'الكل' ? 'كل المجالات' : value)))
                          .toList(),
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(.12),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.primaryGold.withOpacity(.4)),
                        ),
                        child: Row(children: const [
                          Icon(Icons.tune_rounded, size: 16, color: AppColors.primaryGold),
                          SizedBox(width: 5),
                          Text('المجالات', style: TextStyle(color: AppColors.primaryGold, fontSize: 12)),
                          Icon(Icons.expand_more, size: 16, color: AppColors.primaryGold),
                        ]),
                      ),
                    ),
                    ...agents.map((agent) {
                      final selected = provider.selectedAgent == agent.id;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 7),
                        child: ChoiceChip(
                          label: Text(agent.name),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: (_) => provider.selectAgent(selected ? null : agent.id),
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: selected ? AppColors.primaryNavy : Colors.white,
                            fontSize: 12,
                          ),
                          side: BorderSide(color: selected ? AppColors.primaryGold : Colors.white12),
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Text(
                  'الأسماء المعروضة تعريفات مسجلة في الدليل؛ ظهور الاسم لا يعني أن لكل وكيل نموذجًا مستقلًا أو خدمة منفصلة. التنفيذ يعتمد على الأدوات والمصادر المحلية المتاحة وحالة النموذج.',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.58),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
              if (provider.selectionError != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(.35)),
                    ),
                    child: Text(
                      provider.selectionError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                ),
              if (task == null)
                _QuickPrompts(onChoose: (value) {
                  _controller.text = value;
                  _controller.selection = TextSelection.collapsed(offset: value.length);
                }),
              const _LocalModelPanel(),
              if (task != null) _TaskProgress(task: task, provider: provider),
              Expanded(
                child: _Transcript(
                  task: task,
                  messages: provider.messages,
                  loadingKnowledge: !provider.initialized &&
                      provider.initializationError == null,
                ),
              ),
              _Composer(
                controller: _controller,
                running: task?.status == TaskStatus.running || task?.status == TaskStatus.paused,
                onSend: () {
                  final query = _controller.text.trim();
                  if (query.isEmpty) return;
                  _controller.clear();
                  FocusScope.of(context).unfocus();
                  provider.executeTask(query);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceHero extends StatelessWidget {
  final int documentCount;
  final int sourceCount;
  final bool initialized;
  final String? initializationError;
  final bool modelLoaded;
  final VoidCallback onRetry;
  const _WorkspaceHero({
    required this.documentCount,
    required this.sourceCount,
    required this.initialized,
    required this.initializationError,
    required this.modelLoaded,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(14, 12, 14, 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGold.withOpacity(.25)),
        ),
        child: Row(children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.hub_rounded, color: AppColors.primaryGold, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('مركز التفكير والتنفيذ',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                initializationError != null
                    ? 'تعذر تهيئة المعرفة المحلية'
                    : initialized
                        ? modelLoaded
                            ? 'نموذج GGUF محلي محمّل • التوليد المحلي مهيأ'
                            : 'فهرس المعرفة المحلي جاهز • حمّل نموذجًا من شاشة النواة للتوليد'
                        : 'تهيئة فهرس المعرفة المحلي…',
                style: TextStyle(
                  color: initializationError != null
                      ? Colors.redAccent
                      : Colors.white70,
                  fontSize: 11,
                ),
              ),
              if (initialized && !modelLoaded && initializationError == null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NucleusScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.memory_rounded, size: 16),
                    label: const Text('فتح النواة وتحميل نموذج محلي'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                ),
              if (initializationError != null) ...[
                const SizedBox(height: 4),
                Text(
                  initializationError!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 10),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('إعادة تهيئة المعرفة'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryGold,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                _Metric(icon: Icons.groups_2_outlined, text: '${AgentRegistry.all.length} وكيل'),
                _Metric(icon: Icons.library_books_outlined, text: '$documentCount مقطع'),
                _Metric(icon: Icons.folder_outlined, text: '$sourceCount مصدر'),
              ]),
            ]),
          ),
        ]),
      );
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Metric({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: AppColors.primaryGold),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ]),
      );
}

class _QuickPrompts extends StatelessWidget {
  final ValueChanged<String> onChoose;
  const _QuickPrompts({required this.onChoose});
  static const items = [
    ('بحث قرآني', 'ابحث في القرآن عن آيات تتعلق بـ '),
    ('إحصاء كلمة', 'كم مرة وردت كلمة الله في القرآن؟'),
    ('تحليل عميق', 'حلّل هذا الموضوع من المصادر المحلية: '),
    ('تدقيق الأدلة', 'استخرج الأدلة والمصادر وحدد ما لم يثبت: '),
  ];
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 47,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          children: items.map((item) => Padding(
            padding: const EdgeInsetsDirectional.only(end: 7),
            child: ActionChip(
              avatar: const Icon(Icons.bolt_rounded, size: 15, color: AppColors.primaryGold),
              label: Text(item.$1),
              onPressed: () => onChoose(item.$2),
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: Colors.white12),
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
              visualDensity: VisualDensity.compact,
            ),
          )).toList(),
        ),
      );
}

class _LocalModelPanel extends StatefulWidget {
  const _LocalModelPanel();
  @override
  State<_LocalModelPanel> createState() => _LocalModelPanelState();
}

class _LocalModelPanelState extends State<_LocalModelPanel> {
  final _runtime = NucleusService();
  bool _hasModel = false;
  bool _working = false;
  @override
  void initState() {
    super.initState();
    _runtime.addListener(_refresh);
    _checkModel();
  }

  @override
  void dispose() {
    _runtime.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() { if (mounted) setState(() {}); }

  Future<void> _checkModel() async {
    final valid = await _runtime.hasValidModel();
    if (mounted) setState(() => _hasModel = valid);
  }

  Future<void> _importModel() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['gguf'],
        allowMultiple: false,
        withData: false,
      );
      if (!mounted || picked == null || picked.files.isEmpty) return;

      final path = picked.files.first.path;
      if (path == null || path.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر الوصول إلى الملف المحدد. اختر ملف GGUF من مدير الملفات في الهاتف.'),
          ),
        );
        return;
      }

      await _run(() async {
        await _runtime.importModel(path);
        await _checkModel();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر اختيار ملف النموذج من ذاكرة الهاتف: $error')),
      );
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await action();
    } catch (error) {
      final cancelled = _runtime.modelStatus.contains('أُلغي');
      if (mounted && !cancelled) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذرت العملية: $error')),
      );
    } finally {
      if (mounted) setState(() => _working = false);
      await _checkModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _working || _runtime.isBusy || _runtime.isGenerating;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _runtime.isModelLoaded ? Colors.green.withOpacity(.12) : AppColors.primaryGold.withOpacity(.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.memory_rounded, color: _runtime.isModelLoaded ? Colors.greenAccent : AppColors.primaryGold),
          ),
          title: const Text('النموذج المحلي GGUF',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(
            _runtime.isModelLoaded ? 'محمّل • الاستدلال محلي' : _hasModel ? 'ملف مستورد • لم يُختبر بعد في محرك الاستدلال' : 'لا يوجد نموذج • استورد ملف GGUF محليًا',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          children: [
            Align(alignment: Alignment.centerRight, child: Text(_runtime.modelStatus,
                style: const TextStyle(color: Colors.white70, fontSize: 11))),
            const SizedBox(height: 9),
            Wrap(spacing: 7, runSpacing: 7, children: [
              OutlinedButton.icon(
                onPressed: busy || _runtime.isModelLoaded ? null : _importModel,
                icon: const Icon(Icons.file_open_rounded, size: 17),
                label: const Text('استيراد من ذاكرة الهاتف'),
              ),
              FilledButton.icon(
                onPressed: busy ? null : _runtime.isModelLoaded
                    ? () => _run(_runtime.unloadModel)
                    : _hasModel ? () => _run(_runtime.loadModel) : null,
                icon: Icon(_runtime.isModelLoaded ? Icons.stop_circle_outlined : Icons.play_arrow_rounded),
                label: Text(_runtime.isModelLoaded ? 'إيقاف النموذج' : 'تحميل النموذج'),
              ),
              if (_runtime.isGenerating)
                OutlinedButton.icon(
                  onPressed: _working ? null : () => _run(_runtime.stopGeneration),
                  icon: const Icon(Icons.stop_rounded, size: 17),
                  label: const Text('إيقاف التوليد'),
                ),
            ]),
            const SizedBox(height: 6),
            const Text(
              'يدعم التطبيق استيراد ملفات .gguf الموجودة على الهاتف فقط، ولا ينزّل النماذج من الإنترنت. يُنسخ الملف إلى مساحة التطبيق الخاصة ويُفحص قبل التشغيل؛ لا يبدأ الاستدلال حتى ينجح تحميله في llama.cpp، ويلزم توفر مساحة تخزين وذاكرة RAM كافيتان.',
              style: TextStyle(color: Colors.white54, fontSize: 10, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskProgress extends StatelessWidget {
  final AgentTask task;
  final AgentChatProvider provider;
  const _TaskProgress({required this.task, required this.provider});

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'بانتظار البدء';
      case TaskStatus.running:
        return 'قيد التنفيذ';
      case TaskStatus.paused:
        return 'متوقفة مؤقتًا';
      case TaskStatus.completed:
        return 'اكتملت';
      case TaskStatus.failed:
        return 'فشلت';
      case TaskStatus.cancelled:
        return 'أُلغيت';
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = task.steps.where((s) => s.status == StepStatus.done).length;
    final failed = task.steps.where((s) => s.status == StepStatus.failed).length;
    final canControl = task.status == TaskStatus.running ||
        task.status == TaskStatus.paused;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryGold.withOpacity(.22)),
      ),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.account_tree_outlined, color: AppColors.primaryGold, size: 18),
          const SizedBox(width: 7),
          Expanded(child: Text(task.userQuery, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Text('${(task.progress * 100).round()}%',
              style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: task.progress, minHeight: 5)),
        Row(children: [
          Text('$done/${task.steps.length} مكتملة${failed > 0 ? ' • $failed فاشلة' : ''}',
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(width: 8),
          Text(_statusLabel(task.status),
              style: TextStyle(
                color: task.status == TaskStatus.failed
                    ? Colors.redAccent
                    : task.status == TaskStatus.completed
                        ? Colors.greenAccent
                        : task.status == TaskStatus.cancelled
                            ? Colors.white38
                            : AppColors.primaryGold,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              )),
          if (task.status == TaskStatus.failed ||
              task.status == TaskStatus.cancelled)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'إعادة المحاولة',
              onPressed: () => provider.executeTask(task.userQuery),
              icon: const Icon(Icons.replay_rounded,
                  color: AppColors.primaryGold, size: 18),
            ),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: canControl ? provider.pauseOrResume : null,
            tooltip: task.status == TaskStatus.paused
                ? 'استئناف المهمة'
                : 'إيقاف مؤقت بعد الخطوة الحالية',
            icon: Icon(provider.paused ? Icons.play_arrow : Icons.pause,
                color: canControl ? AppColors.primaryGold : Colors.white24, size: 19),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: canControl ? provider.cancel : null,
            tooltip: 'إلغاء المهمة',
            icon: Icon(Icons.stop_circle_outlined,
                color: canControl ? Colors.redAccent : Colors.white24, size: 19),
          ),
        ]),
        if (task.error != null && task.error!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: SelectableText(
                'تفاصيل الخطأ: ${task.error}',
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _Transcript extends StatelessWidget {
  final AgentTask? task;
  final List<String> messages;
  final bool loadingKnowledge;
  const _Transcript({required this.task, required this.messages, required this.loadingKnowledge});

  @override
  Widget build(BuildContext context) {
    if (task == null && messages.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 68, height: 68,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(.09),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: AppColors.primaryGold.withOpacity(.22)),
              ),
              child: const Icon(Icons.psychology_alt_rounded, color: AppColors.primaryGold, size: 35),
            ),
            const SizedBox(height: 14),
            const Text('ما المهمة التي تريد إنجازها؟',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              loadingKnowledge
                  ? 'يجري تجهيز فهرس المعرفة المحلي…'
                  : 'ستظهر خطة التنفيذ وخطوات الوكلاء والنتائج والمصادر هنا. عند غياب النموذج التوليدي ستبقى نتائج البحث المحلي واضحة دون ادعاء توليد غير حقيقي.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.7),
            ),
          ]),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      children: [
        if (task?.finalAnswer != null) _AnswerCard(text: task!.finalAnswer!),
        if (task != null) ...task!.steps.map((step) => _StepCard(step: step)),
        ...messages.reversed.map((message) => _MessageBubble(text: message)),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String text;
  const _AnswerCard({required this.text});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withOpacity(.09),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.primaryGold.withOpacity(.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.task_alt_rounded, color: AppColors.primaryGold, size: 19),
            SizedBox(width: 7),
            Text('النتيجة النهائية', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 9),
          SelectableText(text, textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.white, height: 1.65)),
        ]),
      );
}

class _StepCard extends StatelessWidget {
  final AgentStep step;
  const _StepCard({required this.step});
  @override
  Widget build(BuildContext context) {
    final running = step.status == StepStatus.running;
    final failed = step.status == StepStatus.failed;
    final cancelled = step.status == StepStatus.cancelled;
    final color = failed
        ? Colors.redAccent
        : step.status == StepStatus.done
            ? Colors.greenAccent
            : cancelled
                ? Colors.white38
                : AppColors.primaryGold;
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withOpacity(.18))),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: running
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: color))
            : Icon(
                failed
                    ? Icons.error_outline_rounded
                    : step.status == StepStatus.done
                        ? Icons.check_circle_outline_rounded
                        : cancelled
                            ? Icons.cancel_outlined
                            : Icons.schedule_rounded,
                color: color,
              ),
        title: Text('${step.number}. ${step.title}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        subtitle: Text('${step.agentName} • ${step.subtitle}', maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        children: [
          if (step.result != null)
            Align(alignment: Alignment.centerRight,
                child: SelectableText(step.result!, textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white, height: 1.6))),
          ...step.details.map((detail) => ListTile(
                dense: true,
                title: Text(detail.label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                subtitle: SelectableText(detail.value, style: const TextStyle(color: Colors.white, fontSize: 12)),
              )),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  const _MessageBubble({required this.text});
  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16),
              bottomLeft: Radius.circular(5), bottomRight: Radius.circular(16),
            ),
          ),
          child: SelectableText(text, textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.white, height: 1.6)),
        ),
      );
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool running;
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.running, required this.onSend});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(color: AppColors.primaryNavy,
            border: Border(top: BorderSide(color: Colors.white.withOpacity(.08)))),
        child: SafeArea(
          top: false,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: TextField(
                controller: controller, minLines: 1, maxLines: 4,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: running ? 'المهمة قيد التنفيذ…' : 'اكتب المهمة التي تريد من مُدَبِّر إنجازها',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  filled: true, fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.primaryGold,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'تنفيذ المهمة',
                onPressed: running ? null : onSend,
                icon: const Icon(Icons.arrow_upward_rounded),
                color: AppColors.primaryNavy,
              ),
            ),
          ]),
        ),
      );
}
