import 'package:flutter/material.dart';

import '../../../core/themes/mudabbir_design_tokens.dart';

/// Shared visual shell for atomic blocks in the universal canvas.
///
/// The content builder is isolated from synchronous build-time exceptions.
/// Flutter layout/paint errors are still handled by Flutter's own error
/// machinery; this widget deliberately does not install a global error hook.
abstract class BaseUniversalBlock extends StatelessWidget {
  const BaseUniversalBlock({
    super.key,
    required this.title,
    required this.data,
    this.styleHints,
  });

  final String title;
  final Map<String, dynamic> data;

  /// Only a small allowlist is interpreted. Payloads cannot supply arbitrary
  /// colors, shadows, or executable styling.
  final Map<String, dynamic>? styleHints;

  Widget buildBlockContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final highlight = styleHints?['highlight'] == true;
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: MudabbirDesignTokens.glassSurface,
          borderRadius: BorderRadius.circular(MudabbirDesignTokens.cardRadius),
          border: Border.all(
            color: highlight
                ? MudabbirDesignTokens.cyan.withOpacity(0.75)
                : MudabbirDesignTokens.glassBorder,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MudabbirDesignTokens.cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.trim().isNotEmpty) ...[
                  Text(
                    title,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: MudabbirDesignTokens.goldBright,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                ],
                _SynchronousBlockErrorBoundary(
                  builder: () => buildBlockContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SynchronousBlockErrorBoundary extends StatelessWidget {
  const _SynchronousBlockErrorBoundary({required this.builder});

  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    try {
      return builder();
    } catch (error) {
      // Keep the rest of the canvas usable if this block's builder throws.
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.errorContainer,
        ),
        child: Text(
          'تعذر عرض هذه الكتلة.\n$error',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      );
    }
  }
}
