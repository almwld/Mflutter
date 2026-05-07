import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/quran_provider.dart';
import 'presentation/providers/abjad_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/models_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/insight_provider.dart';
import 'presentation/screens/splash_screen.dart';

/// =============================================================================
/// مُدَبِّر الْأَسْرَارِ الْعُلْيَا - نقطة البداية
/// =============================================================================
/// التطبيق يعمل بالكامل بدون إنترنت
/// يدعم RTL العربية
/// تصميم Material Design 3: كحلي (#1A237E) + ذهبي (#FFD700)
/// =============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MudabbirApp());
}

/// =============================================================================
/// clasee MudabbirApp - التطبيق الرئيسي
/// =============================================================================
/// يُهيئ الثيم والـ providers والمترجمات
/// =============================================================================

class MudabbirApp extends StatelessWidget {
  const MudabbirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => AbjadProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ModelsProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => InsightProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'مُدَبِّر الْأَسْرَارِ الْعُلْيَا',
            debugShowCheckedModeBanner: false,

            // إعدادات المترجمات للـ RTL
            locale: const Locale('ar', 'SA'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
            ],

            // الثيم
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // الشاشة الرئيسية
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}