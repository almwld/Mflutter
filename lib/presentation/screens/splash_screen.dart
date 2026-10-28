import 'package:flutter/material.dart';
import '../../services/nucleus_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  final NucleusService _core = NucleusService();
  String _message = 'تجهيز النواة المركزية…';
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _core.addListener(_refresh);
    _start();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _message = _core.knowledgeReady
          ? 'المعرفة المحلية جاهزة · ' + _core.uniqueAgentCount.toString() + ' وكيل معرّف'
          : _core.isInitializing ? 'تحميل النواة وفهرسة المصادر المحلية…' : 'تهيئة الواجهة';
    });
  }

  Future<void> _start() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    try { await _core.initialize(); } catch (error) {
      if (mounted) setState(() => _message = 'بدء محدود: ' + error.toString());
    }
    if (!mounted || _opened) return;
    _opened = true;
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const HomeScreen(),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    ));
  }

  @override
  void dispose() {
    _core.removeListener(_refresh);
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF10131A),
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(animation: _pulse, builder: (_, __) => Transform.scale(
        scale: .95 + _pulse.value * .1,
        child: Container(width: 150, height: 150,
          decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(.4 + _pulse.value * .5), width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(.15), blurRadius: 28, spreadRadius: 5)]),
          child: const Icon(Icons.psychology_alt_rounded, size: 64, color: Color(0xFFD4AF37)),
        ),
      )),
      const SizedBox(height: 24),
      const Text('مُدَبِّر', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Amiri')),
      const SizedBox(height: 8),
      const Text('الْأَسْرَارِ الْعُلْيَا', style: TextStyle(color: Color(0xFFB9BDC7), fontFamily: 'Amiri')),
      const SizedBox(height: 24),
      const SizedBox(width: 180, child: LinearProgressIndicator(minHeight: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)))),
      const SizedBox(height: 12),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Text(_message, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white70, fontSize: 12))),
    ])),
  );
}
