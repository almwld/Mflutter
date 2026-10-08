import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MudabbirApp());
}

class MudabbirApp extends StatelessWidget {
  const MudabbirApp({super.key});

  ThemeData _applyPreferences(ThemeData base, ThemeProvider state, {required bool dark}) {
    final palette = ThemeService.getTheme(state.selectedTheme);
    final primary = palette['primary']!;
    final secondary = palette['secondary']!;
    final surface = palette['surface']!;
    final background = dark ? palette['background']! : AppTheme.lightBackground;
    final scheme = (dark
        ? ColorScheme.dark(
            primary: primary,
            onPrimary: Colors.white,
            secondary: secondary,
            onSecondary: Colors.black,
            surface: surface,
            onSurface: const Color(0xFFF7F4EC),
            error: const Color(0xFFFF6B6B),
          )
        : ColorScheme.light(
            primary: primary,
            onPrimary: Colors.white,
            secondary: secondary,
            onSecondary: Colors.black,
            surface: AppTheme.lightSurface,
            onSurface: const Color(0xFF24202A),
            error: const Color(0xFFB3261E),
          ));
    final textTheme = base.textTheme.apply(
      fontFamily: state.fontFamily,
      fontSizeFactor: state.fontSize / 20,
    );
    return base.copyWith(
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: dark ? surface : primary,
        foregroundColor: secondary,
        iconTheme: IconThemeData(color: secondary),
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: secondary,
          fontFamily: state.fontFamily,
          fontSize: state.fontSize,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: dark ? surface : AppTheme.lightSurface,
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: dark ? surface : primary,
        selectedItemColor: secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, state, _) => MaterialApp(
          title: 'مُدَبِّر',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [Locale('ar', 'SA')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
          themeMode: state.themeMode,
          theme: _applyPreferences(AppTheme.lightTheme, state, dark: false),
          darkTheme: _applyPreferences(AppTheme.darkTheme, state, dark: true),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
