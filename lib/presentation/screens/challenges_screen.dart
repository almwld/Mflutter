import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  static final List<Map<String, dynamic>> _challenges = [
    {'title': 'تدبر ٣ آيات', 'desc': 'اقرأ وتدبر ٣ آيات اليوم', 'xp': 50, 'progress': 0.66},
    {'title': 'اكتشف علماً جديداً', 'desc': 'استخدم ميزة العلوم', 'xp': 30, 'progress': 1.0},
    {'title': 'احسب ٥ جمل', 'desc': 'استخدم حاسبة الجمل', 'xp': 40, 'progress': 0.4},
    {'title': 'شارك آية', 'desc': 'شارك آية مع صديق', 'xp': 20, 'progress': 0.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('التحديات', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: _challenges.length,
        itemBuilder: (context, index) {
          final c = _challenges[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('+${c['xp']} XP', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                    Text(c['title']!, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 8),
                Text(c['desc']!, style: TextStyle(color: Colors.white54)),
                SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (c['progress'] as double),
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    c['progress'] == 1.0 ? AppColors.success : AppColors.primaryGold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
