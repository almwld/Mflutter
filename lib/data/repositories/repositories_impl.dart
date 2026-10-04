import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/verse.dart';
import '../../domain/models/quran_models.dart';
import '../datasources/local/quran_local_datasource.dart';
import '../datasources/local/abjad_local_datasource.dart';
import '../datasources/local/models_local_datasource.dart';
import '../datasources/local/settings_local_datasource.dart';
import '../../core/utils/abjad_calculator.dart';

class QuranRepositoryImpl {
  final QuranLocalDatasource _datasource;
  QuranRepositoryImpl({QuranLocalDatasource? datasource}) : _datasource = datasource ?? QuranLocalDatasource();

  Future<List<Surah>> getAllSurahs() => _datasource.getSurahs();
  Future<List<Verse>> getSurahVerses(int n) async => (await _datasource.getVersesBySurah(n)).map(Ayah.fromJson).toList();
  Future<Verse?> getVerse(int s,int a) async { final row=await _datasource.getVerse(s,a); return row==null?null:Ayah.fromJson(row); }
  Future<List<Verse>> search(String q) async => (await _datasource.searchVerses(q)).map(Ayah.fromJson).toList();
  Future<Verse> getRandomVerse() async { final rows=await _datasource.searchVerses(''); if(rows.isEmpty) throw StateError('لا توجد آيات محلية.'); return Ayah.fromJson(rows.first); }
  Future<Verse> getDailyVerse() => getRandomVerse();
  Future<List<Juz>> getAllJuz() => _datasource.getAllJuzs();
}

class AbjadRepositoryImpl {
  final AbjadLocalDatasource _datasource;
  AbjadRepositoryImpl({AbjadLocalDatasource? datasource}) : _datasource = datasource ?? AbjadLocalDatasource();
  dynamic calculateAbjad(String text) => _toEntity(AbjadCalculator.calculateAll(text));
  dynamic analyzeLetters(String text) => _datasource.analyze(text);
  dynamic getElementalBalance(String text) { final r=AbjadCalculator.calculateAll(text); return {'element':r.element.name,'color':r.color}; }
  dynamic getPlanetaryInfluence(String text) { final r=AbjadCalculator.calculateAll(text); return {'planet':r.planet.name,'zodiac':r.zodiac.name}; }
  dynamic getDivineResonance(String text) { final r=AbjadCalculator.calculateAll(text); return {'name':r.divineName,'value':r.kabir}; }
  dynamic _toEntity(AbjadResult r) => {'text':r.text,'kabir':r.kabir,'saghir':r.saghir,'wasat':r.wasat,'element':r.element.name,'planet':r.planet.name,'zodiac':r.zodiac.name,'divineName':r.divineName,'frequency':r.frequency,'color':r.color};
}

class ModelsRepositoryImpl {
  final ModelsLocalDatasource _datasource;
  ModelsRepositoryImpl({ModelsLocalDatasource? datasource}) : _datasource = datasource ?? ModelsLocalDatasource();
  Future<Map<String,dynamic>?> getModelInfo(String n) async => _datasource.getModelInfo(n);
  Future<bool> loadModel(String n) => _datasource.loadModel(n);
  Future<Map<String,dynamic>> runInference(String n,List<double> f) => _datasource.runInference(n,f);
  List<double> extractFeatures(String t) => _datasource.extractFeatures(t);
  Future<List<Map<String,dynamic>>> getAllModels() => _datasource.getModelsInfo();
  Future<void> unloadModel(String n) => _datasource.unloadModel(n);
}

