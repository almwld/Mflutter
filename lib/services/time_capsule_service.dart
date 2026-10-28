import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimeCapsuleService {
  static const _key = 'mudabbir.time_capsules';

  static const int maxCapsules = 200;
  static const int maxContentLength = 10000;

  static Future<void> sealCapsule(String content, DateTime unlockDate) async {
    final normalized = content.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('لا يمكن حفظ كبسولة فارغة.');
    }
    if (normalized.length > maxContentLength) {
      throw ArgumentError('يتجاوز محتوى الكبسولة الحد الأقصى البالغ 10000 حرف.');
    }
    final prefs = await SharedPreferences.getInstance();
    final capsules = _read(prefs);
    if (capsules.length >= maxCapsules) {
      throw StateError('بلغت الكبسولات المحلية الحد الأقصى ($maxCapsules). احذف أو صدّر بعض الكبسولات أولًا.');
    }
    capsules.add({
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'content': normalized,
      'unlockDate': unlockDate.toIso8601String(),
      'sealed': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_key, jsonEncode(capsules));
  }

  static Future<List<Map<String,dynamic>>> getCapsules() async {
    final prefs = await SharedPreferences.getInstance();
    return _read(prefs);
  }

  static Future<Map<String,dynamic>?> tryUnlock(int index) async {
    final capsules = await getCapsules();
    if (index < 0 || index >= capsules.length) return null;
    final capsule = capsules[index];
    final unlock = DateTime.tryParse(capsule['unlockDate'].toString());
    if (unlock == null || DateTime.now().isBefore(unlock)) return null;
    return capsule;
  }

  static List<Map<String,dynamic>> _read(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final value = jsonDecode(raw);
    return (value as List).map((e) => Map<String,dynamic>.from(e as Map)).toList();
  }
}
