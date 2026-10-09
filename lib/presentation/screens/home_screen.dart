import 'package:flutter/material.dart';
import 'quran/mushaf_screen.dart';
import 'quran_index_screen.dart';
import 'chat/chat_screen.dart';
import 'advanced_search_screen.dart';
import 'quran_word_explorer_screen.dart';
import 'favorites_screen.dart';
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
      ('المفضلة', Icons.bookmark_outline_rounded, const FavoritesScreen()),
      ('التلاوة', Icons.graphic_eq_rounded, const DailyVerseScreen()),
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

  Widget _buildToolsSection(BuildContext context) {
    final items = [
      ('الوكلاء', Icons.psychology_alt_rounded, const AgentsScreen()),
      ('الأسماء الحسنى', Icons.mosque_outlined, const DivineNamesScreen()),
      ('الآيات العظيمة', Icons.star_outline_rounded, const GreatVersesScreen()),
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

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('الوكلاء', Icons.psychology_alt_rounded, const AgentsScreen()),
      ('التدبر', Icons.lightbulb_outline_rounded, const InsightScreen()),
      ('الأسماء الحسنى', Icons.mosque_outlined, const DivineNamesScreen()),
      ('المفضلة', Icons.bookmark_outline_rounded, const FavoritesScreen()),
      ('الآيات العظيمة', Icons.star_outline_rounded, const GreatVersesScreen()),
      ('الإحصائيات', Icons.insights_rounded, const StatsScreen()),
      ('عدسة AR', Icons.view_in_ar_outlined, const ARLensScreen()),
      ('تتبع النظر', Icons.visibility_outlined, const GazeTrackingScreen()),
      ('الإعدادات', Icons.settings_outlined, const SettingsScreen()),
      ('حول مُدَبِّر', Icons.info_outline_rounded, const AboutScreen()),
    ];

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
          ...items.map((item) => Padding(
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
