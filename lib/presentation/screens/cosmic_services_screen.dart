import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../services/time_capsule_service.dart';
import '../../services/dream_journal_service.dart';
import '../../services/audio_synthesis_service.dart';
import 'astronomy_screen.dart';
import 'device/gaze_tracking_screen.dart';

class CosmicServicesScreen extends StatefulWidget {
  const CosmicServicesScreen({super.key});

  @override
  State<CosmicServicesScreen> createState() => _CosmicServicesScreenState();
}

class _CosmicServicesScreenState extends State<CosmicServicesScreen> {
  static const _legacyCapsulesKey = 'mudabbir_cosmic_time_capsules_v1';

  List<Map<String, dynamic>> _dreams = [];
  List<Map<String, dynamic>> _capsules = [];
  bool _loading = true;
  String? _error;
  bool _audioBusy = false;

  @override
  void initState() {
    super.initState();
    _loadLocalEntries();
  }

  Future<void> _loadLocalEntries() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      String? decodeWarning;
      List<Map<String, dynamic>> decode(String? raw) {
        if (raw == null || raw.trim().isEmpty) return [];
        try {
          final value = jsonDecode(raw);
          if (value is! List) {
            decodeWarning ??= 'أحد السجلات المحلية ليس قائمة صالحة.';
            return [];
          }
          return value
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList(growable: true);
        } catch (error) {
          decodeWarning ??= 'تعذر قراءة سجل محلي تالف: $error';
          return [];
        }
      }

