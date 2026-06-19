import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('حول التطبيق', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, size: 80, color: AppColors.primaryGold),
              SizedBox(height: 24),
              Text('مُدَبِّر الْأَسْرَارِ الْعُلْيَا', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('الإصدار 1.0.0', style: TextStyle(color: Colors.white54, fontSize: 16)),
              SizedBox(height: 32),
              Text('نظام ذكاء اصطناعي قرآني متكامل', style: TextStyle(color: Colors.white70, fontSize: 18)),
              SizedBox(height: 16),
              Text('• 114 سورة | 42 علماً | 99 صفة', style: TextStyle(color: Colors.white54)),
              Text('• 1000 شبكة عصبية | 4096 ميزة', style: TextStyle(color: Colors.white54)),
              Text('• يعمل بدون إنترنت', style: TextStyle(color: Colors.white54)),
              SizedBox(height: 40),
              Text('﴿وَفَوْقَ كُلِّ ذِي عِلْمٍ عَلِيمٌ﴾', style: TextStyle(color: AppColors.primaryGold, fontSize: 20, fontFamily: 'Amiri')),
            ],
          ),
        ),
      ),
    );
  }
}
