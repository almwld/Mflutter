import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VoiceSearchWidget extends StatefulWidget {
  final Function(String) onResult;
  const VoiceSearchWidget({super.key, required this.onResult});

  @override
  State<VoiceSearchWidget> createState() => _VoiceSearchWidgetState();
}

class _VoiceSearchWidgetState extends State<VoiceSearchWidget> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000))..repeat(reverse: true);
  }

  void _toggleListening() {
    setState(() => _isListening = !_isListening);
    if (_isListening) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _isListening = false);
          widget.onResult('بحث صوتي: القرآن الكريم');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening ? AppColors.primaryGold.withOpacity(0.3) : AppColors.surface,
              boxShadow: _isListening ? [BoxShadow(color: AppColors.primaryGold.withOpacity(0.5), blurRadius: 20 * _pulseController.value, spreadRadius: 5 * _pulseController.value)] : [],
            ),
            child: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? AppColors.primaryGold : Colors.white54,
              size: 28,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
