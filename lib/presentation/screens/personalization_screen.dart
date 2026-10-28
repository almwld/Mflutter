import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ai_personality_service.dart';
import '../../services/context_memory_service.dart';
import '../../services/smart_notifications_service.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});
  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      await Future.wait([
        AIPersonalityService.loadSavedPersonality(),
        SmartNotificationsService.loadPreferences(),
        ContextMemoryService.loadSavedMemory(),
      ]);
      if (!mounted) return;
      setState(() { _loading = false; _loadError = null; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _loading = false; _loadError = error.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('التخصيص', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline, color: Colors.orangeAccent, size: 32),
                    const SizedBox(height: 12),
                    Text('تعذر تحميل تفضيلات التخصيص المحلية: ' + _loadError!, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () { setState(() => _loading = true); _loadPreferences(); },
                      icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة'),
                    ),
                  ]),
                ))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _panel(
                      title: 'شخصية المساعد', icon: Icons.tune_rounded,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        const Text('اختر نمط التنسيق المستخدم في ردود الخدمة الحالية. هذا الخيار لا يغيّر أوزان النموذج المحلي ولا يضمن تغيير أسلوب توليد GGUF ما لم يستهلكه مسار المحادثة.', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: 8, children: AIPersonalityService.personalityNames.map((name) {
                          final config = AIPersonalityService.getPersonalityConfig(name);
                          final selected = AIPersonalityService.activePersonality == name;
                          return ChoiceChip(
                            label: Text((config['name'] ?? name) + ' — ' + (config['style'] ?? '')),
                            selected: selected, selectedColor: AppColors.primaryGold, backgroundColor: AppColors.background,
                            labelStyle: TextStyle(color: selected ? AppColors.primaryNavy : Colors.white),
                            onSelected: (_) { AIPersonalityService.switchPersonality(name); setState(() {}); },
                          );
                        }).toList(growable: false)),
                        const SizedBox(height: 8),
                        Text('التحية: ' + (AIPersonalityService.activeConfig['greeting'] ?? ''), textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white54)),
                        const SizedBox(height: 4),
                        const Text('يُحفظ الاختيار على هذا الجهاز.', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    _panel(
                      title: 'ملخص ذاكرة السياق', icon: Icons.psychology_alt_rounded,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Text(ContextMemoryService.getContextSummary(), textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        const Text('تعكس هذه الأرقام الذاكرة المتاحة للخدمة في جلسة التشغيل الحالية؛ لا تُعرض على أنها سجل دائم بين مرات تشغيل التطبيق.', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white54, fontSize: 12)),
                        if (ContextMemoryService.getRecentQuestions().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text('الأسئلة الأخيرة', textDirection: TextDirection.rtl, style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          ...ContextMemoryService.getRecentQuestions().take(5).map((question) => ListTile(
                            dense: true, contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.history, color: Colors.white54),
                            title: Text(question, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white70)),
                          )),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 12),
                    _panel(
                      title: 'اقتراحات داخل التطبيق', icon: Icons.lightbulb_outline_rounded,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('عرض الاقتراح اليومي', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white)),
                          subtitle: const Text('هذا مفتاح لعرض الاقتراح داخل الواجهة، وليس جدولة إشعارات نظام التشغيل.', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white54, fontSize: 12)),
                          value: SmartNotificationsService.enabled, activeColor: AppColors.primaryGold,
                          onChanged: (value) { SmartNotificationsService.toggle(value); setState(() {}); },
                        ),
                        if (SmartNotificationsService.enabled) ...[
                          const Divider(color: Colors.white12),
                          Text('الاقتراح الحالي: ' + (SmartNotificationsService.getCurrentInsight()['title'] ?? ''), textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(SmartNotificationsService.getCurrentInsight()['body'] ?? '', textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white70)),
                        ],
                      ]),
                    ),
                  ],
                ),
    );
  }

  Widget _panel({required String title, required IconData icon, required Widget child}) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(icon, color: AppColors.primaryGold), const SizedBox(width: 8),
            Expanded(child: Text(title, textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 12), child,
        ]),
      ),
    );
  }
}
