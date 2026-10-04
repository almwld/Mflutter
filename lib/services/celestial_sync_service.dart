import 'dart:math';

class CelestialSyncService {
  static double solarElevation(DateTime time, {double latitude=15.35}) {
    final day = time.difference(DateTime(time.year,1,1)).inDays + 1;
    final declination = 23.44 * sin(2*pi*(day-81)/365.0);
    final hour = time.hour + time.minute/60.0 + time.second/3600.0;
    final hourAngle = 15.0 * (hour - 12.0);
    final lat = latitude * pi / 180.0;
    final dec = declination * pi / 180.0;
    final h = hourAngle * pi / 180.0;
    return 180/pi * asin(sin(lat)*sin(dec) + cos(lat)*cos(dec)*cos(h));
  }

  static String getCurrentCelestialPhase() {
    final elevation = solarElevation(DateTime.now());
    if (elevation < -6) return 'ليل فلكي';
    if (elevation < 0) return 'شفق';
    if (elevation < 10) return 'شروق/غروب';
    if (elevation > 45) return 'نهار مرتفع';
    return 'نهار';
  }

  static String getVerseForPhase() {
    switch (getCurrentCelestialPhase()) {
      case 'ليل فلكي': return 'وَاللَّيْلِ إِذَا يَغْشَى (الليل:1)';
      case 'شفق': return 'فَلَا أُقْسِمُ بِالشَّفَقِ (الانشقاق:16)';
      case 'شروق/غروب': return 'وَالشَّمْسِ وَضُحَاهَا (الشمس:1)';
      default: return 'وَالنَّهَارِ إِذَا جَلَّاهَا (الشمس:3)';
    }
  }
}
