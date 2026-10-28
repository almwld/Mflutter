import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/abjad_extended_service.dart';
import '../../data/occult_data_service.dart';
import '../../models/occult_models.dart';
import '../../services/audio_synthesis_service.dart';

class OccultExplorerScreen extends StatefulWidget {
  const OccultExplorerScreen({super.key});
  @override
  State<OccultExplorerScreen> createState() => _OccultExplorerScreenState();
}

class _OccultExplorerScreenState extends State<OccultExplorerScreen> {
  final _abjad = TextEditingController();
  final _search = TextEditingController();
  late Future<List<OccultEntry>> _entries;
  String _category = 'all';
  String _query = '';
  int? _result;
  bool _busy = false;

  static const _labels = <String, String>{
    'all': 'الكل', 'tarot': 'التاروت', 'runes': 'الرونية',
    'crystals': 'الأحجار والمعادن', 'hermeticism': 'الهرمسية', 'general': 'عام',
  };

  @override
  void initState() {
    super.initState();
    _entries = OccultDataService.fetchAllEntries();
  }

  void _retryLoadEntries() {
    setState(() => _entries = OccultDataService.fetchAllEntries());
  }

  @override
  void dispose() {
    _abjad.dispose();
    _search.dispose();
    unawaited(AudioSynthesisService.stop());
    super.dispose();
  }

  void _calculate() => setState(() => _result = AbjadExtendedService.calculate(_abjad.text));

