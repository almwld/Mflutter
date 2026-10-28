import 'package:flutter/material.dart';

import '../../../core/themes/mudabbir_design_tokens.dart';

/// A reusable translucent surface with restrained border and optional glow.
///
/// It deliberately avoids a full-screen backdrop blur so scrolling and
/// animation remain affordable on mid-range Android devices.
class MudabbirGlassPanel extends StatelessWidget {
  const MudabbirGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = MudabbirDesignTokens.cardRadius,
    this.color = MudabbirDesignTokens.glassSurface,
    this.borderColor = MudabbirDesignTokens.glassBorder,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: glow
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x18D4AF37),
                  blurRadius: 22,
                  offset: Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
