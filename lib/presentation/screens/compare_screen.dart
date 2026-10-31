import 'package:flutter/material.dart';

import '../../core/themes/mudabbir_design_tokens.dart';
import '../../domain/entities/verse.dart';
import '../../services/quran_loader_service.dart';
import '../templates/mudabbir_templates.dart';

/// Compares references against the canonical local Quran corpus.
/// Source verse text remains unchanged; normalization is only for lexical overlap.
class CompareScreen extends StatefulWidget {
  final String? agentQuery;

  const CompareScreen({super.key, this.agentQuery});
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _firstController = TextEditingController(text: '1:1');
  final _secondController = TextEditingController(text: '1:2');
  List<Ayah> _ayahs = const [];
  Ayah? _first;
  Ayah? _second;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCorpus();
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  Future<void> _loadCorpus() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      if (!mounted) return;
      if (ayahs.isEmpty) {
        setState(() {
          _ayahs = const [];
          _loading = false;
          _error = 'مصدر القرآن المحلي لم يُرجع أي آية قابلة للمقارنة.';
        });
        return;
      }
      setState(() {
        _ayahs = ayahs;
        _loading = false;
        _error = null;
      });
      _compare();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل مصدر القرآن المحلي: $error';
      });
    }
  }

  String _asciiDigits(String value) => value.replaceAllMapped(
        RegExp(r'[٠-٩۰-۹]'),
        (match) {
          final code = match.group(0)!.codeUnitAt(0);
          final digit = code >= 0x06F0 ? code - 0x06F0 : code - 0x0660;
          return String.fromCharCode(0x30 + digit);
        },
      );

  Ayah? _findReference(String raw) {
    final match = RegExp(r'^\s*(\d{1,3})\s*[:/]\s*(\d{1,3})\s*$')
        .firstMatch(_asciiDigits(raw));
    if (match == null) return null;
    final surah = int.tryParse(match.group(1)!);
    final number = int.tryParse(match.group(2)!);
    if (surah == null || number == null) return null;
    for (final ayah in _ayahs) {
      if (ayah.surahNumber == surah && ayah.ayahNumber == number) return ayah;
    }
    return null;
  }

  String _normalize(String value) => value
      .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll(RegExp(r'[ؤئ]'), 'ء')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[^\u0621-\u064A\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  void _compare() {
    if (_loading || _ayahs.isEmpty) return;
    final first = _findReference(_firstController.text);
    final second = _findReference(_secondController.text);
    setState(() {
      _first = first;
      _second = second;
      _error = first == null || second == null
          ? 'أدخل مرجعين صحيحين بصيغة رقم السورة:رقم الآية، مثل 1:1 أو ٢:٢.'
          : null;
    });
  }

  Set<String> _words(Ayah? ayah) => ayah == null
      ? <String>{}
      : _normalize(ayah.text).split(' ').where((word) => word.isNotEmpty).toSet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final firstWords = _words(_first);
    final secondWords = _words(_second);
    final shared = firstWords.intersection(secondWords).toList()..sort();
    final onlyFirst = firstWords.difference(secondWords).toList()..sort();
    final onlySecond = secondWords.difference(firstWords).toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('مقارنة الآيات')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _ayahs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _message(_error!, isError: true),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _loadCorpus,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('إعادة تحميل مصدر القرآن'),
                        ),
                      ],
                    ),
                  ),
                )
              : ComparisonTemplate(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.agentQuery?.trim().isNotEmpty == true) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            'طلب الوكيل: ${widget.agentQuery}',
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('اختر موضعي المقارنة',
                                textDirection: TextDirection.rtl,
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              'تُجلب الآيات من المصحف المحلي. اكتب رقم السورة ثم رقم الآية، وافصل بينهما بنقطتين.',
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            _referenceField(_firstController, 'المرجع الأول'),
                            const SizedBox(height: 10),
                            _referenceField(_secondController, 'المرجع الثاني'),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: _compare,
                              icon: const Icon(Icons.compare_arrows_rounded),
                              label: const Text('مقارنة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      _message(_error!, isError: true),
                    ],
                    if (_first != null && _second != null) ...[
                      const SizedBox(height: 14),
                      _verseCard(_first!),
                      const SizedBox(height: 10),
                      _verseCard(_second!),
                      const SizedBox(height: 14),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('التقاطع اللفظي بعد التطبيع',
                                  textDirection: TextDirection.rtl,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  )),
                              const SizedBox(height: 6),
                              Text(
                                'المصدر: نص الآيات المحلية. تُزال التشكيلات وتُوحّد بعض صور الحروف لأغراض المقارنة فقط؛ لا يُعد هذا تفسيرًا أو استنتاجًا دينيًا.',
                                textDirection: TextDirection.rtl,
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              _wordGroup('كلمات مشتركة (' + shared.length.toString() + ')', shared),
                              _wordGroup('كلمات في الأولى فقط (' + onlyFirst.length.toString() + ')', onlyFirst),
                              _wordGroup('كلمات في الثانية فقط (' + onlySecond.length.toString() + ')', onlySecond),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _referenceField(TextEditingController controller, String label) => TextField(
        controller: controller,
        textDirection: TextDirection.ltr,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _compare(),
        decoration: InputDecoration(
          labelText: label,
          hintText: '1:1',
          border: const OutlineInputBorder(),
        ),
      );

  Widget _verseCard(Ayah ayah) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ayah.surahName + ' • ' + ayah.surahNumber.toString() + ':' + ayah.ayahNumber.toString(),
              textDirection: TextDirection.rtl,
              style: theme.textTheme.titleSmall?.copyWith(
                color: MudabbirDesignTokens.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SelectableText(
              ayah.text,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(height: 2.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wordGroup(String title, List<String> words) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, textDirection: TextDirection.rtl, style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          if (words.isEmpty)
            Text('لا توجد', textDirection: TextDirection.rtl, style: theme.textTheme.bodySmall)
          else
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: words.map((word) => Chip(label: Text(word, textDirection: TextDirection.rtl))).toList(growable: false),
            ),
        ],
      ),
    );
  }

  Widget _message(String text, {required bool isError}) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(color: isError ? Theme.of(context).colorScheme.error : null),
          ),
        ),
      );
}
