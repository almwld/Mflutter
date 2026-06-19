import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static final List<Map<String, dynamic>> _leaders = [
    {'name': 'أحمد', 'score': 1250, 'level': 3, 'badge': '🌟'},
    {'name': 'فاطمة', 'score': 980, 'level': 3, 'badge': '⭐'},
    {'name': 'عمر', 'score': 750, 'level': 2, 'badge': '💫'},
    {'name': 'أنت', 'score': 520, 'level': 2, 'badge': '🔥'},
    {'name': 'سارة', 'score': 340, 'level': 1, 'badge': '🌱'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('المتصدرون', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: _leaders.length,
        itemBuilder: (context, index) {
          final leader = _leaders[index];
          final isMe = leader['name'] == 'أنت';
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primaryGold.withOpacity(0.1) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: isMe ? Border.all(color: AppColors.primaryGold, width: 2) : null,
            ),
            child: Row(
              children: [
                Text('${index + 1}', style: TextStyle(color: index < 3 ? AppColors.primaryGold : Colors.white54, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                Text(leader['badge']!, style: TextStyle(fontSize: 28)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(leader['name']!, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('المستوى ${leader['level']}', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
                Text('${leader['score']}', style: TextStyle(color: AppColors.primaryGold, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
