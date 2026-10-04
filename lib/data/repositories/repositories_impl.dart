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
  final List<Map<String,dynamic>> _conversations=[];
  final List<Map<String,dynamic>> _messages=[];
  String _id() => DateTime.now().microsecondsSinceEpoch.toString();
  Future<Map<String,dynamic>?> getConversation(String id) async { try{return _conversations.firstWhere((c)=>c['id']==id);}catch(_){return null;} }
  Future<List<Map<String,dynamic>>> getAllConversations() async => List.unmodifiable(_conversations);
  Future<Map<String,dynamic>> createConversation(String title) async { final now=DateTime.now().toIso8601String(); final c={'id':_id(),'title':title,'createdAt':now,'lastMessageAt':now};_conversations.add(c);return c; }
  Future<Map<String,dynamic>> addMessage(String conversationId,String content,int type) async { final m={'id':_id(),'conversationId':conversationId,'content':content,'type':type,'timestamp':DateTime.now().toIso8601String()};_messages.add(m);return m; }
  Future<void> deleteConversation(String id) async {_conversations.removeWhere((c)=>c['id']==id);_messages.removeWhere((m)=>m['conversationId']==id);}
  Future<void> saveConversation(Map<String,dynamic> c) async {final i=_conversations.indexWhere((x)=>x['id']==c['id']);if(i>=0)_conversations[i]=c;else _conversations.add(c);}
  Future<List<Map<String,dynamic>>> getSearchHistory() async => const [];
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
  Future<Map<String,dynamic>?> getUserProfile() async => null;
  Future<void> saveUserProfile(Map<String,dynamic> profile) async {}
}
