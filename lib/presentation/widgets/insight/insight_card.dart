import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/insight.dart';

/// =============================================================================
/// InsightCard - بطاقة البصيرة
/// =============================================================================

class InsightCard extends StatelessWidget {
  final Insight insight;
  final VoidCallback? onTap;
  final bool showCategory;

  const InsightCard({
    super.key,
    required this.insight,
    this.onTap,
    this.showCategory = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor().withOpacity(0.3),
            _getCategoryColor().withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: _getCategoryColor().withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildContent(),
                const SizedBox(height: AppDimensions.paddingSmall),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (showCategory) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(),
                  size: 12,
                  color: _getCategoryColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  _getCategoryName(),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: _getCategoryColor(),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
        if (!insight.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          insight.question,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        if (insight.answer.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            insight.answer,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.lightbulb_outline,
          size: 14,
          color: Colors.white54,
        ),
        const SizedBox(width: 4),
        Text(
          insight.hint,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
        const Spacer(),
        Text(
          _formatTime(insight.timestamp),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (insight.category) {
      case InsightCategory.contemplation:
        return Colors.purple;
      case InsightCategory.quran:
        return Colors.green;
      case InsightCategory.science:
        return Colors.blue;
      case InsightCategory.wisdom:
        return Colors.orange;
      default:
        return AppColors.gold;
    }
  }

  IconData _getCategoryIcon() {
    switch (insight.category) {
      case InsightCategory.contemplation:
        return Icons.self_improvement;
      case InsightCategory.quran:
        return Icons.menu_book;
      case InsightCategory.science:
        return Icons.science;
      case InsightCategory.wisdom:
        return Icons.lightbulb;
      default:
        return Icons.help_outline;
    }
  }

  String _getCategoryName() {
    switch (insight.category) {
      case InsightCategory.contemplation:
        return 'تأمل';
      case InsightCategory.quran:
        return 'القرآن';
      case InsightCategory.science:
        return 'العلوم';
      case InsightCategory.wisdom:
        return 'حكمة';
      default:
        return 'عام';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}