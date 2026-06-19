class GeospatialInsightService {
  static double _altitude = 0;
  static String _topography = 'plains';

  static double get altitude => _altitude;
  static String get topography => _topography;

  static void updateLocation(double alt) {
    _altitude = alt;
    if (alt > 1000) _topography = 'mountains';
    else if (alt < 50) _topography = 'coastal';
    else _topography = 'plains';
  }

  static String getVerseForTopography() {
    switch (_topography) {
      case 'mountains': return 'وَالْجِبَالَ أَوْتَادًا (النبأ:7)';
      case 'coastal': return 'مَرَجَ الْبَحْرَيْنِ يَلْتَقِيَانِ (الرحمن:19)';
      default: return 'وَالْأَرْضَ مَدَدْنَاهَا (الحجر:19)';
    }
  }
}