  Future<void> _play(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('بدأ تشغيل الصوت. استخدم مستوى صوت منخفضًا وأوقفه إذا سبب انزعاجًا.')),
        );
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر تشغيل الصوت: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('مستكشف المعرفة والرموز'),
        actions: [
          IconButton(
            tooltip: 'إيقاف الصوت',
            onPressed: () async { await AudioSynthesisService.stop(); if (mounted) setState(() {}); },
            icon: const Icon(Icons.stop_circle_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'هذه المواد تعرض تاريخ الرموز والمعتقدات الثقافية، وليست حقائق علمية أو تنبؤات موثوقة. حساب الجُمّل عملية حسابية للحروف ولا يثبت صفات الأشخاص أو نتائج المستقبل.',
                textDirection: TextDirection.rtl,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withOpacity(.72),
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _heading(context, 'حاسبة الجُمّل', Icons.calculate_outlined),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextField(
                  controller: _abjad,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'اكتب كلمة أو عبارة عربية',
                    prefixIcon: Icon(Icons.text_fields_rounded),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _calculate(),
                  onSubmitted: (_) => _calculate(),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.functions),
                    label: const Text('احسب الجمل الكبير'),
                  )),
                  if (_result != null) ...[
                    const SizedBox(width: 12),
                    Text('$_result', style: theme.textTheme.headlineSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.bold)),
                  ],
                ]),
                if (_abjad.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 5, runSpacing: 5, children: AbjadExtendedService.analyzeLetters(_abjad.text)
                      .map((e) => Chip(label: Text('${e.key} = ${e.value}'), visualDensity: VisualDensity.compact)).toList()),
                  Text(
                    'حساب أبجدي تقليدي بعد إزالة التشكيل وتوحيد بعض الحروف؛ لا يثبت صفات أو تنبؤات عن الأشخاص.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.65)),
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 20),
          _heading(context, 'الصوت التجريبي', Icons.graphic_eq_rounded),
          const SizedBox(height: 8),
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('نغمات ستيريو مولّدة محليًا', style: theme.textTheme.titleMedium),
              const SizedBox(height: 5),
              Text('الصوت تجريبي وليس علاجًا مثبتًا. استخدم مستوى منخفضًا، ولا تستمع إليه أثناء القيادة.',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.65))),
              const SizedBox(height: 10),
              Wrap(spacing: 7, runSpacing: 7, children: [
                _soundButton('هدوء · 7.83 Hz', () => _play(AudioSynthesisService.playTranquility)),
                _soundButton('تركيز · 14 Hz', () => _play(AudioSynthesisService.playFocus)),
                _soundButton('تأمل · 4 Hz', () => _play(AudioSynthesisService.playDeepMeditation)),
                OutlinedButton.icon(
                  onPressed: _busy ? null : () async { await AudioSynthesisService.stop(); if (mounted) setState(() {}); },
                  icon: const Icon(Icons.stop_rounded), label: const Text('إيقاف'),
                ),
              ]),
              if (_busy) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
            ]),
          )),
          const SizedBox(height: 20),
          _heading(context, 'المعرفة المحلية', Icons.auto_stories_rounded),
          const SizedBox(height: 8),
          TextField(
            controller: _search,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              hintText: 'ابحث في الاسم والوصف...',
              prefixIcon: Icon(Icons.search_rounded),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<OccultEntry>>(
            future: _entries,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'تعذر تحميل البيانات المحلية.',
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: OutlinedButton.icon(
                            onPressed: _retryLoadEntries,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final all = snapshot.data ?? const <OccultEntry>[];
              final categories = <String>{'all', ...all.map((e) => e.category)}.toList();
              final filtered = all.where((entry) {
                final categoryMatch = _category == 'all' || entry.category == _category;
                final queryMatch = _query.isEmpty || entry.name.toLowerCase().contains(_query) || entry.description.toLowerCase().contains(_query);
                return categoryMatch && queryMatch;
              }).toList();
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: categories.map((category) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 7),
                    child: ChoiceChip(
                      label: Text(_labels[category] ?? category),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  )).toList()),
                ),
                const SizedBox(height: 8),
                if (filtered.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('لا توجد عناصر مطابقة للبحث.')))
                else
                  ...filtered.map((entry) => Card(
                    margin: const EdgeInsets.only(bottom: 9),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colors.primaryContainer,
                        foregroundColor: colors.onPrimaryContainer,
                        child: Icon(_categoryIcon(entry.category)),
                      ),
                      title: Text(entry.name, textDirection: TextDirection.rtl),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(entry.description, maxLines: 3, overflow: TextOverflow.ellipsis, textDirection: TextDirection.rtl),
                      ),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      onTap: () => _showDetails(entry),
                    ),
                  )),
                const SizedBox(height: 8),
                Text(
                  'تُقرأ assets/all_knowledge.json محليًا عند توفر سجلات منظمة. لم تُنزّل قواعد بيانات خارجية تلقائيًا في هذا الإصدار.',
                  style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.58)),
                  textDirection: TextDirection.rtl,
                ),
              ]);
            },
          ),
        ],
      ),
    );
  }

  Widget _heading(BuildContext context, String title, IconData icon) => Row(children: [
    Icon(icon, color: Theme.of(context).colorScheme.primary),
    const SizedBox(width: 8),
    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
  ]);

  Widget _soundButton(String label, VoidCallback onPressed) => FilledButton.tonal(
    onPressed: _busy ? null : onPressed,
    child: Text(label),
  );

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'tarot': return Icons.style_outlined;
      case 'runes': return Icons.gesture_rounded;
      case 'crystals': return Icons.diamond_outlined;
      case 'hermeticism': return Icons.menu_book_outlined;
      default: return Icons.auto_awesome_outlined;
    }
  }

  void _showDetails(OccultEntry entry) {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(entry.name, textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Align(alignment: AlignmentDirectional.centerStart, child: Chip(label: Text(_labels[entry.category] ?? entry.category))),
            Text(entry.description, textDirection: TextDirection.rtl, style: Theme.of(context).textTheme.bodyLarge),
            if (entry.abjadValue != null) ...[
              const SizedBox(height: 12),
              Text('قيمة الجمل: ${entry.abjadValue}', style: Theme.of(context).textTheme.titleMedium),
            ],
            if (entry.properties.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('الخصائص', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              ...entry.properties.entries.map((property) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(property.key, textDirection: TextDirection.rtl),
                trailing: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: Text(property.value.toString(), textAlign: TextAlign.end),
                ),
              )),
            ],
            if (entry.source != null) ...[
              const SizedBox(height: 12),
              Text('المصدر: ${entry.source}', textDirection: TextDirection.rtl,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurface.withOpacity(.65))),
            ],
          ]),
        ),
      ),
    );
  }
}