import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import 'device/gaze_tracking_screen.dart';

class CosmicServicesScreen extends StatefulWidget {
  const CosmicServicesScreen({super.key});

  @override
  State<CosmicServicesScreen> createState() => _CosmicServicesScreenState();
}

class _CosmicServicesScreenState extends State<CosmicServicesScreen> {
  static const _dreamsKey = 'mudabbir_cosmic_dream_journal_v1';
  static const _capsulesKey = 'mudabbir_cosmic_time_capsules_v1';

  List<Map<String, dynamic>> _dreams = [];
  List<Map<String, dynamic>> _capsules = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocalEntries();
  }

  Future<void> _loadLocalEntries() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> decode(String? raw) {
        if (raw == null || raw.trim().isEmpty) return [];
        final value = jsonDecode(raw);
        if (value is! List) return [];
        return value
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList(growable: true);
      }

      final dreams = decode(preferences.getString(_dreamsKey));
      final capsules = decode(preferences.getString(_capsulesKey));
      if (!mounted) return;
      setState(() {
        _dreams = dreams;
        _capsules = capsules;
        _loading = false;
        _error = null;
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
    final entry = <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'createdAt': DateTime.now().toIso8601String(),
      'text': text.trim(),
    };
    final updated = [entry, ..._dreams];
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_dreamsKey, jsonEncode(updated));
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
    final entry = <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'createdAt': DateTime.now().toIso8601String(),
      'unlockAt': DateTime(
        unlockDate.year,
        unlockDate.month,
        unlockDate.day,
      ).toIso8601String(),
      'text': text.trim(),
    };
    final updated = [entry, ..._capsules];
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_capsulesKey, jsonEncode(updated));
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
                  height: 110,
                  child: ListView.builder(
                    itemCount: _dreams.length.clamp(0, 4).toInt(),
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
      await _saveCapsule(text, unlockDate);
    }
  }

  Future<void> _showCapsules() async {
    final now = DateTime.now();
    final due = _capsules.where((item) {
      final raw = item['unlockAt']?.toString();
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
                    final raw = item['unlockAt']?.toString() ?? '';
                    final date = DateTime.tryParse(raw);
                    final available = date != null && !date.isAfter(now);
                    return ListTile(
                      leading: Icon(
                        available ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                        color: AppColors.primaryGold,
                      ),
                      title: Text(
                        available ? (item['text'] ?? '').toString() : 'رسالة مؤجلة',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                      subtitle: Text('تاريخ الفتح: ${raw.isEmpty ? 'غير محدد' : raw}'),
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
            'محاكاة الترابط الكمي',
            'شرح تعليمي فقط؛ لا يوجد محرك فيزيائي',
            Icons.hub_outlined,
            () => _showHonestStatus(
              'محاكاة تعليمية',
              'هذه الشاشة لا تنفّذ محاكاة كمومية أو قياسات فيزيائية. '
              'يمكن إضافة نموذج رياضي موثّق لاحقًا، ولا ينبغي تفسير هذا الوصف على أنه تجربة علمية.',
            ),
          ),
          _buildCard(
            'الصوت والتركيز',
            'لا يوجد مولّد ترددات علاجي مفعّل',
            Icons.graphic_eq_rounded,
            () => _showHonestStatus(
              'الصوت والتركيز',
              'لا يتم توليد ترددات أو ادعاء تأثير علاجي في هذه الشاشة. '
              'يمكن استخدام مشغل التلاوة الموجود في التطبيق للاستماع إلى التلاوات المتاحة.',
            ),
          ),
          _buildCard(
            'المعلومات الفلكية',
            'مصدر بيانات فلكية غير مهيأ',
            Icons.public_rounded,
            () => _showHonestStatus(
              'المعلومات الفلكية',
              'لم يتم إعداد مصدر إحداثيات أو تقويم فلكي موثوق هنا؛ لذلك لا تُعرض مواقع كواكب أو مزامنات مفترضة.',
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
