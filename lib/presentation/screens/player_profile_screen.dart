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
      body: ListView(padding: EdgeInsets.all(16), children: [
        // رأس الملف
        Card(color: AppColors.surface, child: Padding(padding: EdgeInsets.all(24), child: Column(children: [
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
