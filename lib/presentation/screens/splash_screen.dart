import 'package:flutter/material.dart';
import '../../services/ollama_service.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'جاري تشغيل النواة...';
  bool _ollamaReady = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. تشغيل Ollama
    setState(() => _status = 'جاري تشغيل خادم الذكاء الاصطناعي...');
    _ollamaReady = await OllamaService().startServer();
    
    if (_ollamaReady) {
      setState(() => _status = '✅ النموذج جاهز');
    } else {
      setState(() => _status = '⚠️ النموذج غير متاح — سيعمل بدون ذكاء اصطناعي');
    }

    // 2. انتظر لحظة ثم انتقل
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Color(0xFFFFD700)),
            const SizedBox(height: 24),
            const Text(
              'مُدَبِّر الْأَسْرَارِ الْعُلْيَا',
              style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // مؤشر حالة Ollama
            Icon(
              _ollamaReady ? Icons.check_circle : Icons.warning_amber,
              color: _ollamaReady ? Colors.green : Colors.orange,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              _status,
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Color(0x33FFD700),
                color: Color(0xFFFFD700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
