import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'achievements_service.dart';

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
    if (!unlockDate.isAfter(DateTime.now())) {
      throw ArgumentError('يجب أن يكون موعد فتح الكبسولة في المستقبل.');
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
      await AchievementsService.recordTimeCapsuleSealed();
    });
  }

  /// Imports a pre-existing local capsule during schema migration. Unlike
  /// new capsules, legacy unlock dates may already be due and must be retained.
  static Future<void> importLegacyCapsule(
    String content,
    DateTime unlockDate,
  ) {
    final normalized = content.trim();
    if (normalized.isEmpty || normalized.length > maxContentLength) {
      throw ArgumentError('محتوى الكبسولة القديمة غير صالح.');
    }
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final capsules = _read(prefs);
      final unlockIso = unlockDate.toIso8601String();
      if (capsules.any((capsule) =>
          capsule['content'] == normalized &&
          capsule['unlockDate'] == unlockIso)) {
        return;
      }
      if (capsules.length >= maxCapsules) {
        throw StateError('لا توجد مساحة كافية لاستيراد الكبسولة القديمة.');
      }
      final now = DateTime.now();
      capsules.add({
        'id': now.microsecondsSinceEpoch.toString(),
        'content': normalized,
        'unlockDate': unlockIso,
        'sealed': now.toIso8601String(),
      });
      if (!await prefs.setString(_key, jsonEncode(capsules))) {
        throw StateError('تعذر استيراد الكبسولة القديمة.');
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getCapsules() async {
    await _writeQueue.catchError((Object _) {});
    final prefs = await SharedPreferences.getInstance();
    return _read(prefs);
  }

  static Future<void> removeCapsule(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('معرّف الكبسولة غير صالح.');
    }
    return _enqueueWrite(() async {
      final prefs = await SharedPreferences.getInstance();
      final capsules = _read(prefs);
      final updated = capsules
          .where((capsule) => capsule['id'] != normalizedId)
          .toList(growable: false);
      if (updated.length == capsules.length) return;
      if (!await prefs.setString(_key, jsonEncode(updated))) {
        throw StateError('تعذر حذف الكبسولة من التخزين المحلي.');
      }
    });
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

  static String _legacyId(String content, String unlockDate) {
    var checksum = 0;
    for (final unit in content.codeUnits) {
      checksum = (checksum * 31 + unit) & 0x7fffffff;
    }
    return 'legacy_${DateTime.tryParse(unlockDate)?.microsecondsSinceEpoch ?? 0}_${checksum.toRadixString(16)}';
  }

  static List<Map<String, dynamic>> _read(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw StateError('بنية الكبسولات المحفوظة ليست قائمة صالحة؛ لم تُستبدل البيانات الموجودة.');
      }
      final capsules = <Map<String, dynamic>>[];
      for (final row in decoded) {
        if (row is! Map) {
          throw StateError('تحتوي الكبسولات المحفوظة على سجل غير صالح؛ أُوقف الحفظ لحماية البيانات.');
        }
        final content = row['content'];
        final unlockDate = row['unlockDate'];
        if (content is! String ||
            content.trim().isEmpty ||
            content.length > maxContentLength ||
            unlockDate is! String ||
            DateTime.tryParse(unlockDate) == null) {
          throw StateError('تحتوي الكبسولات المحفوظة على حقول غير صالحة؛ أُوقف الحفظ لحماية البيانات.');
        }
        capsules.add(<String, dynamic>{
          'id': (row['id'] is String && (row['id'] as String).isNotEmpty)
              ? row['id']
              : _legacyId(content, unlockDate),
          'content': content,
          'unlockDate': unlockDate,
          'sealed': row['sealed'] is String ? row['sealed'] : '',
        });
      }
      return capsules.take(maxCapsules).toList(growable: true);
    } on FormatException catch (error) {
      // Never turn corrupted storage into an empty list: a subsequent write
      // could otherwise silently overwrite recoverable user data.
      throw StateError('تعذر قراءة الكبسولات المحفوظة؛ لم تُستبدل البيانات الموجودة. التفاصيل: $error');
    }
  }
}
