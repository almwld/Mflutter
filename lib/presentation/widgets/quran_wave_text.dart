import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A word-by-word, right-to-left scale wave for Quran text.
///
/// The original Quran words and diacritics are displayed unchanged. There is
/// no shimmer, glow, camera, visual tracking, or network processing. Only
/// selected key words gently grow and return to their normal size as the wave
/// moves through the rendered line(s).
class QuranWaveText extends StatefulWidget {
  const QuranWaveText({
    super.key,
    required this.text,
    required this.style,
    this.importanceText,
    this.enabled = true,
    this.sequenceWordCount,
    this.sequenceWordOffset = 0,
    this.stepDuration = const Duration(milliseconds: 180),
    this.peakScale = 1.15,
    this.textAlign = WrapAlignment.start,
  });

  final String text;
  final TextStyle style;
  /// Original Arabic source used to identify key words in transformed scripts.
  final String? importanceText;
  final bool enabled;

  /// When set, several line widgets can share one page-wide wave timeline.
  /// Every line must receive the same count and its cumulative word offset.
  final int? sequenceWordCount;
  final int sequenceWordOffset;
  final Duration stepDuration;
  final double peakScale;
  final WrapAlignment textAlign;

  @override
  State<QuranWaveText> createState() => _QuranWaveTextState();
}

class _QuranWaveTextState extends State<QuranWaveText>
    with SingleTickerProviderStateMixin {
  static const Set<String> _importantWords = {
    'الله', 'اللهم', 'رب', 'ربي', 'ربنا', 'الرحمن', 'الرحيم', 'آمنوا',
    'الإيمان', 'الصلاة', 'الزكاة', 'القرآن', 'الكتاب', 'الجنة', 'النار',
    'الحق', 'النور', 'رحمة', 'رحمت', 'غفور', 'غفورا', 'عليم', 'حكيم',
    'التقوى', 'المتقين', 'الصابرين', 'الظالمين', 'الآيات', 'الساعة',
    'الدنيا', 'الآخرة', 'الحياة', 'الموت', 'عباد', 'رسول', 'رسولا',
    'نبي', 'النبي', 'هدى', 'الهدى', 'سبحان', 'الحمد', 'الملك',
    'القدوس', 'العزيز', 'الحكيم', 'الغفور', 'التواب', 'الرزاق',
    'السماوات', 'الأرض', 'الرحمة', 'النعيم', 'العذاب', 'الفوز',
  };

  late List<String> _words;
  late List<String> _importanceWords;
  late AnimationController _controller;
  late Duration _duration;

  int get _sequenceCount =>
      math.max(1, widget.sequenceWordCount ?? _words.length).toInt();

  static List<String> _splitWords(String text) =>
      text.trim().isEmpty ? <String>[] : text.trim().split(RegExp(r'\s+'));

  static String _normalize(String word) {
    return word
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'[۞۩،؛؟!.:﴿﴾()\[\]«»"“”]'), '')
        .trim();
  }

  bool _isImportant(String word) {
    final normalized = _normalize(word);
    if (_importantWords.contains(normalized)) return true;
    if (normalized.length > 1 &&
        'وفبكل'.contains(normalized.substring(0, 1))) {
      return _importantWords.contains(normalized.substring(1));
    }
    return false;
  }

  Duration _animationDuration() {
    final count = widget.sequenceWordCount ?? _words.length;
    final milliseconds = math.max(
      2400,
      count * widget.stepDuration.inMilliseconds,
    );
    return Duration(milliseconds: milliseconds.toInt());
  }

  @override
  void initState() {
    super.initState();
    _words = widget.text.trim().isEmpty
        ? <String>[]
        : widget.text.trim().split(RegExp(r'\s+'));
    _importanceWords = _splitWords(widget.importanceText ?? widget.text);
    _duration = _animationDuration();
    _controller = AnimationController(vsync: this, duration: _duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant QuranWaveText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.importanceText != widget.importanceText ||
        oldWidget.sequenceWordCount != widget.sequenceWordCount ||
        oldWidget.stepDuration != widget.stepDuration) {
      _words = _splitWords(widget.text);
      _importanceWords = _splitWords(widget.importanceText ?? widget.text);
      _duration = _animationDuration();
      _controller.duration = _duration;
      _controller.value = 0;
    }
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.text != widget.text ||
        oldWidget.importanceText != widget.importanceText ||
        oldWidget.sequenceWordCount != widget.sequenceWordCount ||
        oldWidget.stepDuration != widget.stepDuration) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!widget.enabled ||
        reduceMotion ||
        !TickerMode.of(context) ||
        _words.isEmpty) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  double _scaleForWord(int index) {
    if (index >= _importanceWords.length ||
        !_isImportant(_importanceWords[index])) return 1;
    final globalPosition = _controller.value * _sequenceCount;
    final localPosition = globalPosition - widget.sequenceWordOffset;
    final distance = (localPosition - index).abs();
    if (distance >= 1) return 1;
    final envelope = math.sin((1 - distance) * math.pi / 2);
    return 1 + ((widget.peakScale - 1) * envelope);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) return const SizedBox.shrink();

    if (!widget.enabled ||
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false)) {
      return Semantics(
        label: widget.text,
        child: ExcludeSemantics(child: _buildWords((_) => 1)),
      );
    }

    return Semantics(
      label: widget.text,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => _buildWords(_scaleForWord),
          ),
        ),
      ),
    );
  }

  Widget _buildWords(double Function(int index) scaleForWord) {
    return Wrap(
      alignment: widget.textAlign,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      textDirection: TextDirection.rtl,
      spacing: 8,
      runSpacing: 7,
      children: [
        for (var index = 0; index < _words.length; index++)
          Transform.scale(
            scale: scaleForWord(index),
            alignment: Alignment.center,
            child: Text(
              _words[index],
              textDirection: TextDirection.rtl,
              style: widget.style,
              softWrap: false,
            ),
          ),
      ],
    );
  }
}
