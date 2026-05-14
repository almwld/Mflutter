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
  
  // النواة المحملة من الملف
  Map<String, dynamic>? _nucleus;
  List<Map<String, dynamic>> _verses = [];
  
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  int get userLevel => _userLevel;

  ChatProvider() {
    _loadNucleusFromFile();
  }

  // ═══════════════════════════════════════════════════════════
  // تحميل النواة من الملف (البيانات الحقيقية)
  // ═══════════════════════════════════════════════════════════

  Future<void> _loadNucleusFromFile() async {
    try {
      final file = File('/storage/emulated/0/Download/mudabbir_models/mudabbir_nucleus.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        _nucleus = jsonDecode(content);
        
        // استخراج الآيات من النواة
        if (_nucleus!['data'] != null) {
          _verses = List<Map<String, dynamic>>.from(_nucleus!['data']);
        } else if (_nucleus!['verses'] != null) {
          _verses = List<Map<String, dynamic>>.from(_nucleus!['verses']);
        }
      }
    } catch (e) {
      // استخدام البيانات المدمجة إذا لم يوجد الملف
      _loadBuiltInData();
    }
  }

  void _loadBuiltInData() {
    // بيانات مدمجة (احتياط)
    _verses = [
      {'surah': 1, 'ayah': 1, 'text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', 'sciences': ['علم اللغة'], 'attributes': ['الرحمن', 'الرحيم'], 'jummal': 786, 'mod19': 7, 'mod7': 2},
      {'surah': 2, 'ayah': 255, 'text': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ', 'sciences': ['علم التوحيد'], 'attributes': ['الله', 'الحي', 'القيوم'], 'jummal': 3192, 'mod19': 0, 'mod7': 0},
      {'surah': 51, 'ayah': 47, 'text': 'وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ وَإِنَّا لَمُوسِعُونَ', 'sciences': ['علم الفلك', 'علم الفيزياء'], 'attributes': ['القوي', 'الواسع'], 'jummal': 174405, 'mod19': 4, 'mod7': 0},
      {'surah': 112, 'ayah': 1, 'text': 'قُلْ هُوَ اللَّهُ أَحَدٌ', 'sciences': ['علم التوحيد'], 'attributes': ['الله', 'الأحد'], 'jummal': 111, 'mod19': 16, 'mod7': 6},
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // المحرك: يقرأ من البيانات الحقيقية (النواة)
  // ═══════════════════════════════════════════════════════════

  void sendMessage(String text) {
    _messages.add(ChatMessage(content: text, isUser: true, timestamp: DateTime.now()));
    _isLoading = true;
    notifyListeners();
    
    Future.delayed(Duration(milliseconds: 500), () {
      final response = _generateFromNucleus(text);
      _messages.add(ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        abjadResult: AbjadResult.fromText(text),
      ));
      _isLoading = false;
      _updateLevel();
      notifyListeners();
    });
  }

  String _generateFromNucleus(String question) {
    final q = question.trim();
    final words = q.split(' ').where((w) => w.length > 2).toList();
    
    // ١. البحث في الآيات المحملة من النواة
    Map<String, dynamic>? bestMatch;
    int bestScore = 0;
    
    for (final verse in _verses) {
      int score = 0;
      final verseText = (verse['text'] ?? '').toString();
      for (final word in words) {
        if (verseText.contains(word)) score += 3;
      }
      // تطابق في العلوم
      final sciences = verse['sciences'] ?? [];
      for (final word in words) {
        if (sciences.toString().contains(word)) score += 2;
      }
      // تطابق في الصفات
      final attrs = verse['attributes'] ?? [];
      for (final word in words) {
        if (attrs.toString().contains(word)) score += 2;
      }
      
      if (score > bestScore) {
        bestScore = score;
        bestMatch = verse;
      }
    }
    
    // ٢. بناء الإجابة من بيانات الآية الحقيقية
    if (bestMatch != null && bestScore > 0) {
      final text = bestMatch['text'] ?? '';
      final surah = bestMatch['surah'] ?? '';
      final ayah = bestMatch['ayah'] ?? '';
      final sciences = (bestMatch['sciences'] as List?)?.join(', ') ?? 'علوم متعددة';
      final attrs = (bestMatch['attributes'] as List?)?.join(', ') ?? 'الله';
      final jummal = bestMatch['jummal'] ?? 0;
      final mod19 = bestMatch['mod19'] ?? 0;
      final mod7 = bestMatch['mod7'] ?? 0;
      final questionAbjad = AbjadResult.fromText(q);
      
      return '''
بسم الله الرحمن الرحيم

📖 **أقرب آية لسؤالك**: ﴿$text﴾
📍 السورة: $surah | الآية: $ayah

🔬 **العلوم المستنبطة**: $sciences

🔮 **الصفات الإلهية**: $attrs

🔢 **البصمة الرقمية**:
• جمل الآية: $jummal
• ÷19: $mod19 | ÷7: $mod7
• جمل سؤالك: ${questionAbjad.kabir}
• الطاقة: ${(questionAbjad.kabir * 1.618).toStringAsFixed(0)}

💡 **تأمل**: هذه الآية من النواة (${_verses.length} آية محملة). تدبر معانيها.

🕌 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}
''';
    }
    
    // ٣. لا يوجد تطابق - رد عام مع بيانات حقيقية
    final abjad = AbjadResult.fromText(q);
    return '''
بسم الله الرحمن الرحيم

🔍 **بحثت في النواة** (${_verses.length} آية) عن: ${words.take(3).join(', ')}

📖 لم أجد تطابقاً مباشراً. جرب كلمات من القرآن.

🔢 **جمل سؤالك**: ${abjad.kabir}
• ÷19: ${abjad.kabir % 19} | ÷7: ${abjad.kabir % 7}

💡 النواة محملة من: mudabbir_nucleus.json

🕌 ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}
''';
  }

  void _updateLevel() {
    if (_messages.length > 5) _userLevel = 2;
    if (_messages.length > 15) _userLevel = 3;
  }
}
