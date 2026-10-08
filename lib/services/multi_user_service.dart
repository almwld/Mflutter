import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages local player profiles with durable persistence.
/// This is a local profile switcher, not an authentication system.
class MultiUserService {
  static const _storageKey = 'mudabbir_local_profiles_v1';
  static List<Map<String, dynamic>> _profiles = [];
  static int _activeProfile = 0;
  static bool _initialized = false;

  static Map<String, dynamic> get activeProfile =>
      _profiles.isEmpty ? _defaultProfile() : _profiles[_activeProfile.clamp(0, _profiles.length - 1)];

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
      _profiles = [_defaultProfile()];
      await _persist();
    }
    _activeProfile = 0;
    _initialized = true;
  }

  static Future<void> addProfile(String name, String avatar) async {
    await initialize();
    _profiles.add({
      'name': name.trim().isEmpty ? 'ملف جديد' : name.trim(),
      'avatar': avatar,
      'level': 1,
      'xp': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _persist();
  }

  static Future<void> switchProfile(int index) async {
    await initialize();
    if (index < 0 || index >= _profiles.length) {
      throw RangeError.index(index, _profiles);
    }
    _activeProfile = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_storageKey}_active', index);
  }

  static Future<void> addXP(int amount) async {
    await initialize();
    if (amount <= 0) return;
    final profile = _profiles[_activeProfile];
    final xp = (profile['xp'] as num?)?.toInt() ?? 0;
    profile['xp'] = xp + amount;
    profile['level'] = ((xp + amount) / 250).floor() + 1;
    await _persist();
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_profiles));
  }

  static Map<String, dynamic> _defaultProfile() => {
        'name': 'الملف الرئيسي',
        'avatar': '',
        'level': 5,
        'xp': 1250,
        'createdAt': DateTime.now().toIso8601String(),
      };
}
