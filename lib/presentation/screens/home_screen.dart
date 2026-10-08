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
      backgroundColor: const Color(0xFF0B0D12),
      body: SafeArea(child: IndexedStack(index: _currentIndex, children: screens)),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        border: const Border(top: BorderSide(color: Color(0xFF292D36))),
        boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, -6), color: Colors.black54)],
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
                    color: selected ? const Color(0xFF2A2413) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? const Color(0xFF8F7428) : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.$1, size: 22, color: selected ? const Color(0xFFD8B65A) : const Color(0xFF8B919C)),
                      const SizedBox(height: 3),
                      Text(item.$2, style: TextStyle(fontFamily: 'Amiri', fontSize: 11, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? const Color(0xFFE4C878) : const Color(0xFF8B919C))),
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
        SliverToBoxAdapter(child: _buildSectionTitle('الوصول السريع', Icons.bolt_rounded)),
        SliverToBoxAdapter(child: _buildQuickActions(context)),
        SliverToBoxAdapter(child: _buildSectionTitle('رحلة التدبر', Icons.auto_awesome_rounded)),
        SliverToBoxAdapter(child: _buildInsightSection(context)),
        SliverToBoxAdapter(child: _buildSectionTitle('أدوات مُدَبِّر', Icons.tune_rounded)),
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
              color: const Color(0xFF171A21),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF665226)),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFD8B65A), size: 25),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مُدَبِّر', style: TextStyle(fontFamily: 'Amiri', fontSize: 27, height: 1, fontWeight: FontWeight.bold, color: Color(0xFFE8D49A))),
                SizedBox(height: 5),
                Text('القرآن • التدبر • المعرفة', style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: Color(0xFF9298A4))),
              ],
            ),
          ),
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            icon: const Icon(Icons.settings_outlined, color: Color(0xFFA7ACB5)),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: const Color(0xFF171A21),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MushafScreen())),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF665226)),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 66,
                  decoration: BoxDecoration(color: const Color(0xFF242019), borderRadius: BorderRadius.circular(15)),
                  child: const Center(child: Icon(Icons.menu_book_rounded, color: Color(0xFFD8B65A), size: 29)),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('متابعة القراءة', style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: Color(0xFF9B9FA8))),
                      SizedBox(height: 5),
                      Text('المصحف الشريف', style: TextStyle(fontFamily: 'Amiri', fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 4),
                      Text('اضغط للعودة إلى آخر موضع قراءة', style: TextStyle(fontFamily: 'Amiri', fontSize: 11, color: Color(0xFF818792))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFFD8B65A)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFD8B65A)),
          const SizedBox(width: 7),
          Text(title, style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE1E3E7))),
          const Spacer(),
          Container(width: 42, height: 1, color: const Color(0xFF403922)),
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
      color: const Color(0xFF15181F),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 94,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 7),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF292D35))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 25, color: const Color(0xFFD8B65A)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Amiri', fontSize: 12, color: Color(0xFFD4D7DC))),
          ]),
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
      color: const Color(0xFF15181F),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF292D35))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: const Color(0xFFD8B65A), size: 24),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(fontFamily: 'Amiri', fontSize: 10, color: Color(0xFF858B96))),
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
      color: const Color(0xFF15181F),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 24, color: const Color(0xFFB7A36D)),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Amiri', fontSize: 11, color: Color(0xFFB9BDC5))),
        ]),
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
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        title: const Text('المزيد', style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold, color: Color(0xFFE1E3E7))),
        backgroundColor: const Color(0xFF0B0D12),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFF15181F), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF292D35))),
            child: const Row(children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFFD8B65A), size: 30),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('مساحة مُدَبِّر', style: TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 3),
                Text('كل أدوات التطبيق في مكان واحد', style: TextStyle(fontFamily: 'Amiri', fontSize: 11, color: Color(0xFF858B96))),
              ])),
            ]),
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: const Color(0xFF15181F),
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Icon(item.$2, color: const Color(0xFFD0B15B)),
                title: Text(item.$1, style: const TextStyle(fontFamily: 'Amiri', color: Color(0xFFD7D9DE))),
                trailing: const Icon(Icons.chevron_left_rounded, color: Color(0xFF666D78)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.$3)),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
