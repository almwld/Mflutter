import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'services/theme_service.dart';
import 'services/nucleus_service.dart';
import 'services/achievements_service.dart';
import 'core/themes/font_manager.dart';

Future<void> _loadBundledKufiFont() async {
  try {
    // The font is bundled as base64 text to keep the repository transport-safe;
    // it is decoded locally at startup and requires no network access.
    final encoded = await rootBundle.loadString(
      'assets/fonts/Raqq.ttf.base64',
    );
    final bytes = Uint8List.fromList(
      base64Decode(encoded.replaceAll(RegExp(r'\s+'), '')),
    );
    final loader = FontLoader('Raqq')
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load();
    FontManager.markRaqqFontLoaded(true);
  } catch (_) {
    FontManager.markRaqqFontLoaded(false);
    // Keep the app usable if the optional display font cannot be loaded.
  }

  try {
    final encoded = await rootBundle.loadString(
      'assets/fonts/RaqqSura.ttf.base64',
    );
    final bytes = Uint8List.fromList(
      base64Decode(encoded.replaceAll(RegExp(r'\s+'), '')),
    );
    final loader = FontLoader('RaqqSura')
      ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    await loader.load();
    FontManager.markRaqqSuraFontLoaded(true);
  } catch (_) {
    FontManager.markRaqqSuraFontLoaded(false);
    // Surah titles retain their standard Amiri fallback if unavailable.
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AchievementsService.recordNightUseIfApplicable();
  await _loadBundledKufiFont();
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
    return ChangeNotifierProvider<NucleusService>.value(
      value: NucleusService(),
      child: ChangeNotifierProvider(
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
      ),
    );
  }
}
