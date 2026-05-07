import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/models_provider.dart';

/// =============================================================================
/// SplashScreen - شاشة البداية
/// =============================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // تحميل النماذج
    final modelsProvider = context.read<ModelsProvider>();
    await modelsProvider.initialize();

    // انتظار
    await Future.delayed(const Duration(seconds: 2));

    // الانتقال للشاشة الرئيسية
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الأيقونة
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFD700).withOpacity(0.3),
                          const Color(0xFFFFD700).withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 80,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // العنوان
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: const Column(
                    children: [
                      Text(
                        'مُدَبِّر الْأَسْرَارِ الْعُلْيَا',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'رافقك الله في رحلتك',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // مؤشر التحميل
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: const Color(0xFFFFD700).withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFD700),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}