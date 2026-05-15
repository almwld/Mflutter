import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ai_personality_service.dart';
import '../../services/context_memory_service.dart';
import '../../services/smart_notifications_service.dart';
import '../../services/widget_system_service.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});
  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('تخصيص', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy),
      body: ListView(padding: EdgeInsets.all(16), children: [
        // شخصية AI
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🤖 شخصية المساعد', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Wrap(spacing: 8, children: AIPersonalityService.personalityNames.map((name) {
            final config = AIPersonalityService._personalities[name]!;
            final isActive = AIPersonalityService.activePersonality == name;
            return ChoiceChip(
              label: Text('${config['name']} (${config['style']})'),
              selected: isActive,
              selectedColor: AppColors.primaryGold,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(color: isActive ? AppColors.primaryNavy : Colors.white, fontSize: 11),
              onSelected: (_) { AIPersonalityService.switchPersonality(name); setState(() {}); },
            );
          }).toList()),
        ]))),
        // ذاكرة السياق
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🧠 ملخص السياق', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(ContextMemoryService.getContextSummary(), style: TextStyle(color: Colors.white70)),
          SizedBox(height: 8),
          ...ContextMemoryService.getTopicStats().entries.take(3).map((e) => Text('${e.key}: ${e.value} مرة', style: TextStyle(color: Colors.white54))),
          if (ContextMemoryService.getRecentQuestions().isNotEmpty) ...[
            SizedBox(height: 8),
            Text('آخر الأسئلة:', style: TextStyle(color: Colors.white54)),
            ...ContextMemoryService.getRecentQuestions().take(3).map((q) => Text('• $q', style: TextStyle(color: Colors.white38, fontSize: 12))),
          ],
        ]))),
        // إشعارات
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('🔔 إشعارات ذكية', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
            Switch(value: SmartNotificationsService.enabled, activeColor: AppColors.primaryGold, onChanged: (v) { SmartNotificationsService.toggle(v); setState(() {}); }),
          ]),
          SizedBox(height: 8),
          final insight = SmartNotificationsService.getCurrentInsight();
          Text('الآن: ${insight['title']}', style: TextStyle(color: Colors.white70)),
          Text(insight['body']!, style: TextStyle(color: Colors.white54)),
        ]))),
        // نظام الودجتس
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🧩 الودجتس', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...WidgetSystemService.widgets.map((w) => SwitchListTile(
            value: w['active'],
            activeColor: AppColors.primaryGold,
            title: Text('${w['icon']} ${w['name']}', style: TextStyle(color: Colors.white)),
            subtitle: Text(w['size'], style: TextStyle(color: Colors.white54)),
            onChanged: (_) { WidgetSystemService.toggleWidget(w['id']); setState(() {}); },
          )),
        ]))),
      ]),
    );
  }
}
