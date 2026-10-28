import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../widgets/common/mudabbir_glass_panel.dart';
import '../templates/mudabbir_templates.dart';
import '../../core/themes/mudabbir_design_tokens.dart';
import '../../services/quran_numerical_analysis_service.dart';

class MiraclesScreen extends StatefulWidget {
  const MiraclesScreen({super.key});

  @override
  State<MiraclesScreen> createState() => _MiraclesScreenState();
}

class _MiraclesScreenState extends State<MiraclesScreen> {
  static const List<String> _featuredWords = <String>[
    'الله',
    'الرحمن',
    'الدنيا',
    'الآخرة',
    'نور',
  ];

  final QuranNumericalAnalysisService _service =
      QuranNumericalAnalysisService();
  final TextEditingController _searchController =
      TextEditingController(text: 'الله');

  QuranWordAnalysis? _analysis;
  Object? _error;
  bool _loading = true;
  String _query = 'الله';

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.analyzeAsset();
      if (!mounted) return;
      setState(() {
        _analysis = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _search(String value) {
    setState(() => _query = value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MudabbirDesignTokens.cosmicBackground,
      appBar: AppBar(
        title: const Text('التحليل العددي للنص'),
        backgroundColor: MudabbirDesignTokens.cosmicDeepBackground,
        foregroundColor: MudabbirDesignTokens.goldBright,
        actions: [
          IconButton(
            tooltip: 'إعادة تحليل الملف المحلي',
            onPressed: _loading ? null : _loadAnalysis,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            )
          : _error != null
              ? _buildError()
              : _analysis == null
                  ? _buildError()
                  : _buildAnalysis(_analysis!),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.primaryGold,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'تعذر تحليل بيانات القرآن المحلية',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error?.toString() ?? 'لم تُرجع خدمة التحليل نتيجة.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadAnalysis,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysis(QuranWordAnalysis analysis) {
    final featured = analysis.countsFor(_featuredWords);
    final maxCount = featured.fold<int>(
      1,
      (currentMax, entry) =>
          entry.value > currentMax ? entry.value : currentMax,
    );
    final normalizedQuery =
        QuranNumericalAnalysisService.tokenize(_query);

    return AnalyticsTemplate(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        MudabbirGlassPanel(
          padding: const EdgeInsets.all(20),
          radius: 24,
          glow: true,
          color: const Color(0xE6050811),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.auto_graph_rounded,
                color: AppColors.primaryGold,
                size: 34,
              ),
              const SizedBox(height: 12),
              const Text(
                'استكشاف قابل لإعادة التحقق',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تعرض هذه الشاشة نتائج عدّ حرفي محسوبة من ملف القرآن المضمّن، '
                'ولا تعتبر الأنماط العددية وحدها دليلًا على ادعاء ديني.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white70, height: 1.6),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _summaryMetric(
                      'السور',
                      analysis.surahCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _summaryMetric(
                      'الآيات المحللة',
                      analysis.verseCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _summaryMetric(
                      'الكلمات',
                      analysis.wordCount.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _sectionTitle('ابحث عن كلمة'),
        const SizedBox(height: 10),
        TextField(
          controller: _searchController,
          textDirection: TextDirection.rtl,
          textInputAction: TextInputAction.search,
          onChanged: _search,
          onSubmitted: _search,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: InputDecoration(
            hintText: 'أدخل كلمة عربية واحدة',
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primaryGold,
            ),
            suffixIcon: IconButton(
              tooltip: 'مسح البحث',
              onPressed: () {
                _searchController.clear();
                _search('');
              },
              icon: const Icon(Icons.close_rounded, color: Colors.white60),
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: _buildSearchResult(analysis, normalizedQuery),
        ),
        const SizedBox(height: 22),
        _sectionTitle('مقارنة تكرار كلمات مختارة'),
        const SizedBox(height: 6),
        const Text(
          'تُحسب الأشرطة من البيانات المحلية نفسها، وتتغير أطوالها وفق النتائج الفعلية.',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: Colors.white60, height: 1.5),
        ),
        const SizedBox(height: 14),
        ...featured.map(
          (entry) => _wordBar(
            word: entry.key,
            count: entry.value,
            maxCount: maxCount,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'مصدر البيانات وطريقة الحساب',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'المصدر: assets/unified_quran.json — الحقل text لكل آية. '
                'تُزال علامات التشكيل والتطويل، وتوحّد أشكال الألف، '
                'وتحوّل الألف المقصورة إلى ياء والهمزة على الواو/الياء إلى واو/ياء، '
                'ثم تُقسّم الكلمات بحسب الحروف العربية. '
                'قد تختلف النتائج عن طرق عدّ أخرى تستخدم رسمًا أو تطبيعًا مختلفًا.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white70, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResult(
    QuranWordAnalysis analysis,
    List<String> normalizedQuery,
  ) {
    if (normalizedQuery.isEmpty) {
      return const Card(
        key: ValueKey<String>('empty-search'),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'أدخل كلمة عربية لعرض عدد مرات ظهورها.',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    }

    if (normalizedQuery.length != 1) {
      return Card(
        key: const ValueKey<String>('invalid-search'),
        color: AppColors.surface,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'للحصول على عدّ واضح، ابحث عن كلمة واحدة في كل مرة.',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final word = normalizedQuery.single;
    final count = analysis.countWord(word);
    final occurrences = analysis.occurrencesFor(word);
    final verseReferences = occurrences
        .take(12)
        .map((item) => item.count > 1
            ? '${item.surahNumber}:${item.ayahNumber} ×${item.count}'
            : '${item.surahNumber}:${item.ayahNumber}')
        .join(' • ');
    return Card(
      key: ValueKey<String>('result-$word-$count'),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.format_quote_rounded,
                color: AppColors.primaryGold,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    word,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count == 0
                        ? 'لم تظهر الكلمة وفق قاعدة التطبيع المحددة.'
                        : 'عدد مرات الظهور: $count في ${occurrences.length} آية',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
            if (count > 0) ...[
              const SizedBox(height: 14),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              Text(
                'مواضع الظهور (السورة:الآية) — أول ${occurrences.length < 12 ? occurrences.length : 12} موضعًا',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                verseReferences,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.7,
                ),
              ),
              if (occurrences.length > 12)
                Text(
                  'و${occurrences.length - 12} موضعًا إضافيًا.',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppColors.primaryGold,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _wordBar({
    required String word,
    required int count,
    required int maxCount,
  }) {
    final fraction = count / maxCount;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                word,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(.08),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
