class CelestialSyncService {
  static String getCurrentCelestialPhase() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 6) return 'الفجر - وقت البدايات والتجلي';
    if (hour >= 6 && hour < 8) return 'الشروق - وقت النور والانطلاق';
    if (hour >= 12 && hour < 14) return 'الزوال - وقت التأمل والسكينة';
    if (hour >= 17 && hour < 19) return 'الغروب - وقت التدبر والختام';
    if (hour >= 21 || hour < 3) return 'الليل - وقت المناجاة والأسرار';
    return 'النهار - وقت العمل والآفاق';
  }

  static String getVerseForPhase() {
    final phase = getCurrentCelestialPhase();
    if (phase.contains('فجر')) return 'وَالصُّبْحِ إِذَا تَنَفَّسَ (التكوير:18)';
    if (phase.contains('ليل')) return 'وَاللَّيْلِ إِذَا سَجَى (الضحى:2)';
    if (phase.contains('شروق')) return 'وَالشَّمْسِ وَضُحَاهَا (الشمس:1)';
    if (phase.contains('غروب')) return 'فَلَا أُقْسِمُ بِالشَّفَقِ (الانشقاق:16)';
    return 'وَالنَّهَارِ إِذَا جَلَّاهَا (الشمس:3)';
  }
}
