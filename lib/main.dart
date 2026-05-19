import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/quran_provider.dart';
import 'presentation/providers/abjad_provider.dart';
import 'presentation/providers/models_provider.dart';
import 'presentation/providers/sovereign_chat_provider.dart';
import 'presentation/providers/sovereign_backup_provider.dart';
import 'presentation/providers/cognitive_shield_provider.dart';
import 'presentation/providers/training_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'services/ollama_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تشغيل Ollama تلقائياً
  OllamaService().startServer().then((running) {
    debugPrint(running ? '✅ Ollama جاهز' : '⚠️ Ollama غير متاح');
  });
  
  runApp(const MudabbirApp());
}

class MudabbirApp extends StatelessWidget {
  const MudabbirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatProvider>(create: (_) => ChatProvider()),
        ChangeNotifierProvider<QuranProvider>(create: (_) => QuranProvider()),
        ChangeNotifierProvider<AbjadProvider>(create: (_) => AbjadProvider()),
        ChangeNotifierProvider<ModelsProvider>(create: (_) => ModelsProvider()),
        ChangeNotifierProvider<SovereignChatProvider>(create: (_) => SovereignChatProvider()),
        ChangeNotifierProvider<SovereignBackupProvider>(create: (_) => SovereignBackupProvider()),
        ChangeNotifierProvider<CognitiveShieldProvider>(create: (_) => CognitiveShieldProvider()),
        ChangeNotifierProvider<TrainingProvider>(create: (_) => TrainingProvider()),
      ],
      child: MaterialApp(
        title: 'مُدَبِّر الْأَسْرَارِ الْعُلْيَا',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
