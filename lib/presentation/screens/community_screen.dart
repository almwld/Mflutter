import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/local_activity_summary_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late Future<LocalActivitySummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = const LocalActivitySummaryService().load();
  }

  void _retry() {
    setState(() => _summaryFuture = const LocalActivitySummaryService().load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المجتمع والتدبر', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: FutureBuilder<LocalActivitySummary>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تعذر تحميل إحصاءات القراءة المحلية.\n${snapshot.error ?? ''}',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
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
              const Text(
                'نشاطك المحلي',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: AppColors.primaryGold, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'هذه الأرقام محفوظة على جهازك فقط، وليست إحصاءات جماعية أو بيانات مستخدمين آخرين.',
                textDirection: TextDirection.rtl,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _statCard('الصفحات التي زرتها', '${activity.pagesRead} / 604'),
              _statCard('الأيام التي قرأت فيها', '${activity.readingDays}'),
              _statCard('سلسلة القراءة الحالية', '${activity.currentStreak} يوم'),
              _statCard('الآيات المحفوظة', '${activity.bookmarkCount}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('تقدم الختمة المحلي', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: activity.khatmahProgress,
                      backgroundColor: AppColors.background,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(activity.khatmahProgress * 100).toStringAsFixed(1)}% وفق الصفحات التي زرتها داخل التطبيق',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('المجتمع المباشر', style: TextStyle(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'لم يتم ربط هذه الشاشة بعد بخدمة مجتمع وخادم إحصاءات مشترك؛ لذلك لا نعرض أعداد مستخدمين أو آيات متداولة وهمية.',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
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

  Widget _statCard(String title, String value) {
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
            child: Text(title, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
