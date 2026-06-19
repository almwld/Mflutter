import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// =============================================================================
/// SearchBarWidget - ويدجت شريط البحث
/// =============================================================================

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final String hintText;
  final bool isLoading;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.onClear,
    this.hintText = 'بحث...',
    this.isLoading = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    if (hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.2 * _focusAnimation.value),
                blurRadius: 8 + (8 * _focusAnimation.value),
                spreadRadius: 1 * _focusAnimation.value,
              ),
            ],
          ),
          child: Focus(
            onFocusChange: _onFocusChange,
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearch,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Colors.white38,
                ),
                prefixIcon: widget.isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.gold,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search, color: AppColors.gold),
                        onPressed: () => widget.onSearch(_controller.text),
                      ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _controller.clear();
                          widget.onClear?.call();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: BorderSide(
                    color: AppColors.gold.withOpacity(0.3 + (0.4 * _focusAnimation.value)),
                    width: 1 + _focusAnimation.value,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: BorderSide(
                    color: AppColors.gold.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: const BorderSide(
                    color: AppColors.gold,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}