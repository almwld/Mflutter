import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// =============================================================================
/// EnergyBar - شريط الطاقة
/// =============================================================================

class EnergyBar extends StatefulWidget {
  final double value;
  final double maxValue;
  final String label;
  final Color color;
  final bool showPulse;

  const EnergyBar({
    super.key,
    required this.value,
    this.maxValue = 100,
    this.label = 'الطاقة',
    this.color = AppColors.gold,
    this.showPulse = true,
  });

  @override
  State<EnergyBar> createState() => _EnergyBarState();
}

class _EnergyBarState extends State<EnergyBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.showPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EnergyBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.showPulse && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.value / widget.maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            Text(
              '${widget.value.toInt()}%',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: MediaQuery.of(context).size.width * 0.3 * percentage,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color.withOpacity(widget.showPulse ? _pulseAnimation.value : 1.0),
                          widget.color.withOpacity((widget.showPulse ? _pulseAnimation.value : 1.0) * 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: widget.showPulse
                          ? [
                              BoxShadow(
                                color: widget.color.withOpacity(0.5 * _pulseAnimation.value),
                                blurRadius: 4 * _pulseAnimation.value,
                                spreadRadius: 1 * _pulseAnimation.value,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}