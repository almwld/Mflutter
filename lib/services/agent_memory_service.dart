import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Small persistent, on-device memory/vault for agent runs and Obsidian-style
/// notes. Data stays in app preferences; nothing is uploaded.
class AgentMemoryService {
  AgentMemoryService._();

  static final AgentMemoryService instance = AgentMemoryService._();
  static const _historyKey = 'mudabbir_super_agent_history_v1';
  static const _vaultKey = 'mudabbir_super_agent_vault_v1';

  Future<List<Map<String, dynamic>>> recentRuns({int limit = 8}) async {
    if (limit <= 0) return const <Map<String, dynamic>>[];
    final prefs = await SharedPreferences.getInstance();
    final rows = _decodeRows(prefs.getString(_historyKey));
    return rows.reversed.take(limit).toList(growable: false);
  }

  Future<void> saveRun({
    required String query,
    required String answer,
    required List<String> sources,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = _decodeRows(prefs.getString(_historyKey));
    rows.add({
      'query': query.length > 500 ? '${query.substring(0, 500)}…' : query,
      'answer': answer.length > 6000 ? '${answer.substring(0, 6000)}…' : answer,
      'sources': sources,
      'savedAt': DateTime.now().toIso8601String(),
    });
    final bounded = rows.length > 20 ? rows.sublist(rows.length - 20) : rows;
    if (!await prefs.setString(_historyKey, jsonEncode(bounded))) {
      throw StateError('تعذر حفظ سجل تشغيل الوكلاء محليًا.');
    }
  }

  Future<Map<String, dynamic>> saveVaultNote({
    required String title,
    required String content,
    required List<String> sources,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = _decodeRows(prefs.getString(_vaultKey));
    final note = <String, dynamic>{
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'title': title,
      'content': content.length > 12000 ? '${content.substring(0, 12000)}…' : content,
      'sources': sources,
      'createdAt': DateTime.now().toIso8601String(),
    };
    rows.add(note);
    final bounded = rows.length > 50 ? rows.sublist(rows.length - 50) : rows;
    if (!await prefs.setString(_vaultKey, jsonEncode(bounded))) {
      throw StateError('تعذر حفظ الملاحظة في دفتر المعرفة المحلي.');
    }

    // Read back from persistent storage to verify that the note was saved.
    final readBack = _decodeRows(prefs.getString(_vaultKey));
    final saved = readBack.any((row) => row['id'] == note['id']);
    if (!saved) throw StateError('تعذر التحقق من حفظ الملاحظة في دفتر المعرفة.');
    return {'saved': true, 'readBack': true, 'note': note};
  }

  Future<List<Map<String, dynamic>>> searchVault(String query, {int limit = 8}) async {
    if (limit <= 0) return const [];
    final needle = _normalize(query);
    if (needle.isEmpty) return const [];

    final prefs = await SharedPreferences.getInstance();
    final rows = _decodeRows(prefs.getString(_vaultKey));
    final terms = needle.split(' ').where((term) => term.isNotEmpty).toSet();
    if (terms.isEmpty) return const [];

    // Rank relevant notes instead of returning a recent note merely because
    // it shares one common word with the query. Phrase and title matches are
    // stronger signals than partial body-term overlap.
    final ranked = <({Map<String, dynamic> row, int score, String date})>[];
    for (final row in rows) {
      final title = _normalize((row['title'] ?? '').toString());
      final content = _normalize((row['content'] ?? '').toString());
      final combined = '$title $content';
      final matchedTerms = terms.where(combined.contains).length;
      if (matchedTerms == 0) continue;

      var score = matchedTerms * 10;
      if (title.contains(needle)) score += 100;
      if (content.contains(needle)) score += 50;
      for (final term in terms) {
        if (title.contains(term)) score += 8;
      }
      // Prefer notes that cover the complete query over notes that match only
      // a small fraction of its words.
      if (matchedTerms == terms.length) score += 20;

      ranked.add((
        row: row,
        score: score,
        date: (row['createdAt'] ?? '').toString(),
      ));
    }

    ranked.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : b.date.compareTo(a.date);
    });
    return ranked.take(limit).map((entry) => entry.row).toList(growable: false);
  }

  List<Map<String, dynamic>> _decodeRows(String? raw) {
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded.whereType<Map>().map(
        (row) => Map<String, dynamic>.from(row),
      ).toList();
    } on FormatException {
      return <Map<String, dynamic>>[];
    } on TypeError {
      return <Map<String, dynamic>>[];
    } on ArgumentError {
      return <Map<String, dynamic>>[];
    }
  }

  String _normalize(String value) => value
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
}
