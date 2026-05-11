import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'quran_screen.dart';
import 'abjad_screen.dart';

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
        ],
      ),
    );
  }

  Widget _getScreen() {
    switch (_index) {
      case 0: return const ChatScreen();
      case 1: return const QuranScreen();
      case 2: return const AbjadScreen();
      default: return const ChatScreen();
    }
  }
}
