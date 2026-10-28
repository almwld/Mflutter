import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/local_activity_summary_service.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('أهداف القراءة', style: TextStyle(color: AppColors.primaryGold)),
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
                  'تعذر تحميل تقدمك المحلي. أعد فتح الشاشة للمحاولة.',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            );
          }
          final activity = snapshot.data!;
          final goals = <({String title, String description, int current, int target})>[
            (
              title: 'زيارة 10 صفحات من المصحف',
              description: 'تُحتسب الصفحات التي فتحتها داخل التطبيق.',
              current: activity.pagesRead,
              target: 10,
            ),
            (
              title: 'حفظ 5 آيات في المفضلة',
              description: 'تُحتسب الآيات المحفوظة محليًا.',
              current: activity.bookmarkCount,
              target: 5,
            ),
            (
              title: 'القراءة في 7 أيام مختلفة',
              description: 'تُحتسب أيام القراءة المسجلة على هذا الجهاز.',
              current: activity.readingDays,
              target: 7,
            ),
            (
              title: 'بناء سلسلة قراءة من 3 أيام',
              description: 'تُحتسب الأيام المتتالية حتى اليوم.',
              current: activity.currentStreak,
              target: 3,
            ),
          ];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (activity.warnings.isNotEmpty)
                _activityWarning(activity.warnings),
              const Text(
                'أهداف شخصية مبنية على نشاطك الفعلي',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: AppColors.primaryGold, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'لا توجد نقاط خبرة أو مكافآت مصطنعة. يتحدث التقدم من سجل القراءة والمفضلة المحلي.',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              for (final goal in goals)
                _goalCard(
                  title: goal.title,
                  description: goal.description,
                  current: goal.current,
                  target: goal.target,
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

  Widget _goalCard({
    required String title,
    required String description,
    required int current,
    required int target,
  }) {
    final progress = (current / target).clamp(0.0, 1.0).toDouble();
    final complete = current >= target;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(
              complete ? AppColors.success : AppColors.primaryGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            complete ? 'اكتمل الهدف' : '$current / $target',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: complete ? AppColors.success : Colors.white70),
          ),
        ],
      ),
    );
  }
}
