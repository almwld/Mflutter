import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Device-local personal notes. Entries are records of the user's words, not
/// dream interpretations, predictions, or generated religious conclusions.
class DreamJournalService {
  static const String storageKey = 'mudabbir_cosmic_dream_journal_v1';
  static const int maxEntries = 200;
  static const int maxDreamLength = 5000;
  static const int maxEmotionLength = 500;
  static Future<void> _writeQueue = Future<void>.value();

  static Future<void> addDream(String dream, [String emotions = '']) {
    final text = dream.trim();
    final feeling = emotions.trim();
    if (text.isEmpty) {
      throw ArgumentError('لا يمكن حفظ مذكرة فارغة.');
    }
    if (text.length > maxDreamLength || feeling.length > maxEmotionLength) {
      throw ArgumentError('تجاوزت المذكرة أو وصف المشاعر الحد المسموح.');
    }
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final entries = await _readEntries();
      final now = DateTime.now();
      entries.insert(0, <String, dynamic>{
        'id': now.microsecondsSinceEpoch.toString(),
        'createdAt': now.toIso8601String(),
        'text': text,
        'emotions': feeling,
      });
      final bounded = entries.take(maxEntries).toList(growable: false);
      if (!await prefs.setString(storageKey, jsonEncode(bounded))) {
        throw StateError('تعذر حفظ مذكرة الحلم محليًا.');
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getDreams() async {
    await _writeQueue.catchError((Object _) {});
    return _readEntries();
  }

  static Future<List<Map<String, dynamic>>> _readEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      final entries = <Map<String, dynamic>>[];
      for (final item in decoded.whereType<Map>()) {
        final text = item['text'];
        final createdAt = item['createdAt'];
        if (text is! String ||
            text.trim().isEmpty ||
            text.length > maxDreamLength ||
            createdAt is! String ||
            DateTime.tryParse(createdAt) == null) {
          continue;
        }
        final emotions = item['emotions'];
        entries.add(<String, dynamic>{
          'id': item['id'] is String
              ? item['id']
              : DateTime.tryParse(createdAt)!.microsecondsSinceEpoch.toString(),
          'createdAt': createdAt,
          'text': text,
          'emotions': emotions is String
              ? emotions.substring(0, emotions.length.clamp(0, maxEmotionLength))
              : '',
        });
      }
      return entries.take(maxEntries).toList(growable: true);
    } on FormatException {
      return <Map<String, dynamic>>[];
    } on TypeError {
      return <Map<String, dynamic>>[];
    } on ArgumentError {
      return <Map<String, dynamic>>[];
    }
  }

  static Future<void> _enqueueWrite(Future<void> Function() operation) {
    _writeQueue = _writeQueue
        .catchError((Object _) {})
        .then((_) => operation());
    return _writeQueue;
  }
}
