import 'dart:math';

class QuantumEntanglementService {
  static final Map<String, List<String>> _entangledVerses = {
    'نور': ['اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ (النور:35)', 'وَجَعَلْنَا سِرَاجًا وَهَّاجًا (النبأ:13)'],
    'خلق': ['إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ (البقرة:164)', 'لَقَدْ خَلَقْنَا الْإِنسَانَ فِي أَحْسَنِ تَقْوِيمٍ (التين:4)'],
    'سماء': ['وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ (الذاريات:47)', 'وَالسَّمَاءِ وَالطَّارِقِ (الطارق:1)'],
    'أرض': ['وَالْأَرْضَ مَدَدْنَاهَا (الحجر:19)', 'وَالْأَرْضَ بَعْدَ ذَٰلِكَ دَحَاهَا (النازعات:30)'],
  };

  static List<String> findEntangled(String keyword) {
    for (final entry in _entangledVerses.entries) {
      if (entry.key.contains(keyword) || keyword.contains(entry.key)) {
        return entry.value;
      }
    }
    return ['﴿أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ﴾ (النساء:82)'];
  }

  static String getRandomVerse() {
    final all = _entangledVerses.values.expand((v) => v).toList();
    return all[Random().nextInt(all.length)];
  }
}
