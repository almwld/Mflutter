import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFD700), width: 2)),
            child: const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 40),
          ),
          const SizedBox(height: 24),
          const Text('مُدَبِّر', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFFD700), fontFamily: 'Amiri')),
          const Text('الْأَسْرَارِ الْعُلْيَا', style: TextStyle(fontSize: 14, color: Color(0xFFB8860B), fontFamily: 'Amiri')),
        ]),
      ),
    );
  }
}
