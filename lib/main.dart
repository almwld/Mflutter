import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// الثيمات
import 'core/themes/app_theme.dart';

// Providers
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/quran_provider.dart';
import 'presentation/providers/abjad_provider.dart';
import 'presentation/providers/models_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/training_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/insight_provider.dart';
import 'presentation/providers/sovereign_chat_provider.dart';
import 'presentation/providers/sovereign_backup_provider.dart';
import 'presentation/providers/cognitive_shield_provider.dart';

// الشاشة الرئيسية
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => InsightProvider()),
        ChangeNotifierProvider(create: (_) => SovereignChatProvider()),
        ChangeNotifierProvider(create: (_) => SovereignBackupProvider()),
        ChangeNotifierProvider(create: (_) => CognitiveShieldProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'مُدَبِّر',
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar', 'SA'),
            supportedLocales: const [Locale('ar', 'SA')],
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
