import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/themes/mudabbir_design_tokens.dart';
import '../widgets/common/mudabbir_glass_panel.dart';
import '../../services/agent_registry.dart';
import '../../services/nucleus_service.dart';

class NucleusScreen extends StatefulWidget {
  const NucleusScreen({super.key});

  @override
  State<NucleusScreen> createState() => _NucleusScreenState();
}

class _NucleusScreenState extends State<NucleusScreen>
    with SingleTickerProviderStateMixin {
  final NucleusService _core = NucleusService();
  late final AnimationController _pulse;
  bool _working = false;
  String? _selectedAgentId;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _core.addListener(_refresh);
    _core.initialize();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _importAndLoad() async {
    if (_working || _core.isModelBusy || _core.isGenerating) return;
    setState(() => _working = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['gguf'],
        withData: false,
      );
      if (result == null) return;
      final path = result.files.single.path;
      if (path == null || path.isEmpty) {
        throw StateError('تعذر الحصول على مسار ملف GGUF.');
      }
      await _core.importAndLoadModel(path, threads: 4, contextSize: 512);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحميل النموذج المحلي بنجاح.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تحميل النموذج: $error'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _loadExisting() async {
    if (_working || _core.isModelBusy || _core.isGenerating) return;
    setState(() => _working = true);
    try {
      await _core.loadModel(threads: 4, contextSize: 512);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('النموذج المحلي جاهز للاستدلال.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تشغيل النموذج: $error'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _unloadModel() async {
    if (_working || _core.isModelBusy || _core.isGenerating ||
        !_core.isModelLoaded) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تحرير ذاكرة النموذج'),
        content: const Text(
          'سيتم إيقاف النموذج المحلي وتحرير موارده من الذاكرة. '
          'لن يُحذف ملف GGUF المستورد، ويمكن تحميله مجددًا لاحقًا.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('إيقاف وتحرير'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _working = true);
    try {
      await _core.unloadModel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إيقاف النموذج وتحرير موارده؛ بقي الملف المستورد محفوظًا.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تحرير موارد النموذج بالكامل: $error'),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  void dispose() {
    _core.removeListener(_refresh);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sciences = _core.getSciences();
    final agents = AgentRegistry.all;
    final visibleAgents = agents.take(32).toList(growable: false);
    final selectedAgent = agents.isEmpty
        ? null
        : agents.firstWhere(
            (agent) => agent.id == _selectedAgentId,
            orElse: () => agents.first,
          );

    return Scaffold(
      backgroundColor: MudabbirDesignTokens.cosmicBackground,
      appBar: AppBar(
        title: const Text('النواة المركزية'),
        backgroundColor: MudabbirDesignTokens.cosmicDeepBackground,
        foregroundColor: MudabbirDesignTokens.goldBright,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(.35),
              ),
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Transform.scale(
                    scale: .94 + _pulse.value * .08,
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      size: 82,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'مُدَبِّر Visual Core',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _core.isInitializing
                      ? 'جارٍ تجهيز النواة…'
                      : (_core.isInitialized
                          ? 'النواة مهيأة · ${_core.source}'
                          : 'لم تكتمل التهيئة'),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _status(
            'سجل الوكلاء',
            '${_core.uniqueAgentCount} وكيلًا معرّفًا',
            'هذا العدد يصف تعريفات السجل، وليس عدد الوكلاء النشطين أثناء التنفيذ.',
          ),
          _status(
            'المعرفة المحلية',
            _core.knowledgeReady ? 'جاهزة' : 'لم تجهز بالكامل',
            '${_core.indexedDocumentCount} مستندًا · '
                '${_core.loadedKnowledgeSources.length} مصادر محمّلة',
          ),
          _status(
            'النموذج المحلي',
            _core.isModelLoaded ? 'محمّل وجاهز للاستدلال' : 'غير محمّل',
            _core.modelStatus,
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _working || _core.isModelLoaded ? null : _importAndLoad,
            icon: _working
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_open_rounded),
            label: Text(
              _working ? 'جارٍ تجهيز النموذج…' : 'استيراد نموذج GGUF وتشغيله',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.primaryNavy,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _working || _core.isModelLoaded ? null : _loadExisting,
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: const Text('تشغيل النموذج المستورد سابقًا'),
          ),
          if (_core.isModelLoaded)
            const ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('الاستدلال المحلي متاح'),
              subtitle: Text(
                'تستخدم المحادثة محرك llama.cpp عند التوليد.',
              ),
            ),
          if (_core.isModelLoaded)
            OutlinedButton.icon(
              onPressed: _working ||
                      _core.isModelBusy ||
                      _core.isGenerating
                  ? null
                  : _unloadModel,
              icon: const Icon(Icons.memory_rounded),
              label: const Text('إيقاف النموذج وتحرير الذاكرة'),
            ),
          if (_core.error != null)
            _status('تنبيه تشخيصي', 'تحتاج إلى مراجعة', _core.error!),
          const SizedBox(height: 22),
          _sectionTitle('خريطة سجل الوكلاء'),
          const SizedBox(height: 6),
          const Text(
            'العقد تمثل تعريفات موجودة في AgentRegistry. الخطوط تصل كل تعريف '
            'بالسجل فقط؛ ولا تمثل اتصالات تنفيذية أو حالة تشغيل.',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.white60, height: 1.5),
          ),
          const SizedBox(height: 10),
          MudabbirGlassPanel(
            padding: const EdgeInsets.all(8),
            radius: 22,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, 290);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final index = _AgentRegistryPainter.findTappedNode(
                      details.localPosition,
                      size,
                      visibleAgents,
                    );
                    if (index == null) return;
                    setState(() {
                      _selectedAgentId = visibleAgents[index].id;
                    });
                  },
                  child: CustomPaint(
                    size: size,
                    painter: _AgentRegistryPainter(
                      agents: visibleAgents,
                      selectedId: selectedAgent?.id,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'يعرض الرسم ${visibleAgents.length} من ${agents.length} تعريفًا. '
            'اختر عقدة أو استخدم القائمة لاختيار أي تعريف.',
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (agents.isNotEmpty) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedAgent?.id,
              isExpanded: true,
              dropdownColor: AppColors.primaryNavy,
              decoration: InputDecoration(
                labelText: 'اختيار وكيل من السجل',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: agents
                  .map(
                    (agent) => DropdownMenuItem<String>(
                      value: agent.id,
                      child: Text(
                        '${agent.name} · ${agent.layer}',
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) setState(() => _selectedAgentId = value);
              },
            ),
            if (selectedAgent != null) ...[
              const SizedBox(height: 10),
              _selectedAgentCard(selectedAgent),
            ],
          ],
          const SizedBox(height: 22),
          _sectionTitle('المجالات المسجلة'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sciences
                .map(
                  (item) => Chip(
                    label: Text(
                      (item['name'] ?? item['id'] ?? 'مجال').toString(),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'وجود تعريف لوكيل لا يعني أنه يعمل باستمرار. التدريب والمستشعرات '
            'لا تُعرض كميزات نشطة إلا بعد توفر تنفيذ فعلي وصلاحيات لازمة.',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white60,
              height: 1.6,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _selectedAgentCard(AgentDefinition agent) => Card(
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                agent.name,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${agent.id} · ${agent.layer}',
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                agent.description,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 8),
              const Text(
                'الحالة: مسجل في الفهرس؛ حالة التنفيذ غير متاحة من بيانات السجل وحدها.',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      );

  Widget _status(String title, String value, String detail) => Card(
        color: AppColors.primaryNavy.withOpacity(.78),
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.hub_rounded,
                color: AppColors.primaryGold,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Colors.white60,
                        height: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _AgentRegistryPainter extends CustomPainter {
  const _AgentRegistryPainter({
    required this.agents,
    required this.selectedId,
  });

  final List<AgentDefinition> agents;
  final String? selectedId;

  static Offset _center(Size size) => Offset(size.width / 2, size.height / 2);

  static Offset _nodePosition(Size size, int index, int count) {
    final center = _center(size);
    final radius = math.min(size.width, size.height) * .39;
    final angle = -math.pi / 2 + (2 * math.pi * index / count);
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  static int? findTappedNode(
    Offset point,
    Size size,
    List<AgentDefinition> agents,
  ) {
    for (var i = 0; i < agents.length; i++) {
      if ((point - _nodePosition(size, i, agents.length)).distance <= 15) {
        return i;
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (agents.isEmpty) return;
    final center = _center(size);
    final centerFill = Paint()..color = AppColors.primaryNavy;
    final edgePaint = Paint()
      ..color = AppColors.primaryGold.withOpacity(.22)
      ..strokeWidth = 1;
    final ringPaint = Paint()
      ..color = AppColors.primaryGold.withOpacity(.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(
      center,
      math.min(size.width, size.height) * .43,
      ringPaint,
    );

    for (var i = 0; i < agents.length; i++) {
      final position = _nodePosition(size, i, agents.length);
      canvas.drawLine(center, position, edgePaint);
    }

    canvas.drawCircle(center, 28, centerFill);
    canvas.drawCircle(
      center,
      28,
      Paint()
        ..color = AppColors.primaryGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final centerLabel = TextPainter(
      text: const TextSpan(
        text: 'السجل',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    centerLabel.paint(
      canvas,
      Offset(
        center.dx - centerLabel.width / 2,
        center.dy - centerLabel.height / 2,
      ),
    );

    for (var i = 0; i < agents.length; i++) {
      final agent = agents[i];
      final position = _nodePosition(size, i, agents.length);
      final selected = agent.id == selectedId;
      canvas.drawCircle(
        position,
        selected ? 8 : 5.5,
        Paint()
          ..color = selected ? AppColors.primaryGold : const Color(0xFF38BDF8),
      );
      canvas.drawCircle(
        position,
        selected ? 12 : 8.5,
        Paint()
          ..color = (selected ? AppColors.primaryGold : const Color(0xFF38BDF8))
              .withOpacity(.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AgentRegistryPainter oldDelegate) =>
      oldDelegate.selectedId != selectedId ||
      oldDelegate.agents.length != agents.length;
}
