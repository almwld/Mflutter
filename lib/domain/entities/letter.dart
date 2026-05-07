import '../../core/constants/app_enums.dart';

/// =============================================================================
/// Letter - كيان الحرف
/// =============================================================================

class Letter {
  final String char;
  final int kabirValue;
  final int saghirValue;
  final int wasatValue;
  final bool isArabic;

  const Letter({
    required this.char,
    required this.kabirValue,
    required this.saghirValue,
    required this.wasatValue,
    required this.isArabic,
  });

  /// الحرف بالعربية
  String get display => char;

  /// القيمة بالكلمات
  String get kabirFormatted => _formatValue(kabirValue);
  String get saghirFormatted => _formatValue(saghirValue);
  String get wasatFormatted => _formatValue(wasatValue);

  String _formatValue(int value) {
    if (value < 10) return '٠$value';
    if (value < 100) return '${value ~/ 10}٠${value % 10}';
    return value.toString();
  }
}

/// =============================================================================
/// LetterAnalysis - تحليل الحروف
/// =============================================================================

class LetterAnalysis {
  final String text;
  final List<Letter> letters;
  final Map<String, int> frequencyMap;
  final int totalKabir;
  final int totalSaghir;
  final int totalWasat;
  final String dominantElement;
  final String dominantPlanet;
  final List<Letter> mostFrequentLetters;

  const LetterAnalysis({
    required this.text,
    required this.letters,
    required this.frequencyMap,
    required this.totalKabir,
    required this.totalSaghir,
    required this.totalWasat,
    required this.dominantElement,
    required this.dominantPlanet,
    required this.mostFrequentLetters,
  });

  /// عدد الحروف
  int get letterCount => letters.length;

  /// الوصف
  String get description =>
      'النص يحتوي على $letterCount حرف\n'
      'الجمل الكبير: $totalKabir\n'
      'العنصر السائد: $dominantElement\n'
      'الكوكب السائد: $dominantPlanet';
}

/// =============================================================================
/// ElementBalance - توازن العناصر
/// =============================================================================

class ElementBalance {
  final int fireCount;
  final int waterCount;
  final int earthCount;
  final int airCount;
  final int spiritCount;
  final String dominantElement;
  final String description;

  const ElementBalance({
    required this.fireCount,
    required this.waterCount,
    required this.earthCount,
    required this.airCount,
    required this.spiritCount,
    required this.dominantElement,
    required this.description,
  });

  /// النسب المئوية
  double get firePercent => _calculatePercent(fireCount);
  double get waterPercent => _calculatePercent(waterCount);
  double get earthPercent => _calculatePercent(earthCount);
  double get airPercent => _calculatePercent(airCount);
  double get spiritPercent => _calculatePercent(spiritCount);

  int get total => fireCount + waterCount + earthCount + airCount + spiritCount;

  double _calculatePercent(int count) {
    if (total == 0) return 0;
    return (count / total) * 100;
  }
}

/// =============================================================================
/// PlanetaryInfluence - تأثير الكواكب
/// =============================================================================

class PlanetaryInfluence {
  final PlanetType primaryPlanet;
  final PlanetType secondaryPlanet;
  final int primaryStrength;
  final int secondaryStrength;
  final String description;

  const PlanetaryInfluence({
    required this.primaryPlanet,
    required this.secondaryPlanet,
    required this.primaryStrength,
    required this.secondaryStrength,
    required this.description,
  });

  /// اسم الكوكب الرئيسي
  String get primaryPlanetName => _getPlanetName(primaryPlanet);

  /// اسم الكوكب الثانوي
  String get secondaryPlanetName => _getPlanetName(secondaryPlanet);

  String _getPlanetName(PlanetType planet) {
    switch (planet) {
      case PlanetType.sun:
        return 'الشمس';
      case PlanetType.moon:
        return 'القمر';
      case PlanetType.mars:
        return 'المريخ';
      case PlanetType.mercury:
        return 'عطارد';
      case PlanetType.venus:
        return 'الزهرة';
      case PlanetType.jupiter:
        return 'المشتري';
      case PlanetType.saturn:
        return 'زُحل';
    }
  }
}

/// =============================================================================
/// DivineResonance - رنين الاسم الإلهي
/// =============================================================================

class DivineResonance {
  final int rank;
  final String name;
  final int value;
  final String meaning;
  final String description;
  final String visualization;

  const DivineResonance({
    required this.rank,
    required this.name,
    required this.value,
    required this.meaning,
    required this.description,
    required this.visualization,
  });

  /// الصفة بالشكل
  String get displayName => name;
}