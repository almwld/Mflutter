import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/local_activity_summary_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('التصدر والإنجاز', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: FutureBuilder<LocalActivitySummary>(
        future: const LocalActivitySummaryService().load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'تعذر تحميل إنجازاتك المحلية.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }
          final activity = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (activity.warnings.isNotEmpty)
                _activityWarning(activity.warnings),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('لوحة المتصدرين الجماعية غير متاحة بعد', textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(
                      'لا يوجد حاليًا خادم يجمع نقاط المستخدمين ويزامنها؛ لذلك لا نعرض أسماء أو درجات افتراضية على أنها بيانات حقيقية.',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'إنجازك على هذا الجهاز',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: AppColors.primaryGold, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _stat('الصفحات التي زرتها', '${activity.pagesRead}'),
              _stat('الآيات المحفوظة', '${activity.bookmarkCount}'),
              _stat('أيام القراءة', '${activity.readingDays}'),
              _stat('سلسلة القراءة الحالية', '${activity.currentStreak} يوم'),
              const SizedBox(height: 12),
              const Text(
                'هذه الإحصاءات محلية ولا تُرسل إلى أي جهة.',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.white54),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _activityWarning(List<String> warnings) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(.35)),
        ),
        child: Text(
          'بعض المؤشرات غير مكتملة:\n${warnings.join('\n')}',
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: Colors.orangeAccent, height: 1.5),
        ),
      );

  Widget _stat(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          Flexible(
            child: Text(label, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
