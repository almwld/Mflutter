import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'achievements_service.dart';

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
      await AchievementsService.recordDreamSaved();
    });
  }

  static Future<void> removeDream(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('معرّف المذكرة غير صالح.');
    }
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final entries = await _readEntries();
      final updated = entries
          .where((entry) => entry['id'] != normalizedId)
          .toList(growable: false);
      if (updated.length == entries.length) return;
      if (!await prefs.setString(storageKey, jsonEncode(updated))) {
        throw StateError('تعذر حذف المذكرة من التخزين المحلي.');
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
      if (decoded is! List) {
        throw StateError('بنية سجل الأحلام ليست قائمة صالحة؛ لم تُستبدل البيانات الموجودة.');
      }
      final entries = <Map<String, dynamic>>[];
      for (final item in decoded) {
        if (item is! Map) {
          throw StateError('يحتوي سجل الأحلام على سجل غير صالح؛ أُوقف الحفظ لحماية البيانات.');
        }
        final text = item['text'];
        final createdAt = item['createdAt'];
        if (text is! String ||
            text.trim().isEmpty ||
            text.length > maxDreamLength ||
            createdAt is! String ||
            DateTime.tryParse(createdAt) == null) {
          throw StateError('يحتوي سجل الأحلام على حقول غير صالحة؛ أُوقف الحفظ لحماية البيانات.');
        }
        final emotions = item['emotions'];
        entries.add(<String, dynamic>{
          'id': item['id'] is String
              ? item['id']
              : DateTime.tryParse(createdAt)!.microsecondsSinceEpoch.toString(),
          'createdAt': createdAt,
          'text': text,
          'emotions': emotions is String
              ? emotions.substring(0, emotions.length.clamp(0, maxEmotionLength).toInt())
              : '',
        });
      }
      return entries.take(maxEntries).toList(growable: true);
    } on FormatException catch (error) {
      // Fail closed: an unreadable journal must not be treated as empty,
      // because the next add operation could erase recoverable entries.
      throw StateError('تعذر قراءة سجل الأحلام؛ لم تُستبدل البيانات الموجودة. التفاصيل: $error');
    } on TypeError catch (error) {
      throw StateError('بنية سجل الأحلام غير صالحة؛ لم تُستبدل البيانات الموجودة. التفاصيل: $error');
    } on ArgumentError catch (error) {
      throw StateError('تعذر تفسير سجل الأحلام؛ لم تُستبدل البيانات الموجودة. التفاصيل: $error');
    }
  }

  static Future<void> _enqueueWrite(Future<void> Function() operation) {
    _writeQueue = _writeQueue
        .catchError((Object _) {})
        .then((_) => operation());
    return _writeQueue;
  }
}
