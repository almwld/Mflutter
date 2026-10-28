import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/nucleus_service.dart';

class NucleusScreen extends StatefulWidget {
  const NucleusScreen({super.key});
  @override
  State<NucleusScreen> createState() => _NucleusScreenState();
}

class _NucleusScreenState extends State<NucleusScreen> with SingleTickerProviderStateMixin {
  final NucleusService _core = NucleusService();
  late final AnimationController _pulse;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _core.addListener(_refresh);
    _core.initialize();
  }

  void _refresh() { if (mounted) setState(() {}); }

  Future<void> _importAndLoad() async {
    if (_working || _core.isModelBusy || _core.isGenerating) return;
    setState(() => _working = true);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: const ['gguf'], withData: false);
      if (result == null) return;
      final path = result.files.single.path;
      if (path == null || path.isEmpty) throw StateError('تعذر الحصول على مسار ملف GGUF.');
      await _core.importAndLoadModel(path, threads: 4, contextSize: 512);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحميل النموذج المحلي بنجاح.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر تحميل النموذج: ' + error.toString()), duration: const Duration(seconds: 6)));
    } finally { if (mounted) setState(() => _working = false); }
  }

  Future<void> _loadExisting() async {
    if (_working || _core.isModelBusy || _core.isGenerating) return;
    setState(() => _working = true);
    try {
      await _core.loadModel(threads: 4, contextSize: 512);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('النموذج المحلي جاهز للاستدلال.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر تشغيل النموذج: ' + error.toString()), duration: const Duration(seconds: 6)));
    } finally { if (mounted) setState(() => _working = false); }
  }

  @override
  void dispose() { _core.removeListener(_refresh); _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sciences = _core.getSciences();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('النواة المركزية'), backgroundColor: AppColors.primaryNavy),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.primaryNavy, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primaryGold.withOpacity(.35))),
          child: Column(children: [
            AnimatedBuilder(animation: _pulse, builder: (_, __) => Transform.scale(scale: .94 + _pulse.value * .08, child: const Icon(Icons.psychology_alt_rounded, size: 82, color: AppColors.primaryGold))),
            const SizedBox(height: 12),
            const Text('مُدَبِّر Visual Core', style: TextStyle(color: AppColors.primaryGold, fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_core.isInitializing ? 'جارٍ تجهيز النواة…' : (_core.isInitialized ? 'النواة مهيأة · ' + _core.source : 'لم تكتمل التهيئة'), textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 12),
        _status('سجل الوكلاء', _core.uniqueAgentCount.toString() + ' وكيلًا معرّفًا', 'تعريفات السجل ليست عدد الوكلاء النشطين أثناء التنفيذ.'),
        _status('المعرفة المحلية', _core.knowledgeReady ? 'جاهزة' : 'لم تجهز بالكامل', _core.indexedDocumentCount.toString() + ' مستندًا · ' + _core.loadedKnowledgeSources.length.toString() + ' مصادر محمّلة'),
        _status('النموذج المحلي', _core.isModelLoaded ? 'محمّل وجاهز' : 'غير محمّل', _core.modelStatus),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: _working || _core.isModelLoaded ? null : _importAndLoad,
          icon: _working ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.file_open_rounded),
          label: Text(_working ? 'جارٍ تجهيز النموذج…' : 'استيراد نموذج GGUF وتشغيله'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.primaryNavy, padding: const EdgeInsets.symmetric(vertical: 14))),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: _working || _core.isModelLoaded ? null : _loadExisting, icon: const Icon(Icons.play_circle_outline_rounded), label: const Text('تشغيل النموذج المستورد سابقًا')),
        if (_core.isModelLoaded) const ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('الاستدلال المحلي متاح'), subtitle: Text('تستخدم المحادثة محرك llama.cpp عند التوليد.')),
        if (_core.error != null) _status('تنبيه تشخيصي', 'تحتاج إلى مراجعة', _core.error!),
        const SizedBox(height: 12),
        Text('المجالات المسجلة', style: Theme.of(context).textTheme.titleMedium),
        Wrap(spacing: 8, runSpacing: 8, children: sciences.map((item) => Chip(label: Text((item['name'] ?? item['id'] ?? 'مجال').toString()))).toList()),
        const SizedBox(height: 16),
        const Text('وجود تعريف لوكيل لا يعني أنه يعمل باستمرار. التدريب والمستشعرات لا تُعرض كميزات نشطة إلا بعد توفر تنفيذ فعلي وصلاحيات لازمة.', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white60, height: 1.6, fontSize: 12)),
      ]),
    );
  }

  Widget _status(String title, String value, String detail) => Card(
    color: AppColors.primaryNavy.withOpacity(.78), margin: const EdgeInsets.only(bottom: 10),
    child: Padding(padding: const EdgeInsets.all(12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.hub_rounded, color: AppColors.primaryGold, size: 26),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(detail, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white60, height: 1.5, fontSize: 12)),
      ])),
    ])),
  );
}
