import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/multi_user_service.dart';
import '../../services/achievements_service.dart';
import '../../services/daily_streak_service.dart';
import '../../services/cloud_sync_service.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});
  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final errors = <String>[];
    try {
      await MultiUserService.initialize();
    } catch (error) {
      errors.add('الملفات المحلية: $error');
    }
    try {
      await DailyStreakService.initialize();
    } catch (error) {
      errors.add('التتابع اليومي: $error');
    }
    try {
      await AchievementsService.refreshFromLocalActivity();
    } catch (error) {
      errors.add('الإنجازات: $error');
    }
    try {
      await CloudSyncService.restore();
    } catch (error) {
      errors.add('نقطة الحفظ المحلية: $error');
    }
    if (!mounted) return;
    setState(() {});
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('بعض بيانات الملف لم تُحمّل بالكامل: ${errors.join('؛ ')}'),
        ),
      );
    }
  }

  Future<void> _addProfile() async {
    final nameController = TextEditingController();
    final avatarController = TextEditingController(text: '📖');
    final formKey = GlobalKey<FormState>();
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إنشاء ملف محلي'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                autofocus: true,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'اسم الملف'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'أدخل اسمًا للملف'
                        : null,
              ),
              TextFormField(
                controller: avatarController,
                maxLength: 8,
                decoration: const InputDecoration(
                  labelText: 'رمز الملف (اختياري)',
                  hintText: '📖',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
    if (created != true) {
      nameController.dispose();
      avatarController.dispose();
      return;
    }
    try {
      await MultiUserService.addProfile(
        nameController.text,
        avatarController.text.trim(),
      );
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الملف المحلي الجديد.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إنشاء الملف: $error')),
      );
    } finally {
      nameController.dispose();
      avatarController.dispose();
    }
  }

  Future<void> _switchProfile(int index) async {
    try {
      await MultiUserService.switchProfile(index);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التبديل إلى ${MultiUserService.activeProfile['name']}.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تبديل الملف: $error')),
      );
    }
  }

  Future<void> _saveLocalCheckpoint() async {
    try {
      final saved = await CloudSyncService.sync();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'تم تسجيل وقت الحفظ فقط؛ لم تُنسخ بيانات التطبيق ولا توجد مزامنة سحابية مهيأة.'
                : CloudSyncService.status,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تسجيل وقت الحفظ المحلي: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = MultiUserService.activeProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: AppColors.primaryNavy,
        actions: [
          IconButton(
            tooltip: 'تسجيل وقت الحفظ المحلي',
            icon: Icon(
              Icons.save_outlined,
              color: CloudSyncService.isSyncing
                  ? AppColors.primaryGold
                  : Colors.white54,
            ),
            onPressed: CloudSyncService.isSyncing ? null : _saveLocalCheckpoint,
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'الملفات المحلية',
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                for (var index = 0; index < MultiUserService.profiles.length; index++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      (MultiUserService.profiles[index]['avatar'] as String?) ?? '',
                      style: const TextStyle(fontSize: 26),
                    ),
                    title: Text(
                      (MultiUserService.profiles[index]['name'] as String?) ?? 'ملف محلي',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'المستوى ${MultiUserService.profiles[index]['level']} • ${MultiUserService.profiles[index]['xp']} XP',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: index == MultiUserService.activeProfileIndex
                        ? const Icon(Icons.check_circle, color: AppColors.primaryGold)
                        : const Icon(Icons.radio_button_unchecked, color: Colors.white38),
                    onTap: () => _switchProfile(index),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: MultiUserService.profiles.length >= 20 ? null : _addProfile,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('إضافة ملف محلي'),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'هذه ملفات محلية على هذا الجهاز وليست حسابات تسجيل دخول أو مزامنة سحابية.',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        // رأس الملف
        Card(color: AppColors.surface, child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          Text(profile['avatar'], style: TextStyle(fontSize: 64)),
          SizedBox(height: 12),
          Text(profile['name'], style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('المستوى ${profile['level']} | ${profile['xp']} XP', style: TextStyle(color: AppColors.primaryGold, fontSize: 16)),
          SizedBox(height: 12),
          LinearProgressIndicator(value: (profile['xp'] % 250) / 250, backgroundColor: AppColors.surface, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold)),
        ]))),
        // التتابع اليومي
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(children: [
          Text('${DailyStreakService.getStreakEmoji()} التتابع اليومي', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('${DailyStreakService.streak} يوم متتالي', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: DailyStreakService.weekHistory.map((active) => Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.primaryGold : AppColors.surface, border: Border.all(color: AppColors.primaryGold.withOpacity(0.3))), child: Center(child: Text(active ? '✓' : '', style: TextStyle(color: AppColors.primaryNavy))))).toList()),
        ]))),
        // الإنجازات
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('🏆 الإنجازات (${AchievementsService.unlockedCount}/${AchievementsService.achievements.length})', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...AchievementsService.achievements.map((a) => ListTile(
            leading: Text(a['icon'], style: TextStyle(fontSize: 24)),
            title: Text(a['title'], style: TextStyle(color: a['unlocked'] ? Colors.white : Colors.white38)),
            subtitle: a['unlocked']
                ? const Text('مكتمل', style: TextStyle(color: AppColors.success))
                : a['tracking'] != true
                    ? const Text('قياس هذا الإنجاز غير موصول بعد', style: TextStyle(color: Colors.white38))
                    : LinearProgressIndicator(
                        value: (a['progress'] as num).toDouble(),
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                      ),
            trailing: a['unlocked'] ? Icon(Icons.check_circle, color: AppColors.primaryGold) : null,
          )),
        ]))),
        // Local checkpoint only; no remote sync backend is configured.
        Card(
          color: AppColors.surface,
          child: ListTile(
            leading: Icon(
              Icons.save_outlined,
              color: CloudSyncService.lastSync != null
                  ? AppColors.primaryGold
                  : Colors.white54,
            ),
            title: const Text(
              'علامة وقت الحفظ المحلي',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              CloudSyncService.lastSync != null
                  ? 'آخر علامة وقت: ${CloudSyncService.lastSync.toString().substring(0, 16)} • ${CloudSyncService.status}'
                  : CloudSyncService.status,
              style: const TextStyle(color: Colors.white54),
            ),
            trailing: CloudSyncService.isSyncing
                ? const CircularProgressIndicator(color: AppColors.primaryGold)
                : const Icon(Icons.save_outlined),
            onTap: CloudSyncService.isSyncing ? null : _saveLocalCheckpoint,
          ),
        ),
      ]),
    );
  }
}
