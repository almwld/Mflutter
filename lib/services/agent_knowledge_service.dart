import 'dart:convert';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

import '../domain/entities/verse.dart';
import 'quran_loader_service.dart';

/// Local, offline-first knowledge index backed by bundled application assets.
/// It never claims a source was searched unless it was actually loaded.
class AgentKnowledgeService {
  AgentKnowledgeService._();

  static final AgentKnowledgeService instance = AgentKnowledgeService._();
  static const _knowledgeAsset = 'assets/agent_knowledge.json';
  static const _generalAsset = 'assets/all_knowledge.json';
  static const _infoAsset = 'assets/data/info.json';
  static const _variantAssets = <String>[
    'assets/unified_quran.json',
    'assets/musnad_quran.json',
    'assets/hieroglyphic_quran.json',
  ];

  final List<AgentKnowledgeDocument> _documents = [];
  final Set<String> _loadedSources = {};
  Future<void>? _initializing;
  Future<void>? _loadingVariants;
  bool _variantsLoaded = false;

  bool get isReady => _loadedSources.contains(_knowledgeAsset);
  int get documentCount => _documents.length;
  List<String> get loadedSources => List.unmodifiable(_loadedSources);

  Future<void> initialize() async {
    final pending = _initializing;
    if (pending != null) {
      await pending;
      return;
    }

    final attempt = _initialize();
    _initializing = attempt;
    try {
      await attempt;
      if (!isReady) throw StateError('Knowledge asset unavailable: ' + _knowledgeAsset);
    } catch (error, stackTrace) {
      // Do not pin a failed Future forever or leave a half-built index behind.
      _documents.clear();
      _loadedSources.clear();
      _variantsLoaded = false;
      _initializing = null;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _initialize() async {
    final beforeRequiredKnowledge = _documents.length;
    await _loadJsonAsset(_knowledgeAsset);
    if (!isReady || _documents.length == beforeRequiredKnowledge) {
      throw StateError('Required knowledge asset contains no indexable documents: ' + _knowledgeAsset);
    }
    await _loadJsonAsset(_generalAsset);
    await _loadJsonAsset(_infoAsset);

    // Validate the canonical corpus before it becomes evidence for agents.
    final ayahs = await QuranLoaderService.loadAllAyahs();
    for (final Ayah ayah in ayahs) {
      _documents.add(AgentKnowledgeDocument(
        source: 'assets/quran_full.json',
        title: '${ayah.surahName} ${ayah.surahNumber}:${ayah.ayahNumber}',
        content: ayah.text,
        tags: const ['قرآن', 'حفص', 'آية'],
      ));
    }
    _loadedSources.add('assets/quran_full.json');
  }

  Future<void> _loadJsonAsset(String path) async {
    final before = _documents.length;
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      _collect(decoded, path, path, 0);
      _loadedSources.add(path);
    } on FlutterError {
      // Optional assets do not prevent the canonical corpus from loading.
      _rollbackDocuments(before);
    } on FormatException {
      // Do not fabricate replacement data for malformed assets.
      _rollbackDocuments(before);
    } on TypeError {
      // A malformed optional schema must not leave a partially indexed source.
      _rollbackDocuments(before);
    } on ArgumentError {
      _rollbackDocuments(before);
    }
  }

  void _rollbackDocuments(int lengthBeforeLoad) {
    if (_documents.length > lengthBeforeLoad) {
      _documents.removeRange(lengthBeforeLoad, _documents.length);
    }
  }

  void _collect(dynamic value, String source, String path, int depth) {
    if (depth > 14 || value == null) return;
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        _collect(value[i], source, '$path[$i]', depth + 1);
      }
      return;
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(
        value.map((key, value) => MapEntry(key.toString(), value)),
      );
      final title = _firstText(map, const [
        'title', 'name', 'heading', 'surah_name', 'surahName', 'label',
      ]);
      final text = _firstText(map, const [
        'content', 'description', 'summary', 'body', 'text', 'ayah',
        'meaning', 'definition', 'info', 'value', 'role', 'rule', 'purpose',
      ]);
      if (text != null && text.trim().length >= 12) {
        _documents.add(AgentKnowledgeDocument(
          source: source,
          title: title ?? path,
          content: text.trim(),
          tags: _stringList(map['tags']),
        ));
      }
      for (final entry in map.entries) {
        final child = entry.value;
        if (child is Map || child is List) {
          _collect(child, source, '$path.${entry.key}', depth + 1);
        }
      }
      return;
    }
    if (value is String && value.trim().length >= 40) {
      _documents.add(AgentKnowledgeDocument(
        source: source,
        title: path,
        content: value.trim(),
        tags: const [],
      ));
    }
  }

  String? _firstText(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }

  Future<void> _loadVariantsIfNeeded() async {
    if (_variantsLoaded) return;
    final pending = _loadingVariants;
    if (pending != null) {
      await pending;
      return;
    }
    final attempt = _loadVariantAssets();
    _loadingVariants = attempt;
    try {
      await attempt;
      _variantsLoaded = true;
    } finally {
      if (identical(_loadingVariants, attempt)) _loadingVariants = null;
    }
  }

  Future<void> _loadVariantAssets() async {
    for (final path in _variantAssets) {
      await _loadJsonAsset(path);
    }
  }

  Future<List<AgentKnowledgeDocument>> search(
    String query, {
    int limit = 6,
    bool includeScriptVariants = false,
  }) async {
    await initialize();
    if (includeScriptVariants) await _loadVariantsIfNeeded();

    final normalizedQuery = normalize(query);
    final terms = normalizedQuery.split(' ').where((term) => term.length >= 2).toSet();
    if (terms.isEmpty) return const [];

    final ranked = <({AgentKnowledgeDocument document, int score})>[];
    for (final document in _documents) {
      final title = normalize(document.title);
      final haystack = normalize('${document.title} ${document.content} ${document.tags.join(' ')}');
      var score = 0;
      for (final term in terms) {
        if (haystack.contains(term)) score += 2;
        if (title.contains(term)) score += 2;
      }
      if (haystack.contains(normalizedQuery)) score += 5;
      if (score > 0) ranked.add((document: document, score: score));
    }
    ranked.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final bySource = a.document.source.compareTo(b.document.source);
      if (bySource != 0) return bySource;
      final byTitle = a.document.title.compareTo(b.document.title);
      if (byTitle != 0) return byTitle;
      return a.document.content.compareTo(b.document.content);
    });
    final seen = <String>{};
    return ranked
        .where((item) => seen.add('${item.document.source}|${item.document.title}|${item.document.content}'))
        .take(limit)
        .map((item) => item.document)
        .toList(growable: false);
  }

  static String normalize(String value) => value
      .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll(RegExp(r'[ؤئ]'), 'ء')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[^\u0600-\u06FFa-zA-Z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
}

class AgentKnowledgeDocument {
  final String source;
  final String title;
  final String content;
  final List<String> tags;

  const AgentKnowledgeDocument({
    required this.source,
    required this.title,
    required this.content,
    required this.tags,
  });
}
