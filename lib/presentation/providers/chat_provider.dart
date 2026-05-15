import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/abjad_result.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int _userLevel = 1;
  List<String> _userTopics = [];
  Map<String, dynamic>? _nucleus;
  List<Map<String, dynamic>> _verses = [];

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  int get userLevel => _userLevel;

  ChatProvider() { _loadNucleus(); }

  Future<void> _loadNucleus() async {
    try {
      final file = File('/storage/emulated/0/Download/mudabbir_models/mudabbir_nucleus.json');
      if (await file.exists()) {
        _nucleus = jsonDecode(await file.readAsString());
        if (_nucleus!['data'] != null) {
          _verses = List<Map<String, dynamic>>.from(_nucleus!['data']);
        }
      }
    } catch (_) {
      _loadBuiltInVerses();
    }
  }

  void _loadBuiltInVerses() {
    _verses = [
      {'surah':1,'ayah':1,'text':'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ','sciences':['علم اللغة'],'attributes':['الرحمن','الرحيم'],'jummal':786,'mod19':7,'mod7':2},
      {'surah':2,'ayah':255,'text':'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ','sciences':['علم التوحيد'],'attributes':['الله','الحي','القيوم'],'jummal':3192,'mod19':0,'mod7':0},
      {'surah':51,'ayah':47,'text':'وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ وَإِنَّا لَمُوسِعُونَ','sciences':['علم الفلك','علم الفيزياء'],'attributes':['القوي','الواسع'],'jummal':174405,'mod19':4,'mod7':0},
      {'surah':112,'ayah':1,'text':'قُلْ هُوَ اللَّهُ أَحَدٌ','sciences':['علم التوحيد'],'attributes':['الأحد','الصمد'],'jummal':111,'mod19':16,'mod7':6},
    ];
  }

  void sendMessage(String text) {
    _messages.add(ChatMessage(content: text, isUser: true, timestamp: DateTime.now()));
    _isLoading = true;
    notifyListeners();
    
    Future.delayed(Duration(milliseconds: 500), () {
      final response = _thinkDeep(text);
      _messages.add(ChatMessage(content: response, isUser: false, timestamp: DateTime.now(), abjadResult: AbjadResult.fromText(text)));
      _isLoading = false;
      _updateLevel();
      notifyListeners();
    });
  }

  String _thinkDeep(String q) {
    final abjad = AbjadResult.fromText(q);
    Map<String, dynamic>? match = _searchNucleus(q);
    String sciences = _findSciences(q);
    String attrs = _findAttributes(q);
    String verse = match != null ? '﴿${match['text']}﴾ (${match['surah']}:${match['ayah']})' : _findVerse(q);
    String insight = _generateInsight(q);
    
    return 'بسم الله الرحمن الرحيم\n\n'
        '📖 $verse\n\n'
        '🔬 العلوم: $sciences\n\n'
        '🔮 الصفات: $attrs\n\n'
        '🔢 الجمل: ${abjad.kabir} | ÷19: ${abjad.kabir%19} | ÷7: ${abjad.kabir%7}\n'
        '• العنصر: ${["نار","تراب","هواء","ماء","روح"][abjad.kabir%5]}\n'
        '• الطاقة: ${(abjad.kabir*1.618).toStringAsFixed(0)}\n\n'
        '💡 $insight\n\n'
        '🕌 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2,"0")}';
  }

  Map<String, dynamic>? _searchNucleus(String q) {
    final words = q.split(' ').where((w) => w.length > 2).toList();
    Map<String, dynamic>? best; int bestScore = 0;
    for (final v in _verses) {
      int score = 0;
      for (final w in words) {
        if ((v['text']??'').toString().contains(w)) score += 3;
        if ((v['sciences']??[]).toString().contains(w)) score += 2;
        if ((v['attributes']??[]).toString().contains(w)) score += 2;
      }
      if (score > bestScore) { bestScore = score; best = v; }
    }
    return bestScore > 0 ? best : null;
  }

  String _findVerse(String q) {
    final verses = {
      'الله':'﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ﴾ (البقرة:255)',
      'خلق':'﴿إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ﴾ (البقرة:164)',
      'علم':'﴿وَفَوْقَ كُلِّ ذِي عِلْمٍ عَلِيمٌ﴾ (يوسف:76)',
      'نور':'﴿اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ﴾ (النور:35)',
      'سماء':'﴿وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ﴾ (الذاريات:47)',
      'جبل':'﴿وَالْجِبَالَ أَوْتَادًا﴾ (النبأ:7)',
      'صبر':'﴿إِنَّ اللَّهَ مَعَ الصَّابِرِينَ﴾ (البقرة:153)',
    };
    for (final e in verses.entries) { if (q.contains(e.key)) return e.value; }
    return '﴿أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ﴾ (النساء:82)';
  }

  String _findSciences(String q) {
    final sci = {
      'سماء':'علم الفلك - توسع الكون','نجم':'علم الفلك','شمس':'علم الفلك',
      'جبل':'علم الجيولوجيا','بحر':'علم البحار','خلق':'علم الأجنة',
      'نفس':'علم النفس','نور':'علم الفيزياء','ماء':'علم المياه','نبات':'علم النبات',
    };
    for (final e in sci.entries) { if (q.contains(e.key)) return e.value; }
    return 'علوم متعددة';
  }

  String _findAttributes(String q) {
    final attrs = {
      'خلق':'الخالق - البارئ','رزق':'الرزاق','علم':'العليم - الحكيم',
      'هدى':'الهادي','رحمة':'الرحمن - الرحيم','قوة':'القوي','ملك':'الملك',
    };
    for (final e in attrs.entries) { if (q.contains(e.key)) return e.value; }
    return 'الله - الرحمن - الرحيم';
  }

  String _generateInsight(String q) {
    final pool = _userLevel == 1 
      ? ['توقف لحظة... كيف ترتبط هذه الآية بحياتك اليومية؟','ما الكلمة التي لفتت انتباهك أكثر؟']
      : _userLevel == 2
        ? ['كيف يرتبط الرقم ${AbjadResult.fromText(q).kabir%19} بمعنى الآية؟','ما العلاقة بين العلم والصفة هنا؟']
        : ['لو كنت عالماً، ما التجربة التي ستصممها؟','اربط هذه الآية بآية من سورة أخرى.'];
    return pool[Random().nextInt(pool.length)];
  }

  void _updateLevel() {
    if (_messages.length > 5) _userLevel = 2;
    if (_messages.length > 15) _userLevel = 3;
  }
}
