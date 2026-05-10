import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/abjad_provider.dart';
import '../widgets/effects/fluid_background.dart';
import '../widgets/effects/magnetic_icon.dart';
import '../widgets/common/loading_indicator.dart';

/// =============================================================================
/// HomeScreen - الشاشة الرئيسية
/// =============================================================================

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({Key? key}) : super(key: key) : super(key: key);
    super.key,
    
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final quranProvider = context.read<QuranProvider>();
    final abjadProvider = context.read<AbjadProvider>();

    /* await Future.wait removed */ //
      quranProvider.loadSurahs();
      abjadProvider.calculateAbjad('بسم الله الرحمن الرحيم'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FluidBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // العنوان
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              // بطاقة الطاقة
              SliverToBoxAdapter(
                child: _buildEnergyCard(),
              ),
              // أيقونات التنقل
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildListDelegate([
                    MagneticIcon(
                      icon: Icons.menu_book,
                      label: 'القرآن',
                      onTap: () => widget.onNavigate(1),
                    ),
                    MagneticIcon(
                      icon: Icons.chat,
                      label: 'محادثة',
                      onTap: () => widget.onNavigate(2),
                    ),
                    MagneticIcon(
                      icon: Icons.calculate,
                      label: 'الجُمَّل',
                      onTap: () => widget.onNavigate(3),
                    ),
                    MagneticIcon(
                      icon: Icons.science,
                      label: 'العلوم',
                      onTap: () => widget.onNavigate(4),
                    ),
                    MagneticIcon(
                      icon: Icons.star,
                      label: 'الأسماء',
                      onTap: () => widget.onNavigate(5),
                    ),
                    MagneticIcon(
                      icon: Icons.lightbulb,
                      label: 'البصيرة',
                      onTap: () => widget.onNavigate(6),
                    ),
                  ]),
                ),
              ),
              // آية اليوم
              SliverToBoxAdapter(
                child: _buildDailyVerse(),
              ),
              // قسم التمارين
              SliverToBoxAdapter(
                child: _buildExercises(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primaryGold,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'مُدَبِّر الْأَسْرَارِ الْعُلْيَا',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'رافقك الله في رحلة الكشف عن أسرار القرآن',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.primaryGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard() {
    return Consumer<AbjadProvider>(
      builder: (context, provider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: AppColors.primaryGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'طاقة اليوم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: AppColors.primaryGold.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGold,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.lastResult?.kabir ?? 0} - الجمل الكبير',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyVerse() {
    return Consumer<QuranProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: LoadingIndicator(),
          );
        }

        final verse = provider.dailyVerse;
        if (verse == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.format_quote,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'آية اليوم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  verse.textWithDiacritics,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 24,
                    color: AppColors.primaryNavy,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'سورة ${verse.surahNumber} - آية ${verse.ayahNumber}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExercises() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'تمرين سريع',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildExerciseCard(
            'احسب جملة',
            'بسم الله الرحمن الرحيم',
            Icons.calculate,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryNavy, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_back,
            color: AppColors.primaryGold,
            size: 20,
          ),
        ],
      ),
    );
  }
}