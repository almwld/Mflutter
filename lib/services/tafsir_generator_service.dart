class TafsirGeneratorService {
  static const Map<String, String> _tafsirDB = {
    'الفاتحة:1': 'افتتح الله كتابه بالبسملة، وهي آية عظيمة تقال في بداية كل أمر ذي بال.',
    'البقرة:255': 'آية الكرسي تتناول توحيد الله وإثبات كماله وقيوميته.',
    'الإخلاص:1': 'سورة الإخلاص تقرر وحدانية الله وتنفي الشريك عنه.',
    'الفلق:1': 'الآية تتضمن الاستعاذة برب الفلق من الشرور.',
    'الناس:1': 'الآية تتضمن الاستعاذة برب الناس وملكهم وإلههم.',
  };

  static String generate(String surahName, int ayahNumber) {
    final result = _tafsirDB['$surahName:$ayahNumber'];
    if (result == null) {
      throw StateError('لا يوجد تفسير محلي موثق لهذه الآية في قاعدة البيانات الحالية.');
    }
    return result;
  }
}
