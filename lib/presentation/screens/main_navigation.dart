import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../providers/chat_provider.dart';
import '../providers/quran_provider.dart';
import '../providers/abjad_provider.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'quran_screen.dart';
import 'abjad_screen.dart';
import '../widgets/common/mudabbir_app_bar.dart';
import '../widgets/effects/fluid_background.dart';

/// =============================================================================
/// MainNavigationScreen - شاشة التنقل الرئيسية
/// =============================================================================

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];
  final List<MudabbirNavItem> _navItems = const [
    MudabbirNavItem(icon: Icons.home, label: 'الرئيسية'),
    MudabbirNavItem(icon: Icons.menu_book, label: 'القرآن'),
    MudabbirNavItem(icon: Icons.chat, label: 'محادثة'),
    MudabbirNavItem(icon: Icons.calculate, label: 'الجُمَّل'),
    MudabbirNavItem(icon: Icons.science, label: 'العلوم'),
  ];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomeScreen(onNavigate: _onNavigate),
      const QuranBrowserScreen(),
      const ChatScreen(),
      const AbjadCalculatorScreen(),
      const SciencesScreen(),
    ]);
  }

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: MudabbirBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavigate,
        items: _navItems,
      ),
    );
  }
}

/// =============================================================================
/// SciencesScreen - شاشة العلوم
/// =============================================================================

class SciencesScreen extends StatelessWidget {
  const SciencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sciences = [
      {'name': 'علم الحروف', 'icon': Icons.abc, 'count': 28},
      {'name': 'علم الأعداد', 'icon': Icons.numbers, 'count': 10},
      {'name': 'علم العناصر', 'icon': Icons.science, 'count': 5},
      {'name': 'علم الكواكب', 'icon': Icons.public, 'count': 7},
      {'name': 'علم الأبراج', 'icon': Icons.star, 'count': 12},
      {'name': 'علم الأسماء', 'icon': Icons.badge, 'count': 99},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: MudabbirAppBar(
        title: 'العلوم',
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: sciences.length,
        itemBuilder: (context, index) {
          final science = sciences[index];
          return _buildScienceCard(context, science);
        },
      ),
    );
  }

  Widget _buildScienceCard(BuildContext context, Map<String, dynamic> science) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              science['icon'] as IconData,
              color: AppColors.primaryNavy,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            science['name'] as String,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${science['count']} عنصر',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: MainNavigationScreen()));
}