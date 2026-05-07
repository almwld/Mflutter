import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// =============================================================================
/// ChatBubble - فقاعة المحادثة
/// =============================================================================

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isFromUser;
  final Map<String, dynamic>? metadata;
  final VoidCallback? onTap;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isFromUser,
    this.metadata,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isFromUser
                ? [
                    AppColors.primaryGold.withOpacity(0.3),
                    AppColors.primaryGold.withOpacity(0.1),
                  ]
                : [
                    AppColors.primaryNavy.withOpacity(0.6),
                    AppColors.primaryNavy.withOpacity(0.4),
                  ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isFromUser ? 0 : 24),
            bottomRight: Radius.circular(isFromUser ? 24 : 0),
          ),
          border: Border.all(
            color: isFromUser
                ? AppColors.primaryGold.withOpacity(0.5)
                : AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // نص الرسالة
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
            // البيانات الوصفية
            if (metadata != null) ...[
              const SizedBox(height: 12),
              _buildMetadata(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // قيمة الجمل
          if (metadata!['abjadValue'] != null)
            _buildMetadataRow(
              'الجُمَّل',
              '${metadata!['abjadValue']}',
              Icons.calculate,
            ),
          // العنصر
          if (metadata!['element'] != null)
            _buildMetadataRow(
              'العنصر',
              '${metadata!['element']}',
              Icons.science,
            ),
          // الكوكب
          if (metadata!['planet'] != null)
            _buildMetadataRow(
              'الكوكب',
              '${metadata!['planet']}',
              Icons.public,
            ),
          // البرج
          if (metadata!['zodiac'] != null)
            _buildMetadataRow(
              'البرج',
              '${metadata!['zodiac']}',
              Icons.star,
            ),
          // الاسم الإلهي
          if (metadata!['divineName'] != null)
            _buildMetadataRow(
              'الاسم الإلهي',
              '${metadata!['divineName']}',
              Icons.auto_awesome,
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

/// =============================================================================
/// TypingIndicator - مؤشر الكتابة
/// =============================================================================

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy.withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = _animation.value - index;
                final isVisible = delay >= 0 && delay < 1;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isVisible
                        ? AppColors.primaryGold
                        : AppColors.primaryGold.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

/// =============================================================================
/// ChatInputBar - شريط إدخال المحادثة
/// =============================================================================

class ChatInputBar extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isNotEmpty && !widget.isLoading) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // حقل الإدخال
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryGold.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white38,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // زر الإرسال
          GestureDetector(
            onTap: widget.isLoading ? null : _handleSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGold, Color(0xFFFFA500)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryNavy,
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: AppColors.primaryNavy,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}