import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'quran_screen.dart';
import 'abjad_screen.dart';
import 'miracles_screen.dart';
import 'stats_screen.dart';
import 'compare_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';
import 'nucleus_screen.dart';
import 'sovereign_hub_screen.dart';
import 'cosmic_services_screen.dart';
import 'ai_advanced_screen.dart';
import 'personalization_screen.dart';
import 'player_profile_screen.dart';
import 'advanced_search_screen.dart';
import 'favorites_screen.dart';
import 'recitation_screen.dart';

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
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'المزيد'),
        ],
      ),
    );
  }

  Widget _getScreen() {
    switch (_index) {
      case 0: return const ChatScreen();
      case 1: return const QuranScreen();
      case 2: return const AbjadCalculatorScreen();
      case 3: return const MoreScreen();
      default: return const ChatScreen();
    }
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(title: const Text('المزيد', style: TextStyle(color: Color(0xFFFFD700))), backgroundColor: const Color(0xFF1A237E)),
      body: GridView.count(crossAxisCount: 3, padding: const EdgeInsets.all(12), children: [
        _buildTile(context, 'إعجاز', Icons.auto_awesome, const MiraclesScreen()),
        _buildTile(context, 'إحصائيات', Icons.bar_chart, const StatsScreen()),
        _buildTile(context, 'مقارنة', Icons.compare_arrows, const CompareScreen()),
        _buildTile(context, 'نواة', Icons.psychology, const NucleusScreen()),
        _buildTile(context, 'سيادة', Icons.hub, const SovereignHubScreen()),
        _buildTile(context, 'كونية', Icons.rocket_launch, const CosmicServicesScreen()),
        _buildTile(context, 'ذكاء', Icons.memory, const AIAdvancedScreen()),
        _buildTile(context, 'تخصيص', Icons.palette, const PersonalizationScreen()),
        _buildTile(context, 'ملفي', Icons.person, const PlayerProfileScreen()),
        _buildTile(context, 'بحث', Icons.search, const AdvancedSearchScreen()),
        _buildTile(context, 'مفضلة', Icons.favorite, const FavoritesScreen()),
        _buildTile(context, 'تلاوة', Icons.play_circle, const RecitationScreen()),
        _buildTile(context, 'مساعدة', Icons.help, const HelpScreen()),
        _buildTile(context, 'حول', Icons.info, const AboutScreen()),
      ]),
    );
  }

  Widget _buildTile(BuildContext context, String label, IconData icon, Widget screen) {
    return Card(
      color: const Color(0xFF16213E),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 32),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
    );
  }
}
