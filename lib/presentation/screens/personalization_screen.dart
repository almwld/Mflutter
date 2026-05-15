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
      appBar: AppBar(
        title: const Text('تخصيص', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // شخصية AI
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('🤖 شخصية المساعد', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: AIPersonalityService.personalityNames.map((name) {
                      final config = AIPersonalityService.getPersonalityConfig(name);
                      final isActive = AIPersonalityService.activePersonality == name;
                      return ChoiceChip(
                        label: Text('${config['name']} (${config['style']})', style: const TextStyle(fontSize: 11)),
                        selected: isActive,
                        selectedColor: AppColors.primaryGold,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(color: isActive ? AppColors.primaryNavy : Colors.white),
                        onSelected: (_) {
                          AIPersonalityService.switchPersonality(name);
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ذاكرة السياق
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('🧠 ملخص السياق', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(ContextMemoryService.getContextSummary(), style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // إشعارات
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🔔 إشعارات ذكية', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                      Switch(
                        value: SmartNotificationsService.enabled,
                        activeColor: AppColors.primaryGold,
                        onChanged: (v) {
                          SmartNotificationsService.toggle(v);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer(builder: (context, _, __) {
                    final insight = SmartNotificationsService.getCurrentInsight();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('الآن: ${insight['title']}', style: const TextStyle(color: Colors.white70)),
                        Text(insight['body'] ?? '', style: const TextStyle(color: Colors.white54)),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Consumer بسيط للاستخدام المحلي
class Consumer extends StatelessWidget {
  final Widget Function(BuildContext context, dynamic value, Widget? child) builder;
  const Consumer({super.key, required this.builder});
  
  @override
  Widget build(BuildContext context) {
    return builder(context, null, null);
  }
}
