import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/models_provider.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToHome();
  }

  Future<void> _goToHome() async {
    try { await context.read<ModelsProvider>().initialize(); } catch (_) {}
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Color(0xFFFFD700)),
            SizedBox(height: 24),
            Text('مُدَبِّر الْأَسْرَارِ الْعُلْيَا',
              style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('رافقك الله في رحلتك',
              style: TextStyle(fontSize: 16, color: Color(0xFFFFD700))),
            SizedBox(height: 48),
            SizedBox(width: 200, child: LinearProgressIndicator(
              backgroundColor: Color(0xFFFFD700).withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            )),
          ],
        ),
      ),
    );
  }
}
