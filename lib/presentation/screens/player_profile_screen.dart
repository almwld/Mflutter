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
    DailyStreakService.recordActivity();
  }

  @override
  Widget build(BuildContext context) {
    final profile = MultiUserService.activeProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('الملف الشخصي', style: TextStyle(color: AppColors.primaryGold)), backgroundColor: AppColors.primaryNavy, actions: [
        IconButton(icon: Icon(Icons.sync, color: CloudSyncService.isSyncing ? AppColors.primaryGold : Colors.white54), onPressed: () async { await CloudSyncService.sync(); setState(() {}); }),
      ]),
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
            subtitle: a['unlocked'] ? Text('✅ مكتمل', style: TextStyle(color: AppColors.success)) : LinearProgressIndicator(value: a['progress'], backgroundColor: AppColors.surface, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold)),
            trailing: a['unlocked'] ? Icon(Icons.check_circle, color: AppColors.primaryGold) : null,
          )),
        ]))),
        // المزامنة
        Card(color: AppColors.surface, child: ListTile(
          leading: Icon(Icons.cloud, color: CloudSyncService.lastSync != null ? AppColors.primaryGold : Colors.white54),
          title: Text('المزامنة السحابية', style: TextStyle(color: Colors.white)),
          subtitle: Text(CloudSyncService.lastSync != null ? 'آخر مزامنة: ${CloudSyncService.lastSync.toString().substring(0, 16)}' : 'لم تتم المزامنة بعد', style: TextStyle(color: Colors.white54)),
          trailing: CloudSyncService.isSyncing ? CircularProgressIndicator(color: AppColors.primaryGold) : Icon(Icons.sync),
          onTap: () async { await CloudSyncService.sync(); setState(() {}); },
        )),
      ]),
    );
  }
}
