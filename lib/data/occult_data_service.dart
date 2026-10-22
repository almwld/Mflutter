import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/occult_models.dart';

/// Local-first knowledge loader. No network access is required at runtime.
/// Entries bundled below are clearly marked as starter/reference summaries;
/// an optional JSON asset can add structured records without changing the UI.
class OccultDataService {
  OccultDataService._();

  static const String assetPath = 'assets/all_knowledge.json';

  static const List<OccultEntry> _starterEntries = <OccultEntry>[
    OccultEntry(
      id: 'tarot-fool',
      name: 'المهرج — The Fool',
      category: 'tarot',
      description: 'مدخل تعريفي لرمز البداية والتجربة الجديدة في بعض مدارس التاروت.',
      properties: <String, dynamic>{'number': 0, 'element': 'يختلف حسب المدرسة'},
      source: 'Starter reference — not a prediction',
    ),
    OccultEntry(
      id: 'rune-fehu',
      name: 'فيهو — Fehu',
      category: 'runes',
      description: 'رمز من الأبجدية الرونية ارتبط تاريخياً بالماشية والثروة في المصادر الجرمانية القديمة.',
      properties: <String, dynamic>{'system': 'Elder Futhark'},
      source: 'Historical / cultural reference',
    ),
    OccultEntry(
      id: 'crystal-amethyst',
      name: 'الجمشت — Amethyst',
      category: 'crystals',
      description: 'نوع من الكوارتز البنفسجي؛ أما الادعاءات العلاجية أو الروحية المنسوبة إليه فليست حقائق علمية مثبتة.',
      properties: <String, dynamic>{'mineral': 'Quartz', 'Mohs hardness': 7},
      source: 'Mineralogical reference',
    ),
    OccultEntry(
      id: 'emerald-tablet',
      name: 'لوح الزمرد — Emerald Tablet',
      category: 'hermeticism',
      description: 'نص قصير مشهور في تاريخ الهرمسية والخيمياء، وصل عبر تقاليد مخطوطية متعددة.',
      properties: <String, dynamic>{'field': 'History of esotericism'},
      source: 'Historical text reference',
    ),
  ];

  static Future<List<OccultEntry>> fetchAllEntries() async {
    final byId = <String, OccultEntry>{
      for (final entry in _starterEntries) entry.id: entry,
    };

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      final records = _extractRecords(decoded);
      for (var i = 0; i < records.length; i++) {
        final entry = OccultEntry.fromJson(records[i]);
        if (entry.name.trim().isEmpty || entry.description.trim().isEmpty) {
          continue;
        }
        final id = entry.id.trim().isEmpty
            ? 'asset-entry-$i'
            : entry.id.trim();
        byId[id] = OccultEntry(
          id: id,
          name: entry.name,
          category: entry.category,
          description: entry.description,
          properties: entry.properties,
          abjadValue: entry.abjadValue,
          source: entry.source ?? 'assets/all_knowledge.json',
        );
      }
    } catch (_) {
      // A missing or malformed optional asset must not block offline use.
      return _starterEntries;
    }

    final result = byId.values.toList()
      ..sort((a, b) => a.category.compareTo(b.category));
    return result;
  }

  static List<Map<String, dynamic>> _extractRecords(dynamic decoded) {
    if (decoded is List) {
      return decoded.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
    if (decoded is Map) {
      for (final key in const ['entries', 'items', 'records', 'knowledge', 'data']) {
        final value = decoded[key];
        if (value is List) {
          return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
        }
      }
      // Treat a single record as a one-item collection.
      if (decoded.containsKey('name') || decoded.containsKey('title')) {
        return <Map<String, dynamic>>[Map<String, dynamic>.from(decoded)];
      }
    }
    return const <Map<String, dynamic>>[];
  }

  static Future<List<OccultEntry>> fetchByCategory(String category) async {
    final all = await fetchAllEntries();
    if (category == 'all') return all;
    return all.where((entry) => entry.category == category).toList();
  }
}