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

  ThemeData _applyPreferences(
    ThemeData base,
    ThemeProvider state, {
    required bool dark,
  }) {
    final palette = ThemeService.getTheme(state.selectedTheme);
    final brand = palette['primary']!;
    final accent = palette['secondary']!;
    final surface = palette[dark ? 'surface' : 'lightSurface']!;
    final background =
        palette[dark ? 'background' : 'lightBackground']!;
    final foreground =
        dark ? const Color(0xFFF7F4EC) : const Color(0xFF24202A);

    final scheme = dark
        ? ColorScheme.dark(
            primary: accent,
            onPrimary: background,
            secondary: brand,
            onSecondary: Colors.white,
            surface: surface,
            onSurface: foreground,
            error: const Color(0xFFFF6B6B),
          )
        : ColorScheme.light(
            primary: brand,
            onPrimary: Colors.white,
            secondary: accent,
            onSecondary: const Color(0xFF24202A),
            surface: surface,
            onSurface: foreground,
            error: const Color(0xFFB3261E),
          );

    final textTheme = base.textTheme.apply(
      fontFamily: state.fontFamily,
      fontSizeFactor: state.fontSize / 20,
      bodyColor: foreground,
      displayColor: foreground,
    );

    return base.copyWith(
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      primaryColor: brand,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: surface,
        foregroundColor: dark ? accent : brand,
        iconTheme: IconThemeData(color: dark ? accent : brand),
        titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(
          color: dark ? accent : brand,
          fontFamily: state.fontFamily,
          fontSize: state.fontSize,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(color: surface),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: surface,
        selectedItemColor: dark ? accent : brand,
        unselectedItemColor: foreground.withOpacity(.62),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: (dark ? accent : brand).withOpacity(.16),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? (dark ? accent : brand)
              : foreground.withOpacity(.62),
        )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontFamily: state.fontFamily,
          color: states.contains(WidgetState.selected)
              ? (dark ? accent : brand)
              : foreground.withOpacity(.72),
        )),
      ),
      dividerTheme: DividerThemeData(color: foreground.withOpacity(.12)),
      listTileTheme: ListTileThemeData(
        iconColor: dark ? accent : brand,
        textColor: foreground,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? accent : foreground),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? accent.withOpacity(.35)
                : foreground.withOpacity(.12)),
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
