import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/themes/mudabbir_design_tokens.dart';
import 'base_universal_block.dart';
import 'block_event_bus.dart';
import 'block_event_scope.dart';

/// Compact metric presentation. The value must come from a trusted service;
/// this widget never computes or infers a metric.
class MetricCardBlock extends BaseUniversalBlock {
  const MetricCardBlock({
    super.key,
    required super.title,
    required super.data,
    super.styleHints,
  });

  @override
  Widget buildBlockContent(BuildContext context) {
    final value = data['value'];
    final unit = data['unit'];
    final description = data['description'];
    final hasValue = value is String || value is num || value is bool;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          hasValue ? value.toString() : 'القيمة غير متاحة',
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: MudabbirDesignTokens.goldBright,
                fontWeight: FontWeight.w800,
              ),
        ),
        if (unit is String && unit.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(unit, textDirection: TextDirection.rtl),
        ],
        if (description is String && description.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            description,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (data['copyable'] == true && hasValue) ...[
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value.toString()));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ القيمة')),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('نسخ القيمة'),
            ),
          ),
        ],
      ],
    );
    final selectionId = data['selection_id'];
    final targetBlockId = data['target_block_id'];
    if (selectionId is! String || selectionId.isEmpty ||
        targetBlockId is! String || targetBlockId.isEmpty) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(MudabbirDesignTokens.cardRadius),
      onTap: () {
        HapticFeedback.selectionClick();
        BlockEventScope.maybeOf(context)?.publish(BlockEvent(
          type: 'selection_changed',
          sourceBlockId: data['_canvas_block_id'] is String
              ? data['_canvas_block_id'] as String
              : 'metric',
          targetBlockId: targetBlockId,
          payload: <String, Object?>{'selection_id': selectionId},
        ));
      },
      child: content,
    );
  }
}
