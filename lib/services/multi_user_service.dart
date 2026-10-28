import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages local player profiles with durable persistence.
/// This is a local profile switcher, not an authentication system.
class MultiUserService {
  static const _storageKey = 'mudabbir_local_profiles_v1';
  static List<Map<String, dynamic>> _profiles = [];
  static int _activeProfile = 0;
  static bool _initialized = false;

  static Map<String, dynamic> get activeProfile {
    if (_profiles.isEmpty) {
      return Map<String, dynamic>.unmodifiable(_defaultProfile());
    }
    final index =
        _activeProfile >= 0 && _activeProfile < _profiles.length
            ? _activeProfile
            : 0;
    return Map<String, dynamic>.unmodifiable(_profiles[index]);
  }

  static List<Map<String, dynamic>> get profiles =>
      List.unmodifiable(_profiles.map((p) => Map<String, dynamic>.from(p)));

  static Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _profiles = decoded
              .whereType<Map>()
              .map((p) => Map<String, dynamic>.from(p))
              .toList();
        }
      } catch (_) {
        _profiles = [];
      }
    }
    if (_profiles.isEmpty) {
      final defaults = <Map<String, dynamic>>[_defaultProfile()];
      await _persist(defaults);
      _profiles = defaults;
    }
    final savedIndex = prefs.getInt('${_storageKey}_active') ?? 0;
    _activeProfile = savedIndex >= 0 && savedIndex < _profiles.length
        ? savedIndex
        : 0;
    _initialized = true;
  }

  static Future<void> addProfile(String name, String avatar) async {
    await initialize();
    if (_profiles.length >= 20) {
      throw StateError('بلغت الملفات المحلية الحد الأقصى (20).');
    }
    final normalizedName = name.trim();
    final updated = _profiles
        .map((profile) => Map<String, dynamic>.from(profile))
        .toList();
    updated.add({
      'name': normalizedName.isEmpty
          ? 'ملف جديد'
          : (normalizedName.length > 60
              ? normalizedName.substring(0, 60)
              : normalizedName),
      'avatar': avatar,
      'level': 1,
      'xp': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _persist(updated);
    _profiles = updated;
  }

  static Future<void> switchProfile(int index) async {
    await initialize();
    if (index < 0 || index >= _profiles.length) {
      throw RangeError.index(index, _profiles);
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setInt('${_storageKey}_active', index)) {
      throw StateError('تعذر حفظ الملف النشط محليًا.');
    }
    _activeProfile = index;
  }

  static Future<void> addXP(int amount) async {
    await initialize();
    if (amount <= 0) return;
    final updated = _profiles
        .map((profile) => Map<String, dynamic>.from(profile))
        .toList();
    final profile = updated[_activeProfile];
    final xp = (profile['xp'] as num?)?.toInt() ?? 0;
    final nextXp = xp + amount;
    profile['xp'] = nextXp;
    profile['level'] = (nextXp / 250).floor() + 1;
    await _persist(updated);
    _profiles = updated;
  }

  static Future<void> _persist([
    List<Map<String, dynamic>>? profiles,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_storageKey, jsonEncode(profiles ?? _profiles))) {
      throw StateError('تعذر حفظ الملفات المحلية.');
    }
  }

  static Map<String, dynamic> _defaultProfile() => {
        'name': 'الملف الرئيسي',
        'avatar': '',
        'level': 5,
        'xp': 1250,
        'createdAt': DateTime.now().toIso8601String(),
      };
}
