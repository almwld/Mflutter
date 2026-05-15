class ARLensService {
  static final Map<String, Map<String, String>> _natureDB = {
    'mountain': {'verse': 'وَالْجِبَالَ أَوْتَادًا (النبأ:7)', 'science': 'علم الجيولوجيا', 'attribute': 'المتين'},
    'sea': {'verse': 'مَرَجَ الْبَحْرَيْنِ يَلْتَقِيَانِ (الرحمن:19)', 'science': 'علم البحار', 'attribute': 'اللطيف'},
    'sky': {'verse': 'وَالسَّمَاءَ بَنَيْنَاهَا بِأَيْدٍ (الذاريات:47)', 'science': 'علم الفلك', 'attribute': 'القوي'},
    'star': {'verse': 'وَالنَّجْمِ إِذَا هَوَى (النجم:1)', 'science': 'علم الفلك', 'attribute': 'العليم'},
    'tree': {'verse': 'وَشَجَرَةً تَخْرُجُ مِن طُورِ سَيْنَاءَ (المؤمنون:20)', 'science': 'علم النبات', 'attribute': 'الخالق'},
  };

  static Map<String, String>? detectObject(String label) {
    return _natureDB[label.toLowerCase()];
  }
}
