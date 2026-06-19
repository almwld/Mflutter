import 'package:flutter/material.dart';
import 'quran/mushaf_screen.dart';
import 'chat/chat_screen.dart';
import 'advanced_search_screen.dart';
import 'favorites_screen.dart';
import 'daily_verse_screen.dart';
import 'stats_screen.dart';
import 'insight_screen.dart';
import 'divine_names_screen.dart';
import 'great_verses_screen.dart';
import 'agents/agents_screen.dart';
import 'settings/settings_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // يبدأ من الآية اليومية

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A237E),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'مصحف'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'اليوم'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'محادثة'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'المزيد'),
        ],
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0: return const MushafScreen();
      case 1: return const AdvancedSearchScreen();
      case 2: return const DailyVerseScreen();
      case 3: return const ChatScreen();
      case 4: return const MoreScreen();
      default: return const DailyVerseScreen();
    }
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('المزيد', style: TextStyle(color: Color(0xFFFFD700)))),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        children: [
          _tile(context, '🧠 الوكلاء', const AgentsScreen(), Icons.psychology),
          _tile(context, '💡 التدبر', const InsightScreen(), Icons.lightbulb),
          _tile(context, '🕌 الأسماء', const DivineNamesScreen(), Icons.mosque),
          _tile(context, '⭐ المفضلة', const FavoritesScreen(), Icons.star),
          _tile(context, '🌟 عظيمة', const GreatVersesScreen(), Icons.auto_awesome),
          _tile(context, '📊 إحصائيات', const StatsScreen(), Icons.bar_chart),
          _tile(context, '⚙️ إعدادات', const SettingsScreen(), Icons.settings),
          _tile(context, 'ℹ️ حول', const AboutScreen(), Icons.info),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String label, Widget screen, IconData icon) {
    return Card(
      color: const Color(0xFF1A237E).withOpacity(0.6),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 36),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13, fontFamily: 'Amiri')),
        ]),
      ),
    );
  }
}
