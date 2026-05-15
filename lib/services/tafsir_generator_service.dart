class TafsirGeneratorService {
  static final Map<String, String> _tafsirDB = {
    'الفاتحة:1': 'افتتح الله كتابه بالبسملة، وهي آية عظيمة تقال في بداية كل أمر ذي بال.',
    'البقرة:255': 'آية الكرسي أعظم آية في القرآن. فيها توحيد خالص وإثبات صفات الكمال لله.',
    'الإخلاص:1': 'سورة الإخلاص تعدل ثلث القرآن. تثبت وحدانية الله وتنفي الشركاء.',
    'الفلق:1': 'تعوذ بالله رب الفلق وهو الصبح، من شرور المخلوقات كلها.',
    'الناس:1': 'تعوذ بالله رب الناس ومالكهم وإلههم من شر الوسواس.',
  };

  static String generate(String surahName, int ayahNumber) {
    final key = '$surahName:$ayahNumber';
    if (_tafsirDB.containsKey(key)) return _tafsirDB[key]!;
    return _generateGeneric(surahName, ayahNumber);
  }

  static String _generateGeneric(String surah, int ayah) {
    final templates = [
      'تأمل في هذه الآية الكريمة من سورة $surah، فالآية رقم $ayah تحمل معاني عميقة تستحق التدبر.',
      'آية عظيمة من سورة $surah، الآية $ayah، تدعوك للتأمل في بديع خلق الله وإحكام صنعه.',
      'في هذه الآية من سورة $surah ($ayah) إشارات كونية وعلمية تحتاج إلى تأمل وبحث.',
    ];
    return templates[DateTime.now().millisecond % templates.length];
  }
}
