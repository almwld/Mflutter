import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// =============================================================================
/// MudabbirBottomNav - شريط التنقل السفلي
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
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNavy.withOpacity(0.95),
            AppColors.primaryNavy.withOpacity(0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              return _buildNavItem(items[index], index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(MudabbirNavItem item, int index) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.gold.withOpacity(0.5))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold.withOpacity(0.3)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: isSelected ? AppColors.gold : Colors.white54,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.gold : Colors.white54,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

/// =============================================================================
/// MudabbirNavItem - عنصر التنقل
/// =============================================================================

class MudabbirNavItem {
  final IconData icon;
  final String label;

  const MudabbirNavItem({
    required this.icon,
    required this.label,
  });
}