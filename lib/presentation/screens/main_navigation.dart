import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'quran_screen.dart';
import 'abjad_screen.dart';
import 'miracles_screen.dart';
import 'stats_screen.dart';
import 'compare_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: _getScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: const Color(0xFF16213E),
        indicatorColor: const Color(0xFFFFD700).withOpacity(0.2),
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat), label: 'محادثة'),
          NavigationDestination(icon: Icon(Icons.book), label: 'قرآن'),
          NavigationDestination(icon: Icon(Icons.calculate), label: 'جمل'),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'إعجاز'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'إحصائيات'),
          NavigationDestination(icon: Icon(Icons.compare_arrows), label: 'مقارنة'),
          NavigationDestination(icon: Icon(Icons.help), label: 'مساعدة'),
          NavigationDestination(icon: Icon(Icons.info), label: 'حول'),
        ],
      ),
    );
  }

  Widget _getScreen() {
    switch (_index) {
      case 0: return const ChatScreen();
      case 1: return const QuranScreen();
      case 2: return const AbjadCalculatorScreen();
      case 3: return const MiraclesScreen();
      case 4: return const StatsScreen();
      case 5: return const CompareScreen();
      case 6: return const HelpScreen();
      case 7: return const AboutScreen();
      default: return const ChatScreen();
    }
  }
}
