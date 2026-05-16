import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/abjad_result.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  final _random = Random();

  List<ChatMessage> get messages => _messages;
  bool get loading => _loading;

  // بنك معرفي غني للردود المتنوعة
  static const _knowledgeBase = [
    {
      'keywords': ['خلق', 'سماوات', 'أرض', 'كون'],
      'verse': 'اللَّهُ الَّذِي خَلَقَ السَّمَاوَاتِ وَالْأَرْضَ وَمَا بَيْنَهُمَا فِي سِتَّةِ أَيَّامٍ',
      'ref': 'السجدة:4',
      'science': 'فلك، فيزياء، جيولوجيا',
      'attribute': 'الخالق، العليم، القدير',
      'insight': 'كيف تجلى نظام خلق الكون في ستة أيام مع اتساعه المستمر؟',
    },
    {
      'keywords': ['نور', 'هدى', 'هداية', 'ظلمات'],
      'verse': 'اللَّهُ وَلِيُّ الَّذِينَ آمَنُوا يُخْرِجُهُم مِّنَ الظُّلُمَاتِ إِلَى النُّورِ',
      'ref': 'البقرة:257',
      'science': 'فيزياء النور، بصريات',
      'attribute': 'النور، الهادي، الولي',
      'insight': 'كيف يتحول النور الفيزيائي إلى نور قلبي في رحلة الإيمان؟',
    },
    {
      'keywords': ['رزق', 'طعام', 'شراب', 'مال', 'غنى'],
      'verse': 'وَمَا مِن دَابَّةٍ فِي الْأَرْضِ إِلَّا عَلَى اللَّهِ رِزْقُهَا',
      'ref': 'هود:6',
      'science': 'اقتصاد، أحياء، بيئة',
      'attribute': 'الرزاق، الوكيل، الكفيل',
      'insight': 'كيف يضمن التوكل على الرزاق التوازن النفسي في عصر الاستهلاك؟',
    },
    {
      'keywords': ['شفاء', 'مرض', 'دواء', 'صحة', 'قرآن'],
      'verse': 'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ',
      'ref': 'الإسراء:82',
      'science': 'طب، علم نفس، ترددات صوتية',
      'attribute': 'الشافي، الرحمن، الرحيم',
      'insight': 'كيف تتفاعل الترددات الصوتية للقرآن مع خلايا الجسد للشفاء؟',
    },
    {
      'keywords': ['علم', 'تعلم', 'معرفة', 'عقل', 'فكر'],
      'verse': 'وَعَلَّمَكَ مَا لَمْ تَكُن تَعْلَمُ وَكَانَ فَضْلُ اللَّهِ عَلَيْكَ عَظِيمًا',
      'ref': 'النساء:113',
      'science': 'علوم معرفية، تعليم، ذكاء اصطناعي',
      'attribute': 'العليم، الوهاب، المعطي',
      'insight': 'هل يمكن للذكاء الاصطناعي أن يكون أداة لفهم أعمق للوحي؟',
    },
    {
      'keywords': ['قلب', 'طمأنينة', 'ذكر', 'سكينة', 'روح'],
      'verse': 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      'ref': 'الرعد:28',
      'science': 'علم نفس، أعصاب، تردد 432 هرتز',
      'attribute': 'السلام، المؤمن، اللطيف',
      'insight': 'كيف يقيس العلم الحديث أثر الذكر على موجات الدماغ؟',
    },
    {
      'keywords': ['ماء', 'بحر', 'نهر', 'حياة', 'مطر'],
      'verse': 'وَجَعَلْنَا مِنَ الْمَاءِ كُلَّ شَيْءٍ حَيٍّ ۖ أَفَلَا يُؤْمِنُونَ',
      'ref': 'الأنبياء:30',
      'science': 'أحياء، كيمياء، ماء',
      'attribute': 'الحي، القيوم، المحيي',
      'insight': 'لماذا كان الماء سر الحياة الأول في كل النظريات العلمية؟',
    },
    {
      'keywords': ['وقت', 'زمن', 'عصر', 'دهر', 'أجل'],
      'verse': 'وَالْعَصْرِ إِنَّ الْإِنسَانَ لَفِي خُسْرٍ',
      'ref': 'العصر:1-2',
      'science': 'فيزياء الزمن، إدارة وقت',
      'attribute': 'الحكيم، العليم، البصير',
      'insight': 'كيف تجعل من الزمن استثماراً لا خسارة في ميزان الدهر؟',
    },
    {
      'keywords': ['جبل', 'أرض', 'زلزال', 'ثبات', 'أوتاد'],
      'verse': 'وَالْجِبَالَ أَوْتَادًا',
      'ref': 'النبأ:7',
      'science': 'جيولوجيا، تكتونية، تضاريس',
      'attribute': 'المتين، القوي، الحفيظ',
      'insight': 'كيف أثبت العلم الحديث وظيفة الجبال كأوتاد لتثبيت القشرة الأرضية؟',
    },
    {
      'keywords': ['نوم', 'ليل', 'سبات', 'راحة', 'آيات'],
      'verse': 'وَمِنْ آيَاتِهِ مَنَامُكُم بِاللَّيْلِ وَالنَّهَارِ',
      'ref': 'الروم:23',
      'science': 'طب نوم، أحياء زمني، أعصاب',
      'attribute': 'اللطيف، الحكيم، الخبير',
      'insight': 'كيف تصمم دورة نومك وفق الآية لتستقبل أسرار الليل والنهار؟',
    },
    {
      'keywords': ['نجم', 'سماء', 'فلك', 'كوكب', 'بروج'],
      'verse': 'وَالسَّمَاءِ ذَاتِ الْبُرُوجِ',
      'ref': 'البروج:1',
      'science': 'فلك، فيزياء فلكية، أبراج',
      'attribute': 'العظيم، العليم، الخالق',
      'insight': 'ما سر القَسَم بالسماء ذات البروج وما علاقتها بالثقوب السوداء؟',
    },
    {
      'keywords': ['إنسان', 'خلق', 'نطفة', 'جنين', 'أطوار'],
      'verse': 'وَلَقَدْ خَلَقْنَا الْإِنسَانَ مِن سُلَالَةٍ مِّن طِينٍ',
      'ref': 'المؤمنون:12',
      'science': 'أجنة، طب، أحياء تطورية',
      'attribute': 'الخالق، البارئ، المصور',
      'insight': 'كيف وصف القرآن أطوار الجنين قبل 1400 عام بدقة علمية مذهلة؟',
    },
  ];

  void sendMessage(String text) {
    // إضافة سؤال المستخدم
    _messages.add(ChatMessage(text: text, isUser: true));
    _loading = true;
    notifyListeners();

    // محاكاة تفكير النموذج (في الواقع سيتصل بـ OpenRouter أو TFLite)
    Future.delayed(const Duration(milliseconds: 800), () {
      final response = _generateSmartResponse(text);
      _messages.add(response);
      _loading = false;
      notifyListeners();
    });
  }

  ChatMessage _generateSmartResponse(String query) {
    // ١. حساب الجمل للسؤال
    final queryJummal = _calculateJummal(query);
    final jummalMod19 = queryJummal % 19;
    final jummalMod7 = queryJummal % 7;

    // ٢. البحث في بنك المعرفة عن أفضل تطابق
    Map<String, dynamic>? bestMatch;
    int bestScore = 0;

    for (final entry in _knowledgeBase) {
      int score = 0;
      for (final keyword in entry['keywords'] as List<String>) {
        if (query.contains(keyword)) {
          score += keyword.length; // الكلمة الأطول تعطي وزنًا أعلى
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestMatch = entry;
      }
    }

    // ٣. إذا لم يوجد تطابق، اختر ردًا عشوائيًا متنوعًا
    if (bestMatch == null || bestScore == 0) {
      bestMatch = _knowledgeBase[_random.nextInt(_knowledgeBase.length)];
    }

    // ٤. بناء الرد بأسلوب النواة (مصفوفة التفكيك الثلاثي)
    final verse = bestMatch!['verse'] as String;
    final ref = bestMatch['ref'] as String;
    final science = bestMatch['science'] as String;
    final attribute = bestMatch['attribute'] as String;
    final insight = bestMatch['insight'] as String;

    final verseJummal = _calculateJummal(verse);
    final energy = _calculateEnergy(queryJummal, verseJummal);

    final abjadResult = AbjadResult(
      major: queryJummal,
      minor: queryJummal % 1000,
      middle: (queryJummal % 1000) ~/ 10,
      element: _getElement(jummalMod19),
      planet: _getPlanet(jummalMod7),
      zodiac: _getZodiac(queryJummal % 12),
      energy: energy,
    );

    // ٥. صياغة الرد النهائي بتنسيق النواة
    final responseText = '''
📖 قال تعالى: "$verse"
   [سورة ${ref.split(':')[0]}، الآية ${ref.split(':')[1]}]

🔬 العلوم المرتبطة: $science
🕌 الصفات الإلهية المتجلية: $attribute

🔢 البصمة الرقمية:
   • جمل السؤال: $queryJummal
   • جمل الآية: $verseJummal
   • المجموع: ${queryJummal + verseJummal}
   • باقي ÷ 19: $jummalMod19 | باقي ÷ 7: $jummalMod7
   • النسبة الذهبية: ${(verseJummal / queryJummal).toStringAsFixed(4)}
   • مستوى الطاقة: ${energy.toStringAsFixed(2)}

💡 للتأمل: $insight''';

    return ChatMessage(
      text: responseText,
      isUser: false,
      surahRef: ref,
      abjadResult: abjadResult,
      energy: energy,
    );
  }

  // ═════════════════════════════════════════════════
  // دوال حساب الجمل والطاقة
  // ═════════════════════════════════════════════════

  int _calculateJummal(String text) {
    // حساب الجمل الكبير
    int jummal = 0;
    for (final char in text.runes) {
      jummal += char % 1000;
    }
    return jummal.abs();
  }

  double _calculateEnergy(int queryJummal, int verseJummal) {
    if (verseJummal == 0) return 0.5;
    final ratio = queryJummal / verseJummal;
    // طاقة متناغمة كلما اقتربت من النسبة الذهبية
    final phi = 1.61803398875;
    return (1.0 - (ratio - phi).abs() / phi).clamp(0.0, 1.0);
  }

  String _getElement(int mod19) {
    const elements = ['نار', 'هواء', 'ماء', 'تراب', 'نور', 'ظلمة', 'سكينة'];
    return elements[mod19 % elements.length];
  }

  String _getPlanet(int mod7) {
    const planets = ['الشمس', 'القمر', 'المريخ', 'عطارد', 'المشتري', 'الزهرة', 'زحل'];
    return planets[mod7];
  }

  String _getZodiac(int mod12) {
    const zodiacs = ['الحمل', 'الثور', 'الجوزاء', 'السرطان', 'الأسد', 'العذراء',
                     'الميزان', 'العقرب', 'القوس', 'الجدي', 'الدلو', 'الحوت'];
    return zodiacs[mod12];
  }
}
