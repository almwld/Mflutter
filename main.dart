import 'package:flutter/material.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المصحف الشريف',
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
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'QCF',
        scaffoldBackgroundColor: const Color(0xFFFDF9F3),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      ),
      themeMode: ThemeMode.system,
      home: const QuranViewer(),
    );
  }
}

class QuranViewer extends StatefulWidget {
  const QuranViewer({super.key});

  @override
  State<QuranViewer> createState() => _QuranViewerState();
}

class _QuranViewerState extends State<QuranViewer> {
  final PageController _pageController = PageController(initialPage: 0);
  List<HighlightVerse> _highlights = [];
  int _currentPage = 1;
  bool _showBars = true;

  @override
  void initState() {
    super.initState();
    _loadLastPage();
  }

  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPage = prefs.getInt('lastPage') ?? 0;
    _pageController.jumpToPage(lastPage);
  }

  Future<void> _savePage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPage', page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showBars = !_showBars),
              child: QuranPageView(
                pageController: _pageController,
                highlights: _highlights,
                onPageChanged: (page) {
                  setState(() => _currentPage = page + 1);
                  _savePage(page);
                },
                onLongPress: (surah, verse, details) {
                  _showVerseActions(surah, verse, details);
                },
              ),
            ),
            if (_showBars)
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الجزء ${_getJuz(_currentPage)}',
                          style: const TextStyle(fontSize: 14, fontFamily: 'Amiri')),
                      Text('صفحة $_currentPage / 604',
                          style: const TextStyle(fontSize: 14, fontFamily: 'Amiri')),
                    ],
                  ),
                ),
              ),
            if (_showBars)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: const Icon(Icons.search), onPressed: _showSearch),
                      IconButton(icon: const Icon(Icons.bookmark), onPressed: () => _savePage(_currentPage - 1)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _getJuz(int page) {
    if (page <= 21) return 1; if (page <= 41) return 2; if (page <= 61) return 3;
    if (page <= 81) return 4; if (page <= 101) return 5; if (page <= 121) return 6;
    if (page <= 141) return 7; if (page <= 161) return 8; if (page <= 181) return 9;
    if (page <= 201) return 10; if (page <= 221) return 11; if (page <= 241) return 12;
    if (page <= 261) return 13; if (page <= 281) return 14; if (page <= 301) return 15;
    if (page <= 321) return 16; if (page <= 341) return 17; if (page <= 361) return 18;
    if (page <= 381) return 19; if (page <= 401) return 20; if (page <= 421) return 21;
    if (page <= 441) return 22; if (page <= 461) return 23; if (page <= 481) return 24;
    if (page <= 501) return 25; if (page <= 521) return 26; if (page <= 541) return 27;
    if (page <= 561) return 28; if (page <= 581) return 29;
    return 30;
  }

  void _showVerseActions(int surah, int verse, Map<String, dynamic> details) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.copy), title: Text('نسخ الآية $verse'), onTap: () => Navigator.pop(ctx)),
            ListTile(leading: const Icon(Icons.format_paint), title: const Text('تظليل الآية'), onTap: () {
              setState(() { _highlights.add(HighlightVerse(surah: surah, verse: verse)); });
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  void _showSearch() {
    showSearch(context: context, delegate: _QuranSearch());
  }
}

class _QuranSearch extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));
  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
  @override
  Widget buildSuggestions(BuildContext context) => Center(child: Text('ابحث: $query', style: const TextStyle(fontFamily: 'Amiri', fontSize: 18)));
}
