import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'lib/presentation/screens/quran/mushaf_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MudabbirApp());
}

class MudabbirApp extends StatelessWidget {
  const MudabbirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مُدَبِّر الأسرار العليا',
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
        child: child ?? const SizedBox.shrink(),
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F1E4),
      ),
      home: const MushafScreen(),
    );
  }
}
