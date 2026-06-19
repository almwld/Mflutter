import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/divine_name.dart';

/// =============================================================================
/// DivineNameCard - بطاقة الاسم الإلهي
/// =============================================================================

class DivineNameCard extends StatelessWidget {
  final DivineName name;
  final VoidCallback? onTap;
  final bool isSelected;

  const DivineNameCard({
    super.key,
    required this.name,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [
                  AppColors.gold.withOpacity(0.4),
                  AppColors.gold.withOpacity(0.2),
                ]
              : [
                  AppColors.primaryNavy.withOpacity(0.4),
                  AppColors.primaryNavy.withOpacity(0.2),
                ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: isSelected
              ? AppColors.gold
              : AppColors.gold.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                _buildNumberBadge(),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(child: _buildInfo()),
                _buildIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.gold.withOpacity(0.3)
            : AppColors.primaryNavy.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.gold : Colors.transparent,
        ),
      ),
      child: Center(
        child: Text(
          name.number.toString(),
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.gold : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.name,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name.meaning,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        _buildAttributeBadge(),
      ],
    );
  }

  Widget _buildAttributeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        name.attribute,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          color: AppColors.gold,
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      isSelected ? Icons.favorite : Icons.favorite_border,
      color: isSelected ? AppColors.gold : Colors.white54,
      size: 24,
    );
  }
}