class ChatRepositoryImpl {
  static const _conversationsKey = 'mudabbir.chat.conversations';
  static const _messagesKey = 'mudabbir.chat.messages';
  static const _searchHistoryKey = 'mudabbir.chat.search_history';
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _read(String key) async {
    final raw = (await _prefs).getString(key);
    if (raw == null || raw.isEmpty) return [];
    final value = jsonDecode(raw);
    if (value is! List) return [];
    return value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  Future<void> _write(String key, List<Map<String, dynamic>> value) async =>
      (await _prefs).setString(key, jsonEncode(value));
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<Map<String, dynamic>?> getConversation(String id) async {
    for (final item in await _read(_conversationsKey)) {
      if (item['id']?.toString() == id) return item;
    }
    return null;
  }
  Future<List<Map<String, dynamic>>> getAllConversations() async =>
      List.unmodifiable(await _read(_conversationsKey));

  Future<Map<String, dynamic>> createConversation(String title) async {
    final items = await _read(_conversationsKey);
    final now = DateTime.now().toIso8601String();
    final item = {'id': _id(), 'title': title.trim(), 'createdAt': now, 'lastMessageAt': now};
    items.add(item);
    await _write(_conversationsKey, items);
    return item;
  }

  Future<Map<String, dynamic>> addMessage(String conversationId, String content, int type) async {
    final messages = await _read(_messagesKey);
    final message = {'id': _id(), 'conversationId': conversationId, 'content': content, 'type': type, 'timestamp': DateTime.now().toIso8601String()};
    messages.add(message);
    await _write(_messagesKey, messages);
    final conversations = await _read(_conversationsKey);
    final i = conversations.indexWhere((x) => x['id']?.toString() == conversationId);
    if (i >= 0) {
      conversations[i]['lastMessageAt'] = message['timestamp'];
      await _write(_conversationsKey, conversations);
    }
    return message;
  }

  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async =>
      List.unmodifiable((await _read(_messagesKey)).where((m) => m['conversationId']?.toString() == conversationId));

  Future<void> deleteConversation(String id) async {
    final conversations = await _read(_conversationsKey);
    final messages = await _read(_messagesKey);
    conversations.removeWhere((c) => c['id']?.toString() == id);
    messages.removeWhere((m) => m['conversationId']?.toString() == id);
    await _write(_conversationsKey, conversations);
    await _write(_messagesKey, messages);
  }

  Future<void> saveConversation(Map<String, dynamic> conversation) async {
    final conversations = await _read(_conversationsKey);
    final i = conversations.indexWhere((c) => c['id']?.toString() == conversation['id']?.toString());
    final copy = Map<String, dynamic>.from(conversation);
    if (i >= 0) conversations[i] = copy; else conversations.add(copy);
    await _write(_conversationsKey, conversations);
  }

  Future<List<Map<String, dynamic>>> getSearchHistory() async =>
      List.unmodifiable(await _read(_searchHistoryKey));

  Future<void> addSearchHistory(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final items = await _read(_searchHistoryKey);
    items.removeWhere((x) => x['query']?.toString() == q);
    items.insert(0, {'query': q, 'timestamp': DateTime.now().toIso8601String()});
    if (items.length > 50) items.removeRange(50, items.length);
    await _write(_searchHistoryKey, items);
  }
}

class SettingsRepositoryImpl {
  final SettingsLocalDatasource _datasource;
  SettingsRepositoryImpl({SettingsLocalDatasource? datasource}) : _datasource = datasource ?? SettingsLocalDatasource();
  Future<String> getTheme()=>_datasource.getTheme();
  Future<bool> setTheme(String v)=>_datasource.setTheme(v);
  Future<String> getLanguage()=>_datasource.getLanguage();
  Future<bool> setLanguage(String v)=>_datasource.setLanguage(v);
  Future<T?> getSetting<T>(String k)=>_datasource.getSetting<T>(k);
  Future<bool> setSetting<T>(String k,T v)=>_datasource.setSetting(k,v);
  Future<void> clearCache()=>_datasource.clearCache();
  static const _profileKey = 'mudabbir.user.profile';
  Future<Map<String,dynamic>?> getUserProfile() async {
    final raw = (await SharedPreferences.getInstance()).getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    final value = jsonDecode(raw);
    return value is Map ? Map<String,dynamic>.from(value) : null;
  }
  Future<void> saveUserProfile(Map<String,dynamic> profile) async =>
      (await SharedPreferences.getInstance()).setString(_profileKey, jsonEncode(profile));
}
