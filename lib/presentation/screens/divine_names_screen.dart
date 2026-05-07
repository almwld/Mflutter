import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// =============================================================================
/// DivineNamesScreen - شاشة الأسماء الحسنى
/// =============================================================================

class DivineNamesScreen extends StatefulWidget {
  const DivineNamesScreen({super.key});

  @override
  State<DivineNamesScreen> createState() => _DivineNamesScreenState();
}

class _DivineNamesScreenState extends State<DivineNamesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _names = _generateDivineNames();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static List<Map<String, dynamic>> _generateDivineNames() {
    return [
      {'number': 1, 'name': 'الله', 'meaning': 'الإله الحق', 'attribute': 'ذاته'},
      {'number': 2, 'name': 'الرحمن', 'meaning': 'ذو الرحمة الواسعة', 'attribute': 'الرحمة'},
      {'number': 3, 'name': 'الرحيم', 'meaning': 'ذو الرحمة المخصصة', 'attribute': 'الرحمة'},
      {'number': 4, 'name': 'الملك', 'meaning': 'ملك الملوك', 'attribute': 'الملك'},
      {'number': 5, 'name': 'القدوس', 'meaning': 'المتنزه عن النقائص', 'attribute': 'التقديس'},
      {'number': 6, 'name': 'السلام', 'meaning': 'المحروس من النقائص', 'attribute': 'الكمال'},
      {'number': 7, 'name': 'المؤمن', 'meaning': 'الموثوق', 'attribute': 'الأمان'},
      {'number': 8, 'name': 'المهيمن', 'meaning': 'الحافظ', 'attribute': 'الحفظ'},
      {'number': 9, 'name': 'العزيز', 'meaning': 'ذو العزة التامة', 'attribute': 'العزة'},
      {'number': 10, 'name': 'الجبار', 'meaning': 'القاهر لجميع الخلق', 'attribute': 'القهر'},
      {'number': 11, 'name': 'المتكبر', 'meaning': 'المتصف بالكبرياء', 'attribute': 'الكبرياء'},
      {'number': 12, 'name': 'الخالق', 'meaning': 'المبدع للأشياء', 'attribute': 'الخلق'},
      {'number': 13, 'name': 'البارئ', 'meaning': 'المصمم للأشياء', 'attribute': 'البرء'},
      {'number': 14, 'name': 'المصور', 'meaning': 'المصور للمخلوقات', 'attribute': 'الصورة'},
      {'number': 15, 'name': 'الغفار', 'meaning': 'كثير المغفرة', 'attribute': 'المغفرة'},
      {'number': 16, 'name': 'القهار', 'meaning': 'الغالب على جميع things', 'attribute': 'الغلب'},
      {'number': 17, 'name': 'الوهاب', 'meaning': 'كثير العطاء', 'attribute': 'العطاء'},
      {'number': 18, 'name': 'الرزاق', 'meaning': 'مسبب الرزق', 'attribute': 'الرزق'},
      {'number': 19, 'name': 'الفتاح', 'meaning': 'الفاتح للأبواب', 'attribute': 'الفتح'},
      {'number': 20, 'name': 'العليم', 'meaning': 'المحيط علماً', 'attribute': 'العلم'},
      {'number': 21, 'name': 'القابض', 'meaning': 'ماسك بالأرزاق', 'attribute': 'التصرف'},
      {'number': 22, 'name': 'الباسط', 'meaning': 'موسع للأرزاق', 'attribute': 'التصرف'},
      {'number': 23, 'name': 'الخفض', 'meaning': 'المذلل', 'attribute': 'التسخير'},
      {'number': 24, 'name': 'الرافع', 'meaning': 'المعلي', 'attribute': 'التسخير'},
      {'number': 25, 'name': 'المعز', 'meaning': 'المعطي العز', 'attribute': 'العز'},
      {'number': 26, 'name': 'المذل', 'meaning': 'المهين', 'attribute': 'التصرف'},
      {'number': 27, 'name': 'السميع', 'meaning': 'الذي يسمع كل شيء', 'attribute': 'السمع'},
      {'number': 28, 'name': 'البصير', 'meaning': 'الذي يبصر كل شيء', 'attribute': 'البصر'},
      {'number': 29, 'name': 'الحكم', 'meaning': 'الحاكم entre كل شيء', 'attribute': 'الحكم'},
      {'number': 30, 'name': 'العدل', 'meaning': 'المتصف بالعدل', 'attribute': 'العدل'},
      {'number': 31, 'name': 'اللطيف', 'meaning': 'الرياء في كل تدبيره', 'attribute': 'اللطف'},
      {'number': 32, 'name': 'الخبير', 'meaning': 'العليم بالسر والنجوى', 'attribute': 'الخبرة'},
      {'number': 33, 'name': 'الحليم', 'meaning': 'الذي لا يعجل', 'attribute': 'الحلم'},
      {'number': 34, 'name': 'العظيم', 'meaning': 'ذو العظمة البالغة', 'attribute': 'العظمة'},
      {'number': 35, 'name': 'الغفور', 'meaning': 'ذو المغفرة الواسعة', 'attribute': 'المغفرة'},
      {'number': 36, 'name': 'الشكور', 'meaning': 'ذو الشكر الكثير', 'attribute': 'الشكر'},
      {'number': 37, 'name': 'العلير', 'meaning': 'ذو العظمة البالغة', 'attribute': 'العظمة'},
      {'number': 38, 'name': 'الغني', 'meaning': 'ذو الغنى المطلق', 'attribute': 'الغنى'},
      {'number': 39, 'name': 'المغني', 'meaning': 'مغني عباده', 'attribute': 'الغنى'},
      {'number': 40, 'name': 'النور', 'meaning': 'ذو النور', 'attribute': 'النور'},
      {'number': 41, 'name': 'الهادي', 'meaning': 'المرشد', 'attribute': 'الهدي'},
      {'number': 42, 'name': 'البديع', 'meaning': 'المستحدث للأشياء', 'attribute': 'البداعة'},
      {'number': 43, 'name': 'الواب', 'meaning': 'كثير الخير', 'attribute': 'الخير'},
      {'number': 44, 'name': 'الرؤوف', 'meaning': 'ذو الرأفة', 'attribute': 'الرأفة'},
      {'number': 45, 'name': 'الجليل', 'meaning': 'ذو الجلال', 'attribute': 'الجلال'},
      {'number': 46, 'name': 'الكريم', 'meaning': 'ذو الجود', 'attribute': 'الجود'},
      {'number': 47, 'name': 'الرقيب', 'meaning': 'المراقب لكل شيء', 'attribute': 'الرقابة'},
      {'number': 48, 'name': 'المجيب', 'meaning': 'مجيب الدعوات', 'attribute': 'الإجابة'},
      {'number': 49, 'name': 'الواسع', 'meaning': 'ذو السعة في كل شيء', 'attribute': 'السعة'},
      {'number': 50, 'name': 'الحكيم', 'meaning': 'ذو الحكمة', 'attribute': 'الحكمة'},
      {'number': 51, 'name': 'الودود', 'meaning': 'ذو المودة', 'attribute': 'المودة'},
      {'number': 52, 'name': 'المجيد', 'meaning': 'ذو المجد', 'attribute': 'المجد'},
      {'number': 53, 'name': 'الباعث', 'meaning': 'محيي الموتى', 'attribute': 'الإحياء'},
      {'number': 54, 'name': 'الشهيد', 'meaning': 'حاضر غير غائب', 'attribute': 'الشهادة'},
      {'number': 55, 'name': 'الحق', 'meaning': 'الصدق في كل قول', 'attribute': 'الحق'},
      {'number': 56, 'name': 'الوكيل', 'meaning': 'الكفيل بالخلق', 'attribute': 'الوكالة'},
      {'number': 57, 'name': 'القوي', 'meaning': 'ذو القوة التامة', 'attribute': 'القوة'},
      {'number': 58, 'name': 'المتين', 'meaning': 'ذو المتانة', 'attribute': 'المتانة'},
      {'number': 59, 'name': 'الولي', 'meaning': 'الناصر للمؤمنين', 'attribute': 'الولاية'},
      {'number': 60, 'name': 'المهيمن', 'meaning': 'الحافظ', 'attribute': 'الحفظ'},
      {'number': 61, 'name': 'العزيز', 'meaning': 'ذو العزة', 'attribute': 'العزة'},
      {'number': 62, 'name': 'الجبار', 'meaning': 'القاهر', 'attribute': 'القهر'},
      {'number': 63, 'name': 'المتكبر', 'meaning': 'المتصف بالكبرياء', 'attribute': 'الكبرياء'},
      {'number': 64, 'name': 'السبوق', 'meaning': 'السريع', 'attribute': 'السرعة'},
      {'number': 65, 'name': 'التواب', 'meaning': 'كثير قبول التوبة', 'attribute': 'التوبة'},
      {'number': 66, 'name': 'المنتقم', 'meaning': 'ذو الانتقام', 'attribute': 'الانتقام'},
      {'number': 67, 'name': 'العفو', 'meaning': 'ذو العفو', 'attribute': 'العفو'},
      {'number': 68, 'name': 'الرؤوف', 'meaning': 'ذو الرأفة', 'attribute': 'الرأفة'},
      {'number': 69, 'name': 'مالك الملك', 'meaning': 'ملك everything', 'attribute': 'الملك'},
      {'number': 70, 'name': 'ذو الجلال والإكرام', 'meaning': 'ذو العظمة والإحسان', 'attribute': 'الجلال'},
      {'number': 71, 'name': 'الموعظ', 'meaning': 'الذي يرشد إلى الخير', 'attribute': 'الموعظة'},
      {'number': 72, 'name': 'التواب', 'meaning': 'المتوصل إلى كل توبة', 'attribute': 'التوبة'},
      {'number': 73, 'name': 'المنتقم', 'meaning': 'ذو الانتقام من أعدائه', 'attribute': 'الانتقام'},
      {'number': 74, 'name': 'العفو', 'meaning': 'ذو العفو عن ذنوب العباد', 'attribute': 'العفو'},
      {'number': 75, 'name': 'الرؤوف', 'meaning': 'البر الرحيم', 'attribute': 'الرأفة'},
      {'number': 76, 'name': 'ملك菊', 'meaning': 'المالك لكل شيء', 'attribute': 'الملك'},
      {'number': 77, 'name': 'السلام', 'meaning': 'المحروس من كل عيب', 'attribute': 'الكمال'},
      {'number': 78, 'name': 'المؤمن', 'meaning': 'المصدق عباده', 'attribute': 'الإيمان'},
      {'number': 79, 'name': 'المهيمن', 'meaning': 'الحافظ لأوليائه', 'attribute': 'الحفظ'},
      {'number': 80, 'name': 'العزيز', 'meaning': 'المتصف بالعزة', 'attribute': 'العزة'},
      {'number': 81, 'name': 'الجبار', 'meaning': 'القاهر لعباده', 'attribute': 'القهر'},
      {'number': 82, 'name': 'المتكبر', 'meaning': 'المتعالي عن الظلم', 'attribute': 'التعالي'},
      {'number': 83, 'name': 'الخالق', 'meaning': 'المبدع for everything', 'attribute': 'الخلق'},
      {'number': 84, 'name': 'البارئ', 'meaning': 'المصمم للأشياء', 'attribute': 'البرء'},
      {'number': 85, 'name': 'المصور', 'meaning': 'المصور للمخلوقات', 'attribute': 'الصورة'},
      {'number': 86, 'name': 'الغفار', 'meaning': 'المغفر لذنوب عباده', 'attribute': 'المغفرة'},
      {'number': 87, 'name': 'القهار', 'meaning': 'القاهر لكل', 'attribute': 'القهر'},
      {'number': 88, 'name': 'الوهاب', 'meaning': 'كثير العطاء', 'attribute': 'العطاء'},
      {'number': 89, 'name': 'الرزاق', 'meaning': 'مسبب الرزق للخلق', 'attribute': 'الرزق'},
      {'number': 90, 'name': 'الفتاح', 'meaning': 'الذي يفتح للخير', 'attribute': 'الفتح'},
      {'number': 91, 'name': 'العليم', 'meaning': 'المحيط بالعلم', 'attribute': 'العلم'},
      {'number': 92, 'name': 'القابض', 'meaning': 'ماسك everything', 'attribute': 'التصرف'},
      {'number': 93, 'name': 'الباسط', 'meaning': 'موسع everything', 'attribute': 'التصرف'},
      {'number': 94, 'name': 'الخفض', 'meaning': 'المذلل للخلق', 'attribute': 'التسخير'},
      {'number': 95, 'name': 'الرافع', 'meaning': 'المعلي للخلق', 'attribute': 'التسخير'},
      {'number': 96, 'name': 'المعز', 'meaning': 'المعطي للعز', 'attribute': 'العز'},
      {'number': 97, 'name': 'المذل', 'meaning': 'المهين للخلق', 'attribute': 'التصرف'},
      {'number': 98, 'name': 'السميع', 'meaning': 'الذي يسمع everything', 'attribute': 'السمع'},
      {'number': 99, 'name': 'البصير', 'meaning': 'الذي يبصر everything', 'attribute': 'البصر'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        title: const Text(
          'الأسماء الحسنى',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'الرحمة'),
            Tab(text: 'العظمة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNamesList(_names),
          _buildNamesList(_names.where((n) => n['attribute'] == 'الرحمة').toList()),
          _buildNamesList(_names.where((n) => n['attribute'] == 'العظمة').toList()),
        ],
      ),
    );
  }

  Widget _buildNamesList(List<Map<String, dynamic>> names) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: names.length,
      itemBuilder: (context, index) {
        return _buildNameCard(names[index]);
      },
    );
  }

  Widget _buildNameCard(Map<String, dynamic> name) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNavy.withOpacity(0.8),
            AppColors.primaryNavy.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${name['number']}',
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ),
        ),
        title: Text(
          name['name'] as String,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              name['meaning'] as String,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                name['attribute'] as String,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.favorite, color: AppColors.gold, size: 20),
      ),
    );
  }
}