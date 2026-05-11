import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// =============================================================================
/// MudabbirAppBar - شريط التطبيق المُخصص
/// =============================================================================

class MudabbirAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final bool centerTitle;

  const MudabbirAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: AppColors.textOnPrimary,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.primaryNavy,
      elevation: 0,
      leading: automaticallyImplyLeading
          ? leading ??
              (Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null)
          : leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);
}

/// =============================================================================
/// MudabbirBottomNav - شريط التنقل السفلي المُخصص
/// =============================================================================

class MudabbirBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<MudabbirNavItem> items;

  const MudabbirBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMedium,
            vertical: AppDimensions.spacingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isSelected = items.indexOf(item) == currentIndex;
              return _buildNavItem(context, item, isSelected);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, MudabbirNavItem item, bool isSelected) {
    return GestureDetector(
      onTap: () => onTap(items.indexOf(item)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? AppColors.primaryGold : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primaryGold : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =============================================================================
/// MudabbirNavItem - عنصر شريط التنقل
/// =============================================================================

class MudabbirNavItem {
  final IconData icon;
  final String label;

  const MudabbirNavItem({
    required this.icon,
    required this.label,
  });
}

/// =============================================================================
/// MudabbirDrawer - القائمة الجانبية المُخصصة
/// =============================================================================

class MudabbirDrawer extends StatelessWidget {
  final Function(String) onItemSelected;

  const MudabbirDrawer({
    super.key,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.deepBackground,
      child: SafeArea(
        child: Column(
          children: [
            // الرأس
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: const BoxDecoration(
                gradient: AppColors.navyGoldGradient,
              ),
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
                      fontFamily: 'Cairo',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'رافقك الله في رحلتك',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
            ),
            // القائمة
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                children: [
                  _buildDrawerItem(
                    context,
                    Icons.home,
                    'الرئيسية',
                    () => onItemSelected('home'),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.menu_book,
                    'القرآن الكريم',
                    () => onItemSelected('quran'),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.calculate,
                    'حاسبة الجُمَّل',
                    () => onItemSelected('abjad'),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.science,
                    'العلوم',
                    () => onItemSelected('sciences'),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.star,
                    'الأسماء الحسنى',
                    () => onItemSelected('names'),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.lightbulb,
                    'أسئلة البصيرة',
                    () => onItemSelected('insight'),
                  ),
                  const Divider(color: AppColors.primaryNavyLight),
                  _buildDrawerItem(
                    context,
                    Icons.settings,
                    'الإعدادات',
                    () => onItemSelected('settings'),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.info,
                    'عن التطبيق',
                    () => onItemSelected('about'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGold),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textOnPrimary,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      selectedTileColor: AppColors.primaryGold.withOpacity(0.1),
    );
  }
}