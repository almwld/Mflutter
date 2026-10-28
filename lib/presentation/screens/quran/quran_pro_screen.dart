import 'dart:async';
import 'dart:convert';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qcf_quran_lite/qcf_quran_lite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/text_transformer.dart';
import '../../../core/themes/font_manager.dart';
import '../../../services/musnad_quran_service.dart';
import '../../../services/hieroglyphic_quran_service.dart';
import '../../../services/quran_source_corrections.dart';
import '../../../services/nucleus_service.dart';
import '../../../services/bookmark_service.dart';
import '../../../services/daily_streak_service.dart';
import '../../../services/share_service.dart';
import '../../../services/quran_fonts_service.dart';
import '../../widgets/quran_wave_text.dart';

enum QuranDisplayMode { uthmaniGold, musnadAncient, dotlessMarked, dotless, kufi, hieroglyphic }

/// 📖 شاشة القرآن الاحترافية — 5 أنماط عرض
class QuranProScreen extends StatefulWidget {
  const QuranProScreen({super.key});

  @override
  State<QuranProScreen> createState() => _QuranProScreenState();
}

class _QuranProScreenState extends State<QuranProScreen> {
  // البيانات
  Map<String, dynamic>? _quran;
  Map<String, List<Map<String, dynamic>>>? _musnadQuran;
  Map<String, List<Map<String, dynamic>>>? _hieroglyphicQuran;
  List<dynamic> _currentVerses = [];
  int _currentSurah = 1;
  int? _selectedAyah;
  String? _selectedAyahText;
  String _surahName = 'الفاتحة';
  bool _loading = true;
  String? _variantWarning;

  // العرض
  QuranDisplayMode _mode = QuranDisplayMode.uthmaniGold;
  double _fontSize = 22;
  bool _showFrame = true;
  bool _waveEnabled = true;
  bool _chromeVisible = true;
  bool _autoScroll = false;
  Timer? _autoScrollTimer;

  // متحكمات
  final ScrollController _scroll = ScrollController();
  final Map<int, GlobalKey> _verseKeys = <int, GlobalKey>{};

  // الثوابت
  static const _bgColor = Color(0xFF0A0E27);
  static const _goldColor = Color(0xFFFFD700);

