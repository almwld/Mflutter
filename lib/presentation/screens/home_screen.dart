import 'package:flutter/material.dart';
import 'quran/mushaf_screen.dart';
import 'quran/quran_pro_screen.dart';
import 'quran_index_screen.dart';
import 'chat/chat_screen.dart';
import 'advanced_search_screen.dart';
import 'quran_word_explorer_screen.dart';
import 'favorites_screen.dart';
import 'quran_bookmarks_screen.dart';
import 'great_verses_screen.dart';
import 'stats_screen.dart';
import 'agents/agents_screen.dart';
import 'insight_screen.dart';
import 'divine_names_screen.dart';
import 'daily_verse_screen.dart';
import 'settings/settings_screen.dart';
import 'about_screen.dart';
import 'device/ar_lens_screen.dart';
import 'device/gaze_tracking_screen.dart';
import 'occult_explorer_screen.dart';
import 'elements_screen.dart';
import 'numbers_screen.dart';
import 'zodiac_screen.dart';
import 'quran_screen.dart';
import 'quran_page_screen.dart';
import 'surah_index_screen.dart';
import 'abjad_screen.dart';
import 'training_screen.dart';
import 'miracles_screen.dart';
import 'compare_screen.dart';
import 'nucleus_screen.dart';
import 'sovereign_hub_screen.dart';
import 'cosmic_services_screen.dart';
import 'ai_advanced_screen.dart';
import 'personalization_screen.dart';
import 'player_profile_screen.dart';
import 'recitation_screen.dart';
import 'help_screen.dart';
import 'package:provider/provider.dart';
import '../providers/abjad_provider.dart';
import '../providers/training_provider.dart';
import 'community_screen.dart';
import 'challenges_screen.dart';
import 'leaderboard_screen.dart';
import 'planets_screen.dart';
import 'astronomy_screen.dart';
import 'letters_screen.dart';
import 'advanced_tech_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _navItems = [
    (Icons.menu_book_rounded, 'المصحف'),
    (Icons.search_rounded, 'البحث'),
    (Icons.auto_awesome_rounded, 'اليوم'),
    (Icons.forum_rounded, 'المحادثة'),
    (Icons.grid_view_rounded, 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _MushafHome(),
      const AdvancedSearchScreen(),
      const DailyVerseScreen(),
      const ChatScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: IndexedStack(index: _currentIndex, children: screens)),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)), 
        boxShadow: [BoxShadow(blurRadius: 14, offset: const Offset(0, -4), color: Theme.of(context).colorScheme.shadow.withOpacity(.08))],
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Row(
        children: List.generate(_navItems.length, (i) {
          final selected = _currentIndex == i;
          final item = _navItems[i];
          return Expanded(
            child: Semantics(
              button: true,
              selected: selected,
              label: item.$2,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _currentIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? Theme.of(context).colorScheme.primary.withOpacity(.13) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? Theme.of(context).colorScheme.primary.withOpacity(.65) : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.$1, size: 22, color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(.62)),
                      const SizedBox(height: 3),
                      Text(item.$2, style: TextStyle(fontFamily: 'Amiri', fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(.62))),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MushafHome extends StatelessWidget {
  const _MushafHome();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverToBoxAdapter(child: _buildContinueCard(context)),
        SliverToBoxAdapter(child: _buildSectionTitle(context, 'الوصول السريع', Icons.bolt_rounded)),
        SliverToBoxAdapter(child: _buildQuickActions(context)),
        SliverToBoxAdapter(child: _buildSectionTitle(context, 'رحلة التدبر', Icons.auto_awesome_rounded)),
        SliverToBoxAdapter(child: _buildInsightSection(context)),
        SliverToBoxAdapter(child: _buildSuperAgentsCard(context)),
        SliverToBoxAdapter(child: _buildSectionTitle(context, 'أدوات مُدَبِّر', Icons.tune_rounded)),
        SliverToBoxAdapter(child: _buildToolsSection(context)),
        const SliverPadding(padding: EdgeInsets.only(bottom: 18)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('مُدَبِّر', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('القرآن • التدبر • المعرفة', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.65))),
          ])), 
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MushafScreen())),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 66,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(.12), borderRadius: BorderRadius.circular(15)), 
                  child: Center(child: Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.primary, size: 29)), 
                ),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('متابعة القراءة', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.65))),
                  const SizedBox(height: 5),
                  Text('المصحف الشريف', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('اضغط للعودة إلى آخر موضع قراءة', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.62))),
                ])), 
                Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 7),
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), 
          const Spacer(),
          Container(width: 42, height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final items = [
      ('الفهرس', Icons.list_alt_rounded, const QuranIndexScreen()),
      ('بحث متقدم', Icons.manage_search_rounded, const AdvancedSearchScreen()),
      ('تحليل الكلمات', Icons.text_fields_rounded, const QuranWordExplorerScreen()),
      ('الحروف', Icons.abc_rounded, const LettersScreen()),
      ('المفضلة', Icons.bookmark_outline_rounded, const FavoritesScreen()),
      ('علامات المصحف', Icons.bookmarks_outlined, const QuranBookmarksScreen()),
      ('التلاوة', Icons.graphic_eq_rounded, const RecitationScreen()),
    ];
    return SizedBox(
      height: 105,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = items[i];
          return _ActionCard(title: item.$1, icon: item.$2, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.$3)));
        },
      ),
    );
  }

  Widget _buildInsightSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _FeatureCard(title: 'آية اليوم', subtitle: 'تأمل في الآية المختارة', icon: Icons.auto_awesome, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyVerseScreen())))),
          const SizedBox(width: 10),
          Expanded(child: _FeatureCard(title: 'التدبر', subtitle: 'اكتشف أدوات الفهم', icon: Icons.lightbulb_outline_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightScreen())))),
        ],
      ),
    );
  }

  Widget _buildSuperAgentsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgentsScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(.42)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.hub_rounded, color: theme.colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الوكلاء الفائقون', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'تخطيط • بحث من assets • تفكير نقدي • تحقق • ذاكرة محلية',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(.68)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    final items = [
      ('تصفح القرآن', Icons.menu_book_rounded, const QuranIndexScreen()),
      ('علم العناصر', Icons.water_drop_outlined, const ElementsScreen()),
      ('علم الأعداد', Icons.numbers_rounded, const NumbersScreen()),
      ('علم الأبراج', Icons.auto_awesome_rounded, const ZodiacScreen()),
      ('علم الكواكب', Icons.public_rounded, const PlanetsScreen()),
      ('علم الفلك', Icons.nights_stay_rounded, const AstronomyScreen()),
      ('التدبر والبصائر', Icons.lightbulb_outline_rounded, const InsightScreen()),
      ('الأسماء الحسنى', Icons.mosque_outlined, const DivineNamesScreen()),
      ('الآيات العظيمة', Icons.star_outline_rounded, const GreatVersesScreen()),
      ('الوكلاء', Icons.psychology_alt_rounded, const AgentsScreen()),
      ('مستكشف المعرفة', Icons.auto_stories_rounded, const OccultExplorerScreen()),
      ('الإحصائيات', Icons.insights_rounded, const StatsScreen()),
      ('عدسة AR', Icons.view_in_ar_outlined, const ARLensScreen()),
      ('تتبع النظر', Icons.visibility_outlined, const GazeTrackingScreen()),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1.05),
        itemBuilder: (context, i) {
          final item = items[i];
          return _ToolCard(title: item.$1, icon: item.$2, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.$3)));
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 94,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Amiri', fontSize: 11, height: 1.05, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _FeatureCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 15),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Amiri', fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(.65))),
          ]),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _ToolCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Amiri', fontSize: 10, height: 1.0, color: Theme.of(context).colorScheme.onSurface.withOpacity(.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeSearchText(String value) => value
      .toLowerCase()
      .replaceAll(
        RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'),
        '',
      )
      .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
      .replaceAll(RegExp(r'[ؤئ]'), 'ء')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('الوكلاء', Icons.psychology_alt_rounded, const AgentsScreen()),
      ('مستكشف المعرفة', Icons.auto_stories_rounded, const OccultExplorerScreen()),
      ('التدبر', Icons.lightbulb_outline_rounded, const InsightScreen()),
      ('الأسماء الحسنى', Icons.mosque_outlined, const DivineNamesScreen()),
      ('المفضلة', Icons.bookmark_outline_rounded, const FavoritesScreen()),
      ('علامات المصحف', Icons.bookmarks_outlined, const QuranBookmarksScreen()),
      ('الآيات العظيمة', Icons.star_outline_rounded, const GreatVersesScreen()),
      ('الإحصائيات', Icons.insights_rounded, const StatsScreen()),
      ('عدسة AR', Icons.view_in_ar_outlined, const ARLensScreen()),
      ('تتبع النظر', Icons.visibility_outlined, const GazeTrackingScreen()),
      ('الإعدادات', Icons.settings_outlined, const SettingsScreen()),
      ('حول مُدَبِّر', Icons.info_outline_rounded, const AboutScreen()),
      ('القرآن التفاعلي', Icons.menu_book_rounded, const QuranScreen()),
      ('القرآن بأنماط الخط', Icons.auto_stories_rounded, const QuranProScreen()),
      ('تقنيات متقدمة', Icons.science_outlined, const AdvancedTechScreen()),
      ('فهرس السور', Icons.list_alt_rounded, const SurahIndexScreen()),
      ('صفحة المصحف', Icons.menu_book_outlined, const QuranPageScreen(surahNumber: 1, surahName: 'الفاتحة')),
      ('حاسبة الأبجد', Icons.calculate_outlined, ChangeNotifierProvider<AbjadProvider>(create: (_) => AbjadProvider(), child: const AbjadCalculatorScreen())),
      ('تحليل أبجد', Icons.functions_rounded, ChangeNotifierProvider<AbjadProvider>(create: (_) => AbjadProvider(), child: const AbjadCalculatorScreen())),
      ('العناصر الرمزية', Icons.category_outlined, const ElementsScreen()),
      ('الأعداد الرمزية', Icons.pin_outlined, const NumbersScreen()),
      ('علم الأبراج', Icons.auto_awesome_rounded, const ZodiacScreen()),
      ('علم الكواكب', Icons.public_rounded, const PlanetsScreen()),
      ('علم الفلك', Icons.nights_stay_rounded, const AstronomyScreen()),
      ('التدريب', Icons.model_training_rounded, ChangeNotifierProvider<TrainingProvider>(create: (_) => TrainingProvider()..initialize(), child: const TrainingScreen())),
      ('الإعجاز', Icons.auto_awesome_rounded, const MiraclesScreen()),
      ('المقارنة', Icons.compare_arrows_rounded, const CompareScreen()),
      ('النواة', Icons.psychology_rounded, const NucleusScreen()),
      ('مركز السيادة', Icons.hub_rounded, const SovereignHubScreen()),
      ('الخدمات الكونية', Icons.rocket_launch_rounded, const CosmicServicesScreen()),
      ('الذكاء المتقدم', Icons.memory_rounded, const AIAdvancedScreen()),
      ('التخصيص المتقدم', Icons.tune_rounded, const PersonalizationScreen()),
      ('الملف الشخصي', Icons.person_outline_rounded, const PlayerProfileScreen()),
      ('مشغل التلاوة', Icons.play_circle_outline_rounded, const RecitationScreen()),
      ('المساعدة', Icons.help_outline_rounded, const HelpScreen()),
      ('المجتمع', Icons.groups_rounded, const CommunityScreen()),
      ('التحديات', Icons.flag_outlined, const ChallengesScreen()),
      ('لوحة المتصدرين', Icons.leaderboard_rounded, const LeaderboardScreen()),

      ('علم الحروف', Icons.abc_rounded, const LettersScreen()),
    ];
    final normalizedQuery = _normalizeSearchText(_query.trim());
    final filteredItems = items
        .where((item) => _normalizeSearchText(item.$1).contains(normalizedQuery))
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('المزيد'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)),
            child: Row(children: [
              Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary, size: 30),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('مساحة مُدَبِّر', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text('كل أدوات التطبيق في مكان واحد', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Amiri', fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(.65))),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            textDirection: TextDirection.rtl,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'ابحث عن أداة أو واجهة...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'مسح البحث',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              _query.isEmpty ? '${items.length} واجهة وأداة' : '${filteredItems.length} نتيجة',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.65),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (filteredItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 38, color: Theme.of(context).colorScheme.onSurface.withOpacity(.45)),
                  const SizedBox(height: 10),
                  const Text('لا توجد واجهة بهذا الاسم', textAlign: TextAlign.center),
                ],
              ),
            ),
          ...filteredItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Icon(item.$2, color: Theme.of(context).colorScheme.primary),
                title: Text(item.$1),
                trailing: Icon(Icons.chevron_left_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(.55)), 
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.$3)),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
