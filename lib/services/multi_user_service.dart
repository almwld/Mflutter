import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages local player profiles with durable persistence.
/// This is a local profile switcher, not an authentication system.
class MultiUserService {
  static const _storageKey = 'mudabbir_local_profiles_v1';
  static List<Map<String, dynamic>> _profiles = [];
  static int _activeProfile = 0;
  static bool _initialized = false;
  static Future<void>? _initializing;
  static Future<void> _mutationQueue = Future<void>.value();

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

  static int get activeProfileIndex =>
      _activeProfile >= 0 && _activeProfile < _profiles.length
          ? _activeProfile
          : 0;

  static Future<void> initialize() async {
    if (_initialized) return;
    final pending = _initializing;
    if (pending != null) {
      await pending;
      return;
    }
    final attempt = _initializeOnce();
    _initializing = attempt;
    try {
      await attempt;
    } finally {
      if (identical(_initializing, attempt)) _initializing = null;
    }
  }

  static Future<void> _initializeOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _profiles = decoded
              .whereType<Map>()
              .take(20)
              .map((profile) => _normalizeProfile(
                    Map<String, dynamic>.from(profile),
                  ))
              .toList(growable: true);
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
    return _enqueueMutation(() async {
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
        'avatar': avatar.length > 32 ? avatar.substring(0, 32) : avatar,
        'level': 1,
        'xp': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _persist(updated);
      _profiles = updated;
    });
  }

  static Future<void> switchProfile(int index) async {
    await initialize();
    return _enqueueMutation(() async {
      if (index < 0 || index >= _profiles.length) {
        throw RangeError.index(index, _profiles);
      }
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setInt('${_storageKey}_active', index)) {
        throw StateError('تعذر حفظ الملف النشط محليًا.');
      }
      _activeProfile = index;
    });
  }

  static Future<void> addXP(int amount) async {
    await initialize();
    if (amount <= 0) return;
    return _enqueueMutation(() async {
      final updated = _profiles
          .map((profile) => Map<String, dynamic>.from(profile))
          .toList();
      final profile = updated[_activeProfile];
      final xp = (profile['xp'] as num?)?.toInt() ?? 0;
      final nextXp = (xp + amount).clamp(0, 0x7fffffff);
      profile['xp'] = nextXp;
      profile['level'] = (nextXp / 250).floor() + 1;
      await _persist(updated);
      _profiles = updated;
    });
  }

  static Future<void> _enqueueMutation(
    Future<void> Function() operation,
  ) {
    _mutationQueue = _mutationQueue
        .catchError((Object _) {})
        .then((_) => operation());
    return _mutationQueue;
  }

  static Future<void> _persist([
    List<Map<String, dynamic>>? profiles,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_storageKey, jsonEncode(profiles ?? _profiles))) {
      throw StateError('تعذر حفظ الملفات المحلية.');
    }
  }

  static Map<String, dynamic> _normalizeProfile(
    Map<String, dynamic> raw,
  ) {
    final rawName = raw['name'];
    final name = rawName is String && rawName.trim().isNotEmpty
        ? rawName.trim()
        : 'ملف محلي';
    final rawAvatar = raw['avatar'];
    final rawLevel = raw['level'];
    final rawXp = raw['xp'];
    final rawCreatedAt = raw['createdAt'];
    final parsedDate = rawCreatedAt is String
        ? DateTime.tryParse(rawCreatedAt)
        : null;
    return <String, dynamic>{
      'name': name.length > 60 ? name.substring(0, 60) : name,
      'avatar': rawAvatar is String
          ? (rawAvatar.length > 32 ? rawAvatar.substring(0, 32) : rawAvatar)
          : '',
      'level': rawLevel is num ? rawLevel.toInt().clamp(1, 100000) : 1,
      'xp': rawXp is num ? rawXp.toInt().clamp(0, 0x7fffffff) : 0,
      'createdAt': parsedDate?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _defaultProfile() => {
        'name': 'الملف الرئيسي',
        'avatar': '',
        'level': 5,
        'xp': 1250,
        'createdAt': DateTime.now().toIso8601String(),
      };
}
