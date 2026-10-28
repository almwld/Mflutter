import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimeCapsuleService {
  static const _key = 'mudabbir.time_capsules';

  static const int maxCapsules = 200;
  static const int maxContentLength = 10000;
  static Future<void> _writeQueue = Future<void>.value();

  static Future<void> sealCapsule(String content, DateTime unlockDate) {
    final normalized = content.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('لا يمكن حفظ كبسولة فارغة.');
    }
    if (normalized.length > maxContentLength) {
      throw ArgumentError('يتجاوز محتوى الكبسولة الحد الأقصى البالغ 10000 حرف.');
    }
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final capsules = _read(prefs);
      if (capsules.length >= maxCapsules) {
        throw StateError(
          'بلغت الكبسولات المحلية الحد الأقصى ($maxCapsules). احذف أو صدّر بعض الكبسولات أولًا.',
        );
      }
      final now = DateTime.now();
      capsules.add({
        'id': now.microsecondsSinceEpoch.toString(),
        'content': normalized,
        'unlockDate': unlockDate.toIso8601String(),
        'sealed': now.toIso8601String(),
      });
      if (!await prefs.setString(_key, jsonEncode(capsules))) {
        throw StateError('تعذر حفظ الكبسولة في التخزين المحلي.');
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getCapsules() async {
    await _writeQueue.catchError((Object _) {});
    final prefs = await SharedPreferences.getInstance();
    return _read(prefs);
  }

  static Future<void> _enqueueWrite(Future<void> Function() operation) {
    _writeQueue = _writeQueue
        .catchError((Object _) {})
        .then((_) => operation());
    return _writeQueue;
  }

  static Future<Map<String,dynamic>?> tryUnlock(int index) async {
    final capsules = await getCapsules();
    if (index < 0 || index >= capsules.length) return null;
    final capsule = capsules[index];
    final unlock = DateTime.tryParse(capsule['unlockDate'].toString());
    if (unlock == null || DateTime.now().isBefore(unlock)) return null;
    return capsule;
  }

  static List<Map<String, dynamic>> _read(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final capsules = <Map<String, dynamic>>[];
      for (final row in decoded) {
        if (row is! Map) continue;
        final content = row['content'];
        final unlockDate = row['unlockDate'];
        if (content is! String ||
            content.trim().isEmpty ||
            content.length > maxContentLength ||
            unlockDate is! String ||
            DateTime.tryParse(unlockDate) == null) {
          continue;
        }
        capsules.add(<String, dynamic>{
          'id': (row['id'] is String && (row['id'] as String).isNotEmpty)
              ? row['id']
              : DateTime.now().microsecondsSinceEpoch.toString(),
          'content': content,
          'unlockDate': unlockDate,
          'sealed': row['sealed'] is String ? row['sealed'] : '',
        });
      }
      return capsules.take(maxCapsules).toList(growable: true);
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    } on ArgumentError {
      return [];
    }
  }
}