      final dreams = await DreamJournalService.getDreams();
      var capsules = await TimeCapsuleService.getCapsules();
      final legacyCapsules = decode(preferences.getString(_legacyCapsulesKey));
      if (legacyCapsules.isNotEmpty) {
        var migrationComplete = true;
        for (final legacy in legacyCapsules) {
          final text = (legacy['text'] ?? '').toString().trim();
          final rawUnlock = (legacy['unlockAt'] ?? '').toString();
          final unlock = DateTime.tryParse(rawUnlock);
          if (text.isEmpty || unlock == null) {
            decodeWarning ??=
                'تحتوي بعض الكبسولات القديمة على نص أو تاريخ غير صالح؛ احتُفظ بسجل الترحيل للمراجعة.';
            migrationComplete = false;
            continue;
          }
          final alreadyExists = capsules.any((capsule) =>
              (capsule['content'] ?? '').toString() == text &&
              DateTime.tryParse((capsule['unlockDate'] ?? '').toString()) ==
                  unlock);
          if (!alreadyExists) {
            try {
              await TimeCapsuleService.importLegacyCapsule(text, unlock);
            } catch (error) {
              decodeWarning ??=
                  'بقيت بعض الكبسولات القديمة دون ترحيل: $error';
              migrationComplete = false;
              break;
            }
          }
        }
        // Keep the legacy source when capacity or storage errors prevent a
        // complete migration; imported entries are deduplicated on retry.
        if (migrationComplete) {
          await preferences.remove(_legacyCapsulesKey);
        }
        capsules = await TimeCapsuleService.getCapsules();
      }
      if (!mounted) return;
      setState(() {
        _dreams = dreams;
        _capsules = capsules;
        _loading = false;
        _error = decodeWarning;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر قراءة السجلات المحلية: $error';
      });
    }
  }

  Future<void> _saveDream(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;
    if (content.length > 5000) {
      if (mounted) setState(() => _error = 'المذكرة طويلة جدًا؛ الحد الأقصى 5000 حرف.');
      return;
    }
    try {
      await DreamJournalService.addDream(content);
      final updated = await DreamJournalService.getDreams();
      if (!mounted) return;
      setState(() {
        _dreams = updated;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ المذكرة محليًا على هذا الجهاز.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'تعذر حفظ المذكرة: $error');
    }
  }

  Future<void> _saveCapsule(String text, DateTime unlockDate) async {
    final content = text.trim();
    if (content.isEmpty) return;
    if (content.length > 10000) {
      if (mounted) setState(() => _error = 'رسالة الكبسولة طويلة جدًا؛ الحد الأقصى 10000 حرف.');
      return;
    }
    try {
      await TimeCapsuleService.sealCapsule(content, unlockDate);
      final updated = await TimeCapsuleService.getCapsules();
      if (!mounted) return;
      setState(() {
        _capsules = updated;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الكبسولة محليًا؛ لا تُرسل إلى أي خادم.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'تعذر حفظ الكبسولة: $error');
    }
  }

  Future<void> _removeDream(
    String id,
    BuildContext dialogContext,
  ) async {
    try {
      await DreamJournalService.removeDream(id);
      final updated = await DreamJournalService.getDreams();
      if (!mounted) return;
      setState(() {
        _dreams = updated;
        _error = null;
      });
      if (dialogContext.mounted) Navigator.pop(dialogContext, false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المذكرة المحلية.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حذف المذكرة: $error')),
      );
    }
  }

  Future<void> _openDreamJournal() async {
    final controller = TextEditingController();
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مذكرات الأحلام'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'سجّل ما تريد تذكره. المذكرات نصوص شخصية محفوظة محليًا، '
                'وليست تفسيرًا مؤكدًا أو تنبؤًا.',
                textDirection: TextDirection.rtl,
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'اكتب مذكرتك هنا...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('مذكرات محفوظة: ${_dreams.length}'),
              ),
              if (_dreams.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    itemCount: _dreams.length,
                    itemBuilder: (_, index) => ListTile(
                      dense: true,
                      title: Text(
                        (_dreams[index]['text'] ?? '').toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text(
                        (_dreams[index]['createdAt'] ?? '').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        tooltip: 'حذف المذكرة',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => _removeDream(
                          (_dreams[index]['id'] ?? '').toString(),
                          dialogContext,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إغلاق'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حفظ المذكرة'),
          ),
        ],
      ),
    );
    final text = controller.text.trim();
    controller.dispose();
    if (shouldSave == true && text.isNotEmpty) await _saveDream(text);
  }

  Future<void> _openTimeCapsule() async {
    final now = DateTime.now();
    final unlockDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 50),
      helpText: 'اختر تاريخ فتح الرسالة',
    );
    if (unlockDate == null || !mounted) return;

    final controller = TextEditingController();
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('كبسولة زمنية'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'اكتب رسالة لنفسك في المستقبل...',
            helperText: 'تاريخ الفتح: ${unlockDate.year}-${unlockDate.month.toString().padLeft(2, '0')}-${unlockDate.day.toString().padLeft(2, '0')}',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حفظ محلي'),
          ),
        ],
      ),
    );
    final text = controller.text.trim();
    controller.dispose();
    if (shouldSave == true && text.isNotEmpty) {
      // DatePicker returns midnight. Use the end of the selected local day so
      // choosing today's date does not make the capsule immediately readable.
      final unlockAt = DateTime(
        unlockDate.year,
        unlockDate.month,
        unlockDate.day,
        23,
        59,
        59,
      );
      await _saveCapsule(text, unlockAt);
    }
  }

  Future<void> _removeCapsule(String id, BuildContext dialogContext) async {
    try {
      await TimeCapsuleService.removeCapsule(id);
      final updated = await TimeCapsuleService.getCapsules();
      if (!mounted) return;
      setState(() {
        _capsules = updated;
        _error = null;
      });
      if (dialogContext.mounted) Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الكبسولة المحلية.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حذف الكبسولة: $error')),
      );
    }
  }

  Future<void> _showCapsules() async {
    final now = DateTime.now();
    final due = _capsules.where((item) {
      final raw = item['unlockDate']?.toString();
      final date = raw == null ? null : DateTime.tryParse(raw);
      return date != null && !date.isAfter(now);
    }).toList(growable: false);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الكبسولات الزمنية المحلية'),
        content: SizedBox(
          width: 420,
          height: 320,
          child: _capsules.isEmpty
              ? const Text('لا توجد كبسولات محفوظة بعد.')
              : ListView(
                  shrinkWrap: true,
                  children: _capsules.map((item) {
                    final raw = item['unlockDate']?.toString() ?? '';
                    final date = DateTime.tryParse(raw);
                    final available = date != null && !date.isAfter(now);
                    return ListTile(
                      leading: Icon(
                        available ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                        color: AppColors.primaryGold,
                      ),
                      title: Text(
                        available ? (item['content'] ?? '').toString() : 'رسالة مؤجلة',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text('تاريخ الفتح: ${raw.isEmpty ? 'غير محدد' : raw}'),
                      trailing: IconButton(
                        tooltip: 'حذف الكبسولة',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => _removeCapsule(
                          (item['id'] ?? '').toString(),
                          dialogContext,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
    if (due.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('توجد ${due.length} رسالة مؤهلة للعرض حسب التاريخ المحلي.')),
      );
    }
  }

  Future<void> _playTone(Future<void> Function() play) async {
    if (_audioBusy) return;
    setState(() => _audioBusy = true);
    try {
      await play();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('بدأ تشغيل صوت تجريبي محلي لمدة قصيرة؛ لا توجد فائدة علاجية مثبتة.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تشغيل الصوت: $error')),
      );
    } finally {
      if (mounted) setState(() => _audioBusy = false);
    }
  }

  Future<void> _openAudioControls() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الصوت والتركيز'),
        content: const Text(
          'توليد محلي قصير لنغمتين قريبتين في قناتي الاستريو. الرقم المسمّى هو فرق التردد بين القناتين، وليس نغمة مسموعة منفردة ولا علاجًا أو ضمانًا لتحسين التركيز.',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton.icon(
            onPressed: _audioBusy ? null : () => _playTone(AudioSynthesisService.playTranquility),
            icon: const Icon(Icons.spa_outlined),
            label: const Text('هدوء · 7.83 Hz'),
          ),
          TextButton.icon(
            onPressed: _audioBusy ? null : () => _playTone(AudioSynthesisService.playFocus),
            icon: const Icon(Icons.center_focus_strong),
            label: const Text('تركيز · 14 Hz'),
          ),
          TextButton.icon(
            onPressed: _audioBusy ? null : () => _playTone(AudioSynthesisService.playDeepMeditation),
            icon: const Icon(Icons.self_improvement),
            label: const Text('تأمل · 4 Hz'),
          ),
          TextButton.icon(
            onPressed: () async {
              try {
                await AudioSynthesisService.stop();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تعذر إيقاف الصوت: $error')),
                  );
                }
              }
            },
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('إيقاف الصوت'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _openQuantumDemo() async {
    var angle = 90.0;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final probability = math.pow(math.sin(angle * math.pi / 360), 2).toDouble();
          return AlertDialog(
            title: const Text('نموذج كيوبت تعليمي مبسّط'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'يمثل النموذج حالة نظرية cos(θ/2)|0⟩ + sin(θ/2)|1⟩. وفق قاعدة بورن، احتمال قياس الحالة |1⟩ هو sin²(θ/2). هذا حساب رياضي توضيحي وليس محاكاة جهاز كمومي أو تجربة فيزيائية.',
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 18),
                  Text('زاوية التحضير: ${angle.round()}°'),
                  Slider(
                    value: angle,
                    min: 0,
                    max: 180,
                    divisions: 180,
                    label: '${angle.round()}°',
                    onChanged: (value) => setDialogState(() => angle = value),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: probability, minHeight: 10),
                  const SizedBox(height: 8),
                  Text('احتمال |1⟩: ${(probability * 100).toStringAsFixed(1)}٪'),
                  Text('احتمال |0⟩: ${((1 - probability) * 100).toStringAsFixed(1)}٪'),
                  const SizedBox(height: 8),
                  const Text('لا يستخدم هذا النموذج بيانات حساسات أو عتادًا كموميًا.', textDirection: TextDirection.rtl),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق')),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showHonestStatus(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message, textDirection: TextDirection.rtl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unawaited(AudioSynthesisService.stop().catchError((Object error) {
      debugPrint('Could not stop cosmic audio during dispose: $error');
    }));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'الخدمات الكونية',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            'مذكرات الأحلام',
            _loading ? 'جارٍ تحميل السجل المحلي…' : '${_dreams.length} مذكرة محفوظة على الجهاز',
            Icons.auto_stories_outlined,
            _openDreamJournal,
          ),
          _buildCard(
            'كبسولة زمنية',
            '${_capsules.length} رسالة محفوظة محليًا',
            Icons.schedule_rounded,
            _openTimeCapsule,
            trailing: IconButton(
              tooltip: 'عرض الكبسولات',
              onPressed: _showCapsules,
              icon: const Icon(Icons.list_alt_rounded, color: AppColors.primaryGold),
            ),
          ),
          _buildCard(
            'محاكاة كمومية تعليمية',
            'نموذج كيوبت واحتمالات قياس وفق قاعدة بورن',
            Icons.hub_outlined,
            _openQuantumDemo,
          ),
          _buildCard(
            'الصوت والتركيز',
            _audioBusy ? 'جارٍ بدء الصوت التجريبي…' : 'نغمات استريو محلية قصيرة مع زر إيقاف',
            Icons.graphic_eq_rounded,
            _openAudioControls,
          ),
          _buildCard(
            'المعلومات الفلكية',
            'طور القمر التقريبي وزمن الضوء والفترات المدارية',
            Icons.public_rounded,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AstronomyScreen()),
            ),
          ),
          _buildCard(
            'تتبع العين',
            'فتح واجهة التتبع والمعايرة المتاحة',
            Icons.visibility_outlined,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GazeTrackingScreen()),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _error!,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'المذكرات والكبسولات محفوظة محليًا في تفضيلات التطبيق. حذف بيانات التطبيق قد يزيلها؛ لا تُرفع إلى خادم من هذه الشاشة. تأجيل الكبسولة إخفاء داخل الواجهة وليس تشفيرًا أو قفلًا أمنيًا.',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGold),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
        trailing: trailing ??
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        onTap: onTap,
      ),
    );
  }
}
