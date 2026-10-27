import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/agent_task.dart';
import '../../../services/agent_registry.dart';
import '../../../services/local_gguf_runtime_service.dart';
import '../../providers/agent_chat_provider.dart';
import '../../../services/external_asset_service.dart';

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
  String _layer = 'الكل';

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgentChatProvider>();
    final task = provider.activeTask;
    final layers = <String>{'الكل', ...AgentRegistry.all.map((a) => a.layer)};
    final agents = _layer == 'الكل'
        ? AgentRegistry.all
        : AgentRegistry.all.where((a) => a.layer == _layer).toList();

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
            IconButton(
              tooltip: 'استيراد أصول OCR / ML Kit والنماذج المحلية',
              onPressed: _importOptionalAssets,
              icon: const Icon(Icons.folder_open_outlined),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: Center(
                child: Text('${AgentRegistry.all.length} وكيل',
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
                initialized: provider.loadedKnowledgeSources.isNotEmpty,
              ),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: [
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
                  loadingKnowledge: provider.loadedKnowledgeSources.isEmpty,
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
  const _WorkspaceHero({
    required this.documentCount,
    required this.sourceCount,
    required this.initialized,
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
                initialized ? 'بحث محلي موثّق • النموذج التوليدي اختياري' : 'تهيئة فهرس المعرفة المحلي…',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
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
  final _runtime = LocalGgufRuntimeService.instance;
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

  Future<void> _importModel() async {  Future<void> _importModel() async {
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
      final cancelled = _runtime.status.contains('أُلغي');
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
              color: _runtime.isLoaded ? Colors.green.withOpacity(.12) : AppColors.primaryGold.withOpacity(.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.memory_rounded, color: _runtime.isLoaded ? Colors.greenAccent : AppColors.primaryGold),
          ),
          title: const Text('النموذج المحلي GGUF',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(
            _runtime.isLoaded ? 'محمّل • الاستدلال محلي' : _hasModel ? 'ملف مستورد • جاهز للتشغيل' : 'لا يوجد نموذج • استورد ملف GGUF محليًا',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          children: [
            Align(alignment: Alignment.centerRight, child: Text(_runtime.status,
                style: const TextStyle(color: Colors.white70, fontSize: 11))),
            const SizedBox(height: 9),
            Wrap(spacing: 7, runSpacing: 7, children: [            const SizedBox(height: 9),
            Wrap(spacing: 7, runSpacing: 7, children: [
              OutlinedButton.icon(
                onPressed: busy || _runtime.isLoaded ? null : _importModel,
                icon: const Icon(Icons.file_open_rounded, size: 17),
                label: const Text('استيراد من ذاكرة الهاتف'),
              ),
              FilledButton.icon(
                onPressed: busy ? null : _runtime.isLoaded
                    ? () => _run(_runtime.unloadModel)
                    : _hasModel ? () => _run(_runtime.loadModel) : null,
                icon: Icon(_runtime.isLoaded ? Icons.stop_circle_outlined : Icons.play_arrow_rounded),
                label: Text(_runtime.isLoaded ? 'إيقاف النموذج' : 'تحميل النموذج'),
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
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: canControl ? provider.pauseOrResume : null,
            tooltip: task.status == TaskStatus.paused ? 'استئناف المهمة' : 'إيقاف مؤقت',
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
    final color = failed ? Colors.redAccent : step.status == StepStatus.done ? Colors.greenAccent : AppColors.primaryGold;
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
            : Icon(failed ? Icons.error_outline_rounded : step.status == StepStatus.done
                ? Icons.check_circle_outline_rounded : Icons.schedule_rounded, color: color),
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
