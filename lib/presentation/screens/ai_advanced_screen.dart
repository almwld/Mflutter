import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/local_embeddings_service.dart';
import '../../services/tafsir_generator_service.dart';
import '../../services/quranic_search_engine.dart';
import '../../services/quran_loader_service.dart';
import '../../services/mushaf_source.dart';
import 'quran/mushaf_screen.dart';

class AIAdvancedScreen extends StatefulWidget {
  const AIAdvancedScreen({super.key});

  @override
  State<AIAdvancedScreen> createState() => _AIAdvancedScreenState();
}

class _AIAdvancedScreenState extends State<AIAdvancedScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocalSearchResult> _searchResults = const <LocalSearchResult>[];
  bool _indexing = true;
  String? _indexError;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _loadQuranIndex();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuranIndex() async {
    if (mounted) {
      setState(() {
        _indexing = true;
        _indexError = null;
      });
    }
    try {
      final ayahs = await QuranLoaderService.loadAllAyahs();
      if (!mounted) return;
      if (ayahs.isEmpty) {
        setState(() {
          _indexing = false;
          _indexError = 'مصدر القرآن المحلي لم يُرجع أي آية؛ لا يمكن تجهيز فهرس البحث.';
        });
        return;
      }

      final searchDocs = ayahs
          .map((ayah) => <String, String>{
                'text': ayah.text,
                'surah': ayah.surahName,
                'ayah': ayah.ayahNumber.toString(),
              })
          .toList(growable: false);
      QuranicSearchEngine.indexVerses(searchDocs);

      LocalEmbeddingsService.indexAll({
        for (final ayah in ayahs)
          '${ayah.surahNumber}:${ayah.ayahNumber}': ayah.text,
      });
      setState(() => _indexing = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _indexing = false;
        _indexError = 'تعذر تجهيز فهرس القرآن المحلي: $error';
      });
    }
  }

  void _openResult(LocalSearchResult result) {
    final parts = result.id.split(':');
    if (parts.length != 2) {
      setState(() => _searchError = 'تعذر فتح النتيجة: مرجع الآية غير صالح.');
      return;
    }
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    if (surah == null || ayah == null || surah < 1 || surah > 114 || ayah < 1) {
      setState(() => _searchError = 'تعذر فتح النتيجة: مرجع الآية غير صالح.');
      return;
    }
    final page = MushafSource.pageForVerse(surah, ayah);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MushafScreen(
          initialPage: page,
          initialSurah: surah,
          initialAyah: ayah,
          restoreLastPage: false,
        ),
      ),
    );
  }

  void _search() {
    if (_indexing) return;
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = const <LocalSearchResult>[];
        _searchError = 'اكتب كلمة أو عبارة للبحث.';
      });
      return;
    }
    if (!LocalEmbeddingsService.isIndexed) {
      setState(() {
        _searchResults = const <LocalSearchResult>[];
        _searchError = 'الفهرس المحلي غير متاح. أعد تحميل الفهرس.';
      });
      return;
    }
    setState(() {
      _searchError = null;
      _searchResults = LocalEmbeddingsService.searchRanked(query, topK: 8);
      if (_searchResults.isEmpty) {
        _searchError = 'لم تُعثر على مطابقات نصية محلية لهذه العبارة.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'الذكاء المحلي المتقدم',
          style: TextStyle(color: AppColors.primaryGold),
        ),
        backgroundColor: AppColors.primaryNavy,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'بحث نصي محلي',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'يعتمد البحث على مطابقة الكلمات وترجيح TF-IDF داخل فهرس القرآن المحفوظ على الجهاز. هذه آلية استرجاع نصي وليست نموذج فهم دلالي أو استدلالاً لغوياً.',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'ابحث بكلمة أو عبارة من القرآن...',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _indexing ? null : _search,
                      icon: _indexing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search_rounded),
                      label: Text(_indexing ? 'جارٍ تجهيز الفهرس...' : 'بحث محلي'),
                    ),
                  ),
                  if (_indexError != null) ...[
                    _MessagePanel(message: _indexError!, isError: true),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _indexing ? null : _loadQuranIndex,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة تحميل فهرس القرآن'),
                      ),
                    ),
                  ],
                  if (_searchError != null)
                    _MessagePanel(message: _searchError!, isError: false),
                  if (!_indexing && _indexError == null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'الفهرس المحلي: ${LocalEmbeddingsService.documentCount} نصاً',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ..._searchResults.map(
                    (result) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        result.text,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(color: Colors.white70, height: 1.6),
                      ),
                      subtitle: Text(
                        'المرجع: ${result.id} • درجة تشابه نصي نسبية: ${result.score.toStringAsFixed(3)}',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(color: AppColors.primaryGold, fontSize: 12),
                      ),
                      onTap: () => _openResult(result),
                      trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.primaryGold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'ملخصات تعليمية محلية محدودة',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'هذه ملخصات موجزة ثابتة لآيات محددة، وليست نصوصًا منقولة عن كتاب تفسير موثق ولا تفسيرًا مولّدًا بالذكاء الاصطناعي. راجع كتب التفسير المعتمدة للتحقق والتوسع.',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white54, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  _TafsirNote(surah: 'الفاتحة', ayah: 1),
                  _TafsirNote(surah: 'البقرة', ayah: 255),
                  _TafsirNote(surah: 'الإخلاص', ayah: 1),
                ],
              ),
            ),
          ),
          Card(
            color: AppColors.surface,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'التدريب المحلي',
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'الضبط الدقيق متوقف حتى توفير مجموعة بيانات موسومة ومحرك تدريب حقيقي متوافق. لا يتم احتساب تدريب أو خسارة وهمية.',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white54, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TafsirNote extends StatelessWidget {
  const _TafsirNote({required this.surah, required this.ayah});

  final String surah;
  final int ayah;

  @override
  Widget build(BuildContext context) {
    String note;
    try {
      note = TafsirGeneratorService.generate(surah, ayah);
    } catch (_) {
      note = 'لا توجد ملاحظة محلية لهذه الآية.';
    }
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        '$surah:$ayah',
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: AppColors.primaryGold),
      ),
      subtitle: Text(
        note,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white70, height: 1.5),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          message,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: isError ? Colors.redAccent : Colors.white70,
            height: 1.5,
          ),
        ),
      );
}
