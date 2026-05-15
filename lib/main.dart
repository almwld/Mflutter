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
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MudabbirApp());
}

class MudabbirApp extends StatelessWidget {
  const MudabbirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => AbjadProvider()),
        ChangeNotifierProvider(create: (_) => ModelsProvider()),
        ChangeNotifierProvider(create: (_) => SovereignChatProvider()),
        ChangeNotifierProvider(create: (_) => SovereignBackupProvider()),
        ChangeNotifierProvider(create: (_) => CognitiveShieldProvider()),
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