  // فهرس كامل للسور الـ114 من مصدر أسماء السور المستخدم في المصحف.
  late final List<Map<String, dynamic>> _surahs = List.generate(
    114,
    (index) => {'n': index + 1, 'name': getSurahNameArabic(index + 1)},
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge).catchError((error) {
      debugPrint('QuranProScreen: could not set initial system bars: $error');
    });
    _restoreDisplayMode();
    _restoreReadingPreferences();
    _loadQuran();
    _loadQuranFonts();
  }

  Future<void> _loadQuranFonts() async {
    await QuranFontsService.load();
    FontManager.markRaqqFontLoaded(QuranFontsService.isRaqqLoaded);
    FontManager.markRaqqSuraFontLoaded(QuranFontsService.isRaqqSuraLoaded);
    if (mounted) setState(() {});
  }

  Future<void> _loadQuran() async {
    try {
      // Only the canonical Arabic Quran asset is required to open the reader.
      final jsonStr = await rootBundle.loadString('assets/unified_quran.json');
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('صيغة بيانات المصحف غير صحيحة');
      }
      if (!mounted) return;
      setState(() {
        _quran = QuranSourceCorrections.correctQuranMap(
          Map<String, dynamic>.from(decoded),
        );
        _loading = false;
      });

      try {
        final preferences = await SharedPreferences.getInstance();
        final savedSurah =
            preferences.getInt('mudabbir_quran_pro_last_surah') ?? 1;
        _loadSurah(savedSurah.clamp(1, 114).toInt());
      } catch (error) {
        debugPrint('QuranProScreen: could not restore last surah: $error');
        _loadSurah(1);
      }

      // Optional experimental scripts load after canonical reading is usable.
      // The reader remains responsive while these separate datasets are parsed.
      unawaited(_loadOptionalScriptDatasets());
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تحميل بيانات المصحف: $error')),
      );
    }
  }

  Future<void> _loadOptionalScriptDatasets() async {
    Map<String, List<Map<String, dynamic>>>? musnadQuran;
    Map<String, List<Map<String, dynamic>>>? hieroglyphicQuran;
    final warnings = <String>[];
    try {
      musnadQuran = await MusnadQuranService.load();
    } catch (error) {
      warnings.add('بيانات المسند غير متاحة؛ سيُستخدم تحويل العرض المحلي عند الإمكان.');
      debugPrint('QuranProScreen: Musnad dataset unavailable: $error');
    }
    try {
      hieroglyphicQuran = await HieroglyphicQuranService.load();
    } catch (error) {
      warnings.add('بيانات الهيروغليفي غير متاحة؛ سيُستخدم تحويل العرض المحلي عند الإمكان.');
      debugPrint('QuranProScreen: hieroglyphic dataset unavailable: $error');
    }
    if (!mounted) return;
    setState(() {
      _musnadQuran = musnadQuran;
      _hieroglyphicQuran = hieroglyphicQuran;
      _variantWarning = warnings.isEmpty ? null : warnings.join(' ');
    });
  }

  void _loadSurah(int n) {
    final quran = _quran;
    if (quran == null || n < 1 || n > 114) return;
    final surah = _surahs.where((s) => s['n'] == n);
    final verses = quran[n.toString()];
    setState(() {
      _currentSurah = n;
      _selectedAyah = null;
      _selectedAyahText = null;
      _currentVerses = verses is List ? List<dynamic>.from(verses) : <dynamic>[];
      _surahName = surah.isNotEmpty ? surah.first['name'] as String : 'سورة $n';
      _verseKeys.clear();
    });
    unawaited(SharedPreferences.getInstance().then((preferences) {
      return preferences.setInt('mudabbir_quran_pro_last_surah', n);
    }).catchError((error) {
      debugPrint('QuranProScreen: could not save last surah: $error');
    }));
    unawaited(DailyStreakService.recordActivity().catchError((_) {}));
    // A newly opened surah has no selected verse yet; do not leave the nucleus
    // pointed at the first verse or at a verse selected in a previous surah.
    NucleusService().clearQuranContext();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  Future<void> _restoreReadingPreferences() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _fontSize = (preferences.getDouble('mudabbir_quran_pro_font_size') ?? 22)
            .clamp(14.0, 40.0).toDouble();
        _showFrame = preferences.getBool('mudabbir_quran_pro_show_frame') ?? true;
        _waveEnabled = preferences.getBool('mudabbir_quran_pro_wave_enabled') ?? true;
      });
    } catch (error) {
      debugPrint('QuranProScreen: could not restore reading preferences: $error');
    }
  }

  Future<void> _persistReaderPreference(
    Future<bool> Function(SharedPreferences preferences) write,
    String setting,
  ) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await write(preferences);
      if (!saved) {
        debugPrint('QuranProScreen: preference write was rejected: $setting');
      }
    } catch (error) {
      // Keep the current reader controls usable even when persistence fails.
      debugPrint('QuranProScreen: could not save $setting: $error');
    }
  }

  Future<void> _changeFontSize(double delta) async {
    final next = (_fontSize + delta).clamp(14.0, 40.0).toDouble();
    setState(() => _fontSize = next);
    await _persistReaderPreference(
      (preferences) => preferences.setDouble('mudabbir_quran_pro_font_size', next),
      'font size',
    );
  }

  Future<void> _toggleFrame() async {
    final next = !_showFrame;
    setState(() => _showFrame = next);
    await _persistReaderPreference(
      (preferences) => preferences.setBool('mudabbir_quran_pro_show_frame', next),
      'verse frame',
    );
  }

  Future<void> _toggleWave() async {
    final next = !_waveEnabled;
    setState(() => _waveEnabled = next);
    await _persistReaderPreference(
      (preferences) => preferences.setBool('mudabbir_quran_pro_wave_enabled', next),
      'word wave',
    );
  }

  Future<void> _restoreDisplayMode() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedIndex = preferences.getInt('mudabbir_quran_pro_mode_v2');
      if (savedIndex == null ||
          savedIndex < 0 ||
          savedIndex >= QuranDisplayMode.values.length ||
          !mounted) {
        return;
      }
      setState(() => _mode = QuranDisplayMode.values[savedIndex]);
    } catch (error) {
      debugPrint('QuranProScreen: could not restore display mode: $error');
    }
  }

  Future<void> _setDisplayMode(QuranDisplayMode mode) async {
    setState(() => _mode = mode);
    await _persistReaderPreference(
      (preferences) => preferences.setInt('mudabbir_quran_pro_mode_v2', mode.index),
      'display mode',
    );
  }

  String _transform(String text) {
    switch (_mode) {
      case QuranDisplayMode.musnadAncient:
        return TextTransformer.toMusnad(text);
      case QuranDisplayMode.dotlessMarked:
        return FontManager.isRaqqFontLoaded
            ? text
            : TextTransformer.toDotlessPreservingMarks(text);
      case QuranDisplayMode.dotless:
        return FontManager.isRaqqFontLoaded
            ? TextTransformer.removeArabicMarks(text)
            : TextTransformer.toDotless(text);
      case QuranDisplayMode.kufi:
        return text;
      case QuranDisplayMode.hieroglyphic:
        return TextTransformer.toHieroglyphic(text);
      case QuranDisplayMode.uthmaniGold:
        return text;
    }
  }

  TextStyle _textStyle() {
    return TextStyle(
      fontSize: _fontSize,
      fontFamily: _mode == QuranDisplayMode.musnadAncient
          ? 'Musnad'
          : _mode == QuranDisplayMode.hieroglyphic
              ? 'NotoSansEgyptianHieroglyphs'
              : (_mode == QuranDisplayMode.kufi ||
                      _mode == QuranDisplayMode.dotlessMarked ||
                      _mode == QuranDisplayMode.dotless) &&
                  FontManager.isRaqqFontLoaded
                  ? 'Raqq'
                  : 'Amiri',
      fontFeatures: FontManager.isRaqqFontLoaded &&
              (_mode == QuranDisplayMode.dotlessMarked ||
                  _mode == QuranDisplayMode.dotless)
          ? const [FontFeature.enable('ss01')]
          : const [],
      fontWeight: FontWeight.bold,
      color: _mode == QuranDisplayMode.uthmaniGold
          ? const Color(0xFFFFD700)
          : _mode == QuranDisplayMode.musnadAncient
              ? const Color(0xFFB8860B)
              : _mode == QuranDisplayMode.hieroglyphic
                  ? const Color(0xFFCD853F)
                  : const Color(0xFFDAA520),
      height: 2.2,
      letterSpacing: _mode == QuranDisplayMode.musnadAncient
          ? 4
          : _mode == QuranDisplayMode.hieroglyphic
              ? 2.5
              : 1.5,
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scroll.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge).catchError((error) {
      debugPrint('QuranProScreen: could not restore system bars on dispose: $error');
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _goldColor)),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _chromeVisible ? _buildAppBar() : null,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: _toggleChrome,
        child: Column(
          children: [
            if (_chromeVisible) _buildModeBar(),
            if (_chromeVisible && _variantWarning != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.orange.withOpacity(.12),
                child: Text(
                  _variantWarning!,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
                ),
              ),
            Expanded(child: _buildVerseList()),
          ],
        ),
      ),
      bottomNavigationBar: _chromeVisible ? _buildBottomBar() : null,
    );
  }

  /// Search normalization is presentation-only; the canonical Quran text
  /// remains untouched. It allows matches regardless of tashkeel, tatweel,
  /// common alef variants, and Arabic/Persian digit keyboards.
  String _normalizeSearchText(String value) => value
      .replaceAllMapped(
        RegExp(r'[٠-٩۰-۹]'),
        (match) {
          final code = match.group(0)!.codeUnitAt(0);
          final digit = code >= 0x06F0 && code <= 0x06F9
              ? code - 0x06F0
              : code - 0x0660;
          return String.fromCharCode(0x30 + digit);
        },
      )
      .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll(RegExp(r'[ؤئ]'), 'ء')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Future<void> _searchCurrentSurah() async {
    if (_currentVerses.isEmpty) return;
    final controller = TextEditingController();
    var query = '';
    final selectedIndex = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final normalized = _normalizeSearchText(query);
          final matches = <int>[];
          for (var i = 0; i < _currentVerses.length; i++) {
            final verse = _currentVerses[i];
            final text = verse is Map ? (verse['text']?.toString() ?? '') : '';
            final normalizedVerse = _normalizeSearchText(text);
            final numberMatches = normalized.isNotEmpty &&
                (i + 1).toString() == normalized;
            if (normalized.isEmpty ||
                normalizedVerse.contains(normalized) ||
                numberMatches) {
              matches.add(i);
            }
          }
          return AlertDialog(
            title: Text('البحث في سورة ${_surahName}'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textDirection: TextDirection.rtl,
                    onChanged: (value) => setDialogState(() => query = value),
                    decoration: InputDecoration(
                      hintText: 'اكتب كلمة أو رقم الآية',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'مسح البحث',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                controller.clear();
                                setDialogState(() => query = '');
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: matches.isEmpty
                        ? const Center(child: Text('لا توجد آيات مطابقة'))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: matches.length.clamp(0, 80).toInt(),
                            itemBuilder: (_, row) {
                              final index = matches[row];
                              final verse = _currentVerses[index];
                              final text = verse is Map
                                  ? (verse['text']?.toString() ?? '')
                                  : '';
                              return ListTile(
                                dense: true,
                                title: Text('الآية ${index + 1}',
                                    textDirection: TextDirection.rtl),
                                subtitle: Text(text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: TextDirection.rtl),
                                onTap: () => Navigator.of(dialogContext).pop(index),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('إغلاق'),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
    if (selectedIndex == null || !mounted) return;
    final selectedVerse = _currentVerses[selectedIndex];
    final selectedText =
        selectedVerse is Map ? selectedVerse['text']?.toString() ?? '' : '';
    setState(() {
      _selectedAyah = selectedIndex + 1;
      _selectedAyahText = selectedText;
    });
    NucleusService().setQuranContext(
      surahNumber: _currentSurah,
      ayahNumber: selectedIndex + 1,
      verseText: selectedText,
    );
    var targetContext = _verseKeys[selectedIndex]?.currentContext;
    // ListView.builder creates off-screen rows lazily. Move near the target first
    // so its keyed context exists even when the result is far down the surah.
    if (targetContext == null && _scroll.hasClients) {
      final position = _scroll.position;
      final estimatedOffset = (selectedIndex * 180.0)
          .clamp(0.0, position.maxScrollExtent).toDouble();
      await _scroll.animateTo(
        estimatedOffset,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      targetContext = _verseKeys[selectedIndex]?.currentContext;
    }
    if (targetContext != null) {
      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
        alignment: 0.2,
      );
    }
  }

  void _toggleAutoScroll() {
    if (_autoScroll) {
      _autoScrollTimer?.cancel();
      _autoScrollTimer = null;
      setState(() => _autoScroll = false);
      return;
    }
    if (!_scroll.hasClients) return;
    setState(() => _autoScroll = true);
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (!mounted || !_scroll.hasClients) return;
      final position = _scroll.position;
      if (position.pixels >= position.maxScrollExtent) {
        _autoScrollTimer?.cancel();
        _autoScrollTimer = null;
        setState(() => _autoScroll = false);
        return;
      }
      _scroll.animateTo(
        (position.pixels + 110).clamp(0.0, position.maxScrollExtent).toDouble(),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _shareSelectedAyah() async {
    final ayah = _selectedAyah;
    final text = _selectedAyahText;
    if (ayah == null || text == null || text.isEmpty) return;

    try {
      await ShareService.shareVerse(
        text: text,
        surahNumber: _currentSurah,
        ayahNumber: ayah,
        surahName: _surahName,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذرت مشاركة الآية: $error')),
      );
    }
  }

  Future<void> _toggleChrome() async {
    final show = !_chromeVisible;
    if (mounted) setState(() => _chromeVisible = show);
    try {
      await SystemChrome.setEnabledSystemUIMode(
        show ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
      );
    } catch (error) {
      debugPrint('QuranProScreen: could not toggle system bars: $error');
    }
  }

  Future<void> _bookmarkSelectedAyah() async {
    final ayah = _selectedAyah;
    final text = _selectedAyahText;
    if (ayah == null || text == null || text.isEmpty) return;
    try {
      await BookmarkService.addBookmark(_currentSurah, ayah, text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ الآية $_surahName $ayah في العلامات المرجعية')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ العلامة المرجعية: $error')),
      );
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        _surahName,
        style: TextStyle(
          color: _goldColor,
          fontFamily: FontManager.isRaqqSuraFontLoaded ? 'RaqqSura' : 'Amiri',
        ),
      ),
      backgroundColor: const Color(0xFF1A237E),
      elevation: 0,
      actions: [
        IconButton(
          tooltip: _selectedAyah == null
              ? 'اختر آية أولًا لحفظها'
              : 'حفظ الآية المحددة في العلامات المرجعية',
          icon: const Icon(Icons.bookmark_add_outlined, color: _goldColor),
          onPressed: _selectedAyah == null ? null : _bookmarkSelectedAyah,
        ),
        IconButton(
          tooltip: _showFrame ? 'إخفاء إطار الآيات' : 'إظهار إطار الآيات',
          icon: Icon(_showFrame ? Icons.crop_square_rounded : Icons.crop_free_rounded,
              color: _goldColor),
          onPressed: _toggleFrame,
        ),
        IconButton(
          tooltip: _waveEnabled ? 'إيقاف حركة الكلمات' : 'تشغيل حركة الكلمات',
          icon: Icon(_waveEnabled ? Icons.waves_rounded : Icons.motion_photos_off_rounded,
              color: _goldColor),
          onPressed: _toggleWave,
        ),
        IconButton(
          tooltip: 'البحث في السورة الحالية',
          icon: const Icon(Icons.search_rounded, color: _goldColor),
          onPressed: _searchCurrentSurah,
        ),
        IconButton(
            tooltip: _autoScroll ? 'إيقاف التمرير التلقائي' : 'تشغيل التمرير التلقائي',
            icon: Icon(_autoScroll ? Icons.pause : Icons.play_arrow,
                color: _goldColor),
            onPressed: _toggleAutoScroll),
        PopupMenuButton<int>(
          icon: const Icon(Icons.list, color: _goldColor),
          onSelected: (value) {
            if (value == -1) {
              _shareSelectedAyah();
            } else {
              _loadSurah(value);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem<int>(
              value: -1,
              enabled: _selectedAyah != null,
              child: const Text('مشاركة الآية المحددة'),
            ),
            ..._surahs.map(
              (s) => PopupMenuItem<int>(
                value: s['n'] as int,
                child: Text(
                  '${s['name']} (${s['n']})',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: _bgColor.withOpacity(0.9),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _modeButton('عثماني', QuranDisplayMode.uthmaniGold, '🕌'),
            _modeButton('المسند', QuranDisplayMode.musnadAncient, '𐩱'),
            _modeButton('بلا نقاط + تشكيل', QuranDisplayMode.dotlessMarked, 'ٮِ'),
            _modeButton('بلا نقاط/تشكيل', QuranDisplayMode.dotless, 'ٮ'),
            _modeButton(
              FontManager.isRaqqFontLoaded ? 'رَقّ — كوفي مصحفي' : 'رَقّ — خط بديل',
              QuranDisplayMode.kufi,
              '│',
            ),
            _modeButton('هيلوغريفية', QuranDisplayMode.hieroglyphic, '𓂝'),
            const SizedBox(width: 16),
            // أزرار التحكم
            IconButton(
                tooltip: 'تصغير الخط',
                icon: const Icon(Icons.remove, color: _goldColor, size: 20),
                onPressed: () => _changeFontSize(-2)),
            Text('${_fontSize.toInt()}',
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            IconButton(
                tooltip: 'تكبير الخط',
                icon: const Icon(Icons.add, color: _goldColor, size: 20),
                onPressed: () => _changeFontSize(2)),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String label, QuranDisplayMode mode, String icon) {
    final active = _mode == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => _setDisplayMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? _goldColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active ? _goldColor : Colors.white24, width: active ? 1.5 : 0.5),
          ),
          child: Text('$icon $label',
              style: TextStyle(
                  color: active ? _goldColor : Colors.white54, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildVerseList() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _currentVerses.length,
      itemBuilder: (context, i) {
        final verse = _currentVerses[i];
        final text = verse['text'] ?? '';
        final musnadRows = _musnadQuran?[_currentSurah.toString()];
        final musnad = musnadRows != null && i < musnadRows.length
            ? musnadRows[i]['musnad'] as String?
            : null;
        final hieroglyphicRows = _hieroglyphicQuran?[_currentSurah.toString()];
        final hieroglyphic = hieroglyphicRows != null && i < hieroglyphicRows.length
            ? hieroglyphicRows[i]['hieroglyphic'] as String?
            : null;
        final transformed = _mode == QuranDisplayMode.musnadAncient
            ? (musnad ?? _transform(text))
            : _mode == QuranDisplayMode.hieroglyphic
                ? (hieroglyphic ?? _transform(text))
                : _transform(text);
        final verseNumber = i + 1;
        final isSelected = _selectedAyah == verseNumber;
        final verseKey = _verseKeys.putIfAbsent(i, GlobalKey.new);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAyah = verseNumber;
              _selectedAyahText = text.toString();
            });
            // Always send canonical source text to the local core, never a
            // transformed Musnad/dotless/Kufic presentation string.
            NucleusService().setQuranContext(
              surahNumber: _currentSurah,
              ayahNumber: verseNumber,
              verseText: text.toString(),
            );
          },
          onDoubleTap: () {
            setState(() {
              _selectedAyah = verseNumber;
              _selectedAyahText = text.toString();
            });
            NucleusService().setQuranContext(
              surahNumber: _currentSurah,
              ayahNumber: verseNumber,
              verseText: text.toString(),
            );
            unawaited(_toggleChrome());
          },
          onLongPress: () async {
            setState(() {
              _selectedAyah = verseNumber;
              _selectedAyahText = text.toString();
            });
            NucleusService().setQuranContext(
              surahNumber: _currentSurah,
              ayahNumber: verseNumber,
              verseText: text.toString(),
            );
            try {
              await Clipboard.setData(ClipboardData(text: text.toString()));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم نسخ الآية $verseNumber من سورة $_surahName'),
                ),
              );
            } catch (error) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تعذر نسخ الآية: $error')),
              );
            }
          },
          child: Container(
            key: verseKey,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? _goldColor.withOpacity(0.10)
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _goldColor.withOpacity(0.85) : _goldColor.withOpacity(0.1),
                width: isSelected ? 1.4 : 1,
              ),
              boxShadow: [
                if (_showFrame)
                  BoxShadow(
                    color: _goldColor.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                QuranWaveText(
                  text: transformed,
                  importanceText: text.toString(),
                  style: _textStyle(),
                  enabled: _waveEnabled,
                  textAlign: WrapAlignment.end,
                ),
                const SizedBox(height: 8),
                _buildVerseNumber(verseNumber),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerseNumber(int num) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('﴿$num﴾',
          style: const TextStyle(
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1A237E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navButton(Icons.skip_previous, () {
            if (_currentSurah > 1) _loadSurah(_currentSurah - 1);
          }),
          Text('${_currentVerses.length} آية',
              style: const TextStyle(color: _goldColor)),
          _navButton(Icons.skip_next, () {
            if (_currentSurah < 114) _loadSurah(_currentSurah + 1);
          }),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return IconButton(
        icon: Icon(icon, color: _goldColor, size: 28), onPressed: onTap);
  }
}
