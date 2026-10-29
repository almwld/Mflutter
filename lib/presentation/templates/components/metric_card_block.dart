import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/themes/mudabbir_design_tokens.dart';
import 'base_universal_block.dart';

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
    return Column(
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
  }
}
