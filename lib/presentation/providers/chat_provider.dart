import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/abjad_result.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  // قاعدة معرفة مدمجة للرد على أي سؤال
  static const Map<String, String> _knowledgeBase = {
    'الله': 'الله هو الخالق البارئ المصور. ﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ﴾ (البقرة:255). وهو اسم الجلالة الأعظم.',
    'القرآن': 'القرآن الكريم كلام الله المنزل على محمد ﷺ، المتعبد بتلاوته، المنقول إلينا بالتواتر. عدد سوره 114 سورة.',
    'صلاة': 'الصلاة عماد الدين، فرضت على المسلمين خمس مرات في اليوم والليلة. ﴿إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا﴾ (النساء:103).',
    'جنة': 'الجنة دار النعيم التي أعدها الله للمتقين. فيها ما لا عين رأت ولا أذن سمعت ولا خطر على قلب بشر.',
    'نار': 'النار دار العذاب التي أعدها الله للكافرين. أعاذنا الله منها.',
    'موسى': 'موسى كليم الله، أرسله إلى فرعون وقومه. أنزل الله عليه التوراة. ورد ذكره في القرآن 136 مرة.',
    'إبراهيم': 'إبراهيم خليل الله، أبو الأنبياء. بنى الكعبة مع ابنه إسماعيل. ﴿وَاتَّخَذَ اللَّهُ إِبْرَاهِيمَ خَلِيلًا﴾.',
    'محمد': 'محمد ﷺ خاتم الأنبياء والمرسلين. أرسله الله رحمة للعالمين. ﴿وَمَا أَرْسَلْنَاكَ إِلَّا رَحْمَةً لِّلْعَالَمِينَ﴾.',
    'الملائكة': 'الملائكة خلق من نور، لا يعصون الله ما أمرهم ويفعلون ما يؤمرون. منهم جبريل وميكائيل وإسرافيل.',
    'الجن': 'الجن خلق من نار، منهم المؤمن ومنهم الكافر. ﴿وَأَنَّا مِنَّا الْمُسْلِمُونَ وَمِنَّا الْقَاسِطُونَ﴾ (الجن:14).',
    'الشمس': 'الشمس آية من آيات الله. ﴿وَالشَّمْسُ تَجْرِي لِمُسْتَقَرٍّ لَّهَا ۚ ذَٰلِكَ تَقْدِيرُ الْعَزِيزِ الْعَلِيمِ﴾ (يس:38).',
    'القمر': 'القمر آية من آيات الله. ﴿وَالْقَمَرَ قَدَّرْنَاهُ مَنَازِلَ حَتَّىٰ عَادَ كَالْعُرْجُونِ الْقَدِيمِ﴾ (يس:39).',
  };

  void sendMessage(String text) {
    _messages.add(ChatMessage(content: text, isUser: true, timestamp: DateTime.now()));
    _isLoading = true;
    notifyListeners();
    
    Future.delayed(Duration(milliseconds: 800), () {
      final response = _generateResponse(text);
      _messages.add(ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        abjadResult: AbjadResult.fromText(text),
      ));
      _isLoading = false;
      notifyListeners();
    });
  }

  String _generateResponse(String question) {
    final q = question.trim();
    
    // ١. البحث في قاعدة المعرفة
    for (final entry in _knowledgeBase.entries) {
      if (q.contains(entry.key)) {
        return 'بسم الله الرحمن الرحيم\n\n${entry.value}\n\n🔢 جمل السؤال: ${AbjadResult.fromText(q).kabir}';
      }
    }
    
    // ٢. أسئلة عن الجمل
    if (q.contains('جمل') || q.contains('حساب')) {
      final abjad = AbjadResult.fromText(q.replaceAll('جمل', '').replaceAll('حساب', '').trim());
      return 'بسم الله الرحمن الرحيم\n\n🧮 تحليل الجمل:\n• الجمل الكبير: ${abjad.kabir}\n• الجمل الصغير: ${abjad.saghir}\n• الجمل الوسط: ${abjad.wasat}';
    }
    
    // ٣. أسئلة عامة - رد ذكي
    final abjad = AbjadResult.fromText(q);
    final words = q.split(' ');
    final responses = [
      'بسم الله الرحمن الرحيم\n\nسؤالك عن "${q.length > 50 ? q.substring(0, 50) + '...' : q}" جعلني أتدبر.\n\n📖 قال تعالى: ﴿وَفَوْقَ كُلِّ ذِي عِلْمٍ عَلِيمٌ﴾ (يوسف:76).\n\n🔢 جمل سؤالك: ${abjad.kabir}\n\n💡 تأمل في آيات الله في الكون تجد الإجابة.',
      'بسم الله الرحمن الرحيم\n\nبحثت في قاعدة معرفتي عن "${words.first}".\n\n📖 ﴿وَمَا أُوتِيتُم مِّنَ الْعِلْمِ إِلَّا قَلِيلًا﴾ (الإسراء:85).\n\n🔢 الجمل: ${abjad.kabir}\n\n💡 أقترح عليك قراءة سورة الإخلاص بتدبر.',
      'بسم الله الرحمن الرحيم\n\nسؤالك عميق. تأملت فيه:\n• الكلمات المفتاحية: ${words.take(3).join(', ')}\n• الجمل الكبير: ${abjad.kabir}\n• باقي ÷19: ${abjad.kabir % 19}\n\n📖 ﴿أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ﴾ (النساء:82)',
    ];
    
    return responses[abjad.kabir % responses.length];
  }
}
