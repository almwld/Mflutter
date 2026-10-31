import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/reading_progress_service.dart';
import 'quran/mushaf_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<List<dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<List<dynamic>> _loadStats() => Future.wait<dynamic>([
        ReadingProgressService.getLastPage(),
        ReadingProgressService.getKhatmahProgress(),
        ReadingProgressService.getPagesRead(),
        ReadingProgressService.getCurrentStreak(),
        ReadingProgressService.getReadingDays(),
        ReadingProgressService.getReadingDaysInLast7Days(),
      ]);

  void _retry() => setState(() => _statsFuture = _loadStats());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'إحصائيات الرحلة',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.redAccent, size: 34),
                    const SizedBox(height: 12),
                    Text(
                      'تعذر تحميل إحصاءات القراءة المحلية: ${snapshot.error}',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final lastPage = data[0] as int;
          final progress = data[1] as double;
          final pagesRead = data[2] as int;
          final streak = data[3] as int;
          final readingDays = data[4] as int;
          final readingDaysInLast7Days = data[5] as int;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _heroProgress(context, progress, lastPage),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  _statCard('صفحات تمت زيارتها', '$pagesRead / 604', Icons.menu_book),
                  _statCard('أيام القراءة آخر 7 أيام', '$readingDaysInLast7Days يوم', Icons.calendar_today),
                  _statCard('الاستمرار الحالي', '$streak يوم', Icons.local_fire_department),
                  _statCard('أيام القراءة', '$readingDays يوم', Icons.auto_awesome),
                ],
              ),
              const SizedBox(height: 18),
              _infoCard(
                title: 'آخر موضع قراءة',
                value: 'صفحة $lastPage',
                icon: Icons.bookmark_outline,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MushafScreen(
                        initialPage: lastPage,
                        restoreLastPage: false,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _infoCard(
                title: 'تغطية صفحات المصحف',
                value: '${(progress * 100).toStringAsFixed(1)}٪ من إجمالي صفحات المصحف',
                icon: Icons.track_changes,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _heroProgress(BuildContext context, double progress, int lastPage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: AppColors.primaryGold, size: 30),
              const Spacer(),
              Text(
                'تغطية الصفحات',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress.clamp(0.0, 1.0).toDouble(),
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخر صفحة: $lastPage',
                style: const TextStyle(color: Colors.white60),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}٪',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 26),
          const Spacer(),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.primaryGold,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: onTap == null
              ? null
              : Border.all(color: AppColors.primaryGold.withOpacity(.22)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGold),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white70)),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_left_rounded, color: AppColors.primaryGold),
            ],
          ],
        ),
      ),
    );
  }
}
