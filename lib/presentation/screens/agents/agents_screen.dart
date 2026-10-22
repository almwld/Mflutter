import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/agent_task.dart';
import '../../../services/agent_registry.dart';
import '../../../services/local_gguf_runtime_service.dart';
import '../../providers/agent_chat_provider.dart';

class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => AgentChatProvider()..initialize(),
        child: const _AgentsView(),
      );
}

class _AgentsView extends StatefulWidget {
  const _AgentsView();

  @override
  State<_AgentsView> createState() => _AgentsViewState();
}

class _AgentsViewState extends State<_AgentsView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AgentChatProvider>();
    final task = provider.activeTask;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text(
          'مُدَبِّر — الوكلاء الفائقون',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        actions: [
          Center(
            child: Text(
              '${AgentRegistry.all.length} وكيل',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 68,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: const EdgeInsets.all(10),
              itemCount: AgentRegistry.all.length,
              itemBuilder: (_, index) {
                final agent = AgentRegistry.all[index];
                final selected = provider.selectedAgent == agent.id;
                return Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: ChoiceChip(
                    label: Text(agent.name),
                    selected: selected,
                    onSelected: (_) =>
                        provider.selectAgent(selected ? null : agent.id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryNavyLight.withOpacity(.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.storage_rounded,
                        color: AppColors.primaryNavyLight,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      const Expanded(
                        child: Text(
                          'معرفة محلية من ملفات assets',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${provider.indexedDocumentCount} مقطع',
                        style: const TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.loadedKnowledgeSources.isEmpty
                        ? 'جارٍ فهرسة الأصول المحلية...'
                        : 'المصادر: ${provider.loadedKnowledgeSources.join(' • ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _LocalGgufModelCard(),
          if (task != null) _TaskBar(task: task, provider: provider),
          Expanded(child: _TaskView(task: task, messages: provider.messages)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'كلّف مُدَبِّر بمهمة...',
                        hintStyle: TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(provider),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryGold,
                    child: IconButton(
                      color: AppColors.primaryNavy,
                      icon: const Icon(Icons.send),
                      onPressed: () => _send(provider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send(AgentChatProvider provider) {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    _controller.clear();
    provider.executeTask(query);
  }
}

class _TaskBar extends StatelessWidget {
  final AgentTask task;
  final AgentChatProvider provider;

  const _TaskBar({required this.task, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(.45)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primaryGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.userQuery,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${(task.progress * 100).round()}%',
                style: const TextStyle(color: AppColors.primaryGold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: task.progress, minHeight: 5),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${task.steps.where((s) => s.status == StepStatus.done).length}/${task.steps.length} خطوات',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const Spacer(),
              IconButton(
                onPressed: provider.pauseOrResume,
                icon: Icon(
                  provider.paused ? Icons.play_arrow : Icons.pause,
                  color: AppColors.primaryGold,
                ),
              ),
              IconButton(
                onPressed: provider.cancel,
                icon: const Icon(
                  Icons.stop_circle_outlined,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskView extends StatelessWidget {
  final AgentTask? task;
  final List<String> messages;

  const _TaskView({required this.task, required this.messages});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (task?.finalAnswer != null) _Message(text: task!.finalAnswer!),
          if (task != null) ...task!.steps.map((step) => _Step(step: step)),
          ...messages.reversed.map((message) => _Message(text: message)),
          if (task == null && messages.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Text(
                'اكتب مهمة للوكلاء الفائقين. ستظهر خطوات التنفيذ والأدلة والمصادر هنا.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
        ],
      );
}

class _Step extends StatelessWidget {
  final AgentStep step;

  const _Step({required this.step});

  @override
  Widget build(BuildContext context) {
    final running = step.status == StepStatus.running;
    final failed = step.status == StepStatus.failed;
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: running
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                failed
                    ? Icons.error_outline
                    : step.status == StepStatus.done
                        ? Icons.check_circle
                        : Icons.schedule,
                color: failed ? Colors.redAccent : AppColors.primaryGold,
              ),
        title: Text(
          '${step.number}. ${step.title}',
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${step.agentName} • ${step.subtitle}',
          style: const TextStyle(color: Colors.white54),
        ),
        children: [
          if (step.result != null)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  step.result!,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white, height: 1.6),
                ),
              ),
            ),
          ...step.details.map(
            (detail) => ListTile(
              dense: true,
              title: Text(
                detail.label,
                style: const TextStyle(color: Colors.white54),
              ),
              subtitle: Text(
                detail.value,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: Colors.white, height: 1.7),
        ),
      );
}


class _LocalGgufModelCard extends StatefulWidget {
  const _LocalGgufModelCard();

  @override
  State<_LocalGgufModelCard> createState() => _LocalGgufModelCardState();
}

class _LocalGgufModelCardState extends State<_LocalGgufModelCard> {
  final LocalGgufRuntimeService _runtime = LocalGgufRuntimeService.instance;
  bool _hasModel = false;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _runtime.addListener(_onRuntimeChanged);
    _refreshModel();
  }

  @override
  void dispose() {
    _runtime.removeListener(_onRuntimeChanged);
    super.dispose();
  }

  void _onRuntimeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshModel() async {
    final valid = await _runtime.hasValidModel();
    if (mounted) setState(() => _hasModel = valid);
  }

  Future<void> _importModel() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['gguf'],
      allowMultiple: false,
      withData: false,
    );
    final path = picked?.files.singleOrNull?.path;
    if (path == null) return;
    await _run(() async {
      await _runtime.importModel(path);
      await _refreshModel();
    });
  }

  Future<void> _downloadModel() async {
    await _run(() async {
      await _runtime.downloadDefaultModel();
      await _refreshModel();
    });
  }

  Future<void> _loadModel() async {
    await _run(() => _runtime.loadModel());
  }

  Future<void> _unloadModel() async {
    await _run(_runtime.unloadModel);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تنفيذ العملية: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
      await _refreshModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _runtime.downloadProgress;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryNavyLight.withOpacity(.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Icon(Icons.memory_rounded, color: AppColors.primaryNavyLight),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'الذكاء التوليدي المحلي — GGUF',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(
                _runtime.isLoaded ? Icons.check_circle : Icons.radio_button_unchecked,
                color: _runtime.isLoaded ? Colors.greenAccent : Colors.white38,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _runtime.status,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (progress != null && _runtime.isBusy) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 3),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _working || _runtime.isBusy ? null : _importModel,
                icon: const Icon(Icons.file_open),
                label: const Text('استيراد GGUF'),
              ),
              OutlinedButton.icon(
                onPressed: _working || _runtime.isBusy ? null : _downloadModel,
                icon: const Icon(Icons.download),
                label: const Text('تنزيل 3arabLM'),
              ),
              FilledButton.icon(
                onPressed: _working || _runtime.isBusy
                    ? null
                    : (_runtime.isLoaded ? _unloadModel : (_hasModel ? _loadModel : null)),
                icon: Icon(_runtime.isLoaded ? Icons.stop_circle : Icons.play_arrow),
                label: Text(_runtime.isLoaded ? 'إيقاف النموذج' : 'تحميل النموذج'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'يُحفظ النموذج في مساحة التطبيق الخاصة. حجم 3arabLM Q4_K_M نحو 2.71 GB؛ يحتاج مساحة تخزين وذاكرة كافية. لا يُعد الملف صالحًا للاستدلال حتى ينجح تحميله في llama.cpp.',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }
}
