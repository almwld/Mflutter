import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/science.dart';

/// =============================================================================
/// ScienceCard - بطاقة العلم
/// =============================================================================

class ScienceCard extends StatelessWidget {
  final Science science;
  final VoidCallback? onTap;
  final bool isLocked;

  const ScienceCard({
    super.key,
    required this.science,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScienceColor().withOpacity(0.3),
            _getScienceColor().withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: _getScienceColor().withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getScienceColor().withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getScienceColor().withOpacity(0.5),
                        ),
                      ),
                      child: Icon(
                        _getScienceIcon(),
                        color: isLocked ? Colors.white38 : _getScienceColor(),
                        size: 32,
                      ),
                    ),
                    if (isLocked)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.cardBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock,
                            color: Colors.white54,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  science.name,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.white54 : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${science.count} عنصر',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: isLocked ? Colors.white38 : Colors.white70,
                  ),
                ),
                if (science.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    science.description,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: isLocked ? Colors.white24 : Colors.white54,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScienceColor() {
    switch (science.type) {
      case ScienceType.letters:
        return Colors.amber;
      case ScienceType.numbers:
        return Colors.blue;
      case ScienceType.elements:
        return Colors.red;
      case ScienceType.planets:
        return Colors.purple;
      case ScienceType.zodiac:
        return Colors.green;
      case ScienceType.names:
        return AppColors.gold;
      default:
        return AppColors.primaryNavy;
    }
  }

  IconData _getScienceIcon() {
    switch (science.type) {
      case ScienceType.letters:
        return Icons.abc;
      case ScienceType.numbers:
        return Icons.numbers;
      case ScienceType.elements:
        return Icons.science;
      case ScienceType.planets:
        return Icons.public;
      case ScienceType.zodiac:
        return Icons.star;
      case ScienceType.names:
        return Icons.badge;
      default:
        return Icons.help_outline;
    }
  }
}