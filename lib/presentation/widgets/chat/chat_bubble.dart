import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../domain/entities/chat_message.dart';

/// =============================================================================
/// ChatBubble - فقاعة المحادثة
/// =============================================================================

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showMetadata;

  const ChatBubble({
    super.key,
    required this.message,
    this.showMetadata = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.marginSmall),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUser
                ? [
                    AppColors.gold.withOpacity(0.3),
                    AppColors.gold.withOpacity(0.1),
                  ]
                : [
                    AppColors.primaryNavy.withOpacity(0.4),
                    AppColors.primaryNavy.withOpacity(0.2),
                  ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppDimensions.radiusLarge),
            topRight: const Radius.circular(AppDimensions.radiusLarge),
            bottomLeft: Radius.circular(isUser ? 0 : AppDimensions.radiusLarge),
            bottomRight: Radius.circular(isUser ? AppDimensions.radiusLarge : 0),
          ),
          border: Border.all(
            color: isUser
                ? AppColors.gold.withOpacity(0.5)
                : AppColors.gold.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: isUser ? 16 : 14,
                height: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: Colors.white54,
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    size: 14,
                    color: AppColors.gold,
                  ),
                ],
              ],
            ),
            if (showMetadata && message.metadata != null) ...[
              const SizedBox(height: 8),
              _buildMetadata(message.metadata!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(Map<String, dynamic> metadata) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (metadata['abjadValue'] != null)
            _buildMetadataRow(
              'الجُمَّل',
              metadata['abjadValue'].toString(),
              Icons.calculate,
            ),
          if (metadata['divineName'] != null)
            _buildMetadataRow(
              'الاسم الإلهي',
              metadata['divineName'] as String,
              Icons.auto_awesome,
            ),
          if (metadata['element'] != null)
            _buildMetadataRow(
              'العنصر',
              metadata['element'] as String,
              Icons.science,
            ),
          if (metadata['insight'] != null)
            _buildMetadataRow(
              'بصيرة',
              metadata['insight'] as String,
              Icons.lightbulb,
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: Colors.white54),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}