import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// =============================================================================
/// InsightScreen - شاشة أسئلة البصيرة
/// =============================================================================

class InsightScreen extends StatefulWidget {
  const InsightScreen({super.key});

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'الكل', 'icon': Icons.all_inclusive, 'count': 50},
    {'name': 'التأمل', 'icon': Icons.self_improvement, 'count': 15},
    {'name': 'القرآن', 'icon': Icons.menu_book, 'count': 10},
    {'name': 'العلوم', 'icon': Icons.science, 'count': 15},
    {'name': 'الحكمة', 'icon': Icons.lightbulb, 'count': 10},
  ];

  final List<Map<String, dynamic>> _insights = _generateInsights();

  static List<Map<String, dynamic>> _generateInsights() {
    return [
      {
        'question': 'ما هو السر المخفي في الرقم 19؟',
        'category': 'القرآن',
        'difficulty': 'صعب',
        'hint': 'اربط بين سورة المدثر وجمل الحروف',
      },
      {
        'question': 'كيف تؤثر العناصر الأربعة على تصرفاتك؟',
        'category': 'العلوم',
        'difficulty': 'متوسط',
        'hint': 'فكر في طبيعة الماء والنار',
      },
      {
        'question': 'ما العلاقة بين الأسماء الحسنى والابتهاج؟',
        'category': 'التأمل',
        'difficulty': 'سهل',
        'hint': 'التفكر في معاني الأسماء',
      },
      {
        'question': 'لماذا كان العدد 7 مقدساً في كل الأديان؟',
        'category': 'الحكمة',
        'difficulty': 'صعب',
        'hint': 'العد التنازلي والتسبيح',
      },
      {
        'question': 'ما سر البسملة في بداية كل سورة؟',
        'category': 'القرآن',
        'difficulty': 'متوسط',
        'hint': 'الربط بين البركة والحماية',
      },
      {
        'question': 'كيف يحسب الجُمَّل اسمك؟',
        'category': 'العلوم',
        'difficulty': 'سهل',
        'hint': 'استخدم جدول الجُمَّل',
      },
      {
        'question': 'ما الفرق بين علم الأبراج وعلم الحروف؟',
        'category': 'الحكمة',
        'difficulty': 'متوسط',
        'hint': 'التفريق بين التأثير الظاهر والباطن',
      },
      {
        'question': 'كيف تؤثر الكواكب على صحتك؟',
        'category': 'التأمل',
        'difficulty': 'صعب',
        'hint': 'ربط العناصر بالكواكب',
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text(
          'أسئلة البصيرة',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.white70,
          tabs: _categories.map((cat) {
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat['icon'] as IconData, size: 18),
                  const SizedBox(width: 4),
                  Text(cat['name'] as String),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((cat) {
          return _buildInsightsList(cat['name'] as String);
        }).toList(),
      ),
      floatingActionButton: _buildRandomInsightButton(),
    );
  }

  Widget _buildInsightsList(String category) {
    final filteredInsights = category == 'الكل'
        ? _insights
        : _insights.where((i) => i['category'] == category).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: filteredInsights.length,
      itemBuilder: (context, index) {
        return _buildInsightCard(filteredInsights[index]);
      },
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    final difficultyColors = {
      'سهل': Colors.green,
      'متوسط': Colors.orange,
      'صعب': Colors.red,
    };
    final color = difficultyColors[insight['difficulty']] ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNavy.withOpacity(0.4),
            AppColors.primaryNavy.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showInsightDetails(insight),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        insight['difficulty'] as String,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        insight['category'] as String,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  insight['question'] as String,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 14,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'تلميح: ${insight['hint']}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInsightDetails(Map<String, dynamic> insight) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: const BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              Text(
                insight['question'] as String,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Column(
                  children: [
                    const Text(
                      'التلميح',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insight['hint'] as String,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'فهمت',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRandomInsightButton() {
    return FloatingActionButton(
      onPressed: _showRandomInsight,
      backgroundColor: AppColors.gold,
      child: const Icon(
        Icons.shuffle,
        color: AppColors.primaryNavy,
      ),
    );
  }

  void _showRandomInsight() {
    final randomInsight = _insights[(DateTime.now().millisecond) % _insights.length];
    _showInsightDetails(randomInsight);
  }
}