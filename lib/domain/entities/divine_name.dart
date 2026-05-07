import '../../core/constants/app_enums.dart';

/// =============================================================================
/// DivineName - كيان الاسم الإلهي
/// =============================================================================

class DivineName {
  final int id;
  final String arabicName;
  final String transliteration;
  final String meaning;
  final String description;
  final DivineNameType type;
  final int abjadValue;
  final String color;
  final List<String> relatedVerses;
  final List<String> attributes;

  const DivineName({
    required this.id,
    required this.arabicName,
    required this.transliteration,
    required this.meaning,
    required this.description,
    required this.type,
    required this.abjadValue,
    required this.color,
    this.relatedVerses = const [],
    this.attributes = const [],
  });

  /// الاسم المعروض
  String get displayName => arabicName;

  /// رقم الصفة
  String get numberDisplay => '$id';

  /// معلومات الاسم
  String get info =>
      'الاسم: $arabicName\n'
      'المعنى: $meaning\n'
      'القيمة: $abjadValue';

  /// نسخ كـ Map
  Map<String, dynamic> toMap() => {
    'id': id,
    'arabic_name': arabicName,
    'transliteration': transliteration,
    'meaning': meaning,
    'description': description,
    'type': type.index,
    'abjad_value': abjadValue,
    'color': color,
    'related_verses': relatedVerses,
    'attributes': attributes,
  };

  /// إنشاء من Map
  factory DivineName.fromMap(Map<String, dynamic> map) => DivineName(
    id: map['id'] ?? 0,
    arabicName: map['arabic_name'] ?? '',
    transliteration: map['transliteration'] ?? '',
    meaning: map['meaning'] ?? '',
    description: map['description'] ?? '',
    type: DivineNameType.values[map['type'] ?? 0],
    abjadValue: map['abjad_value'] ?? 0,
    color: map['color'] ?? '#FFD700',
    relatedVerses: List<String>.from(map['related_verses'] ?? []),
    attributes: List<String>.from(map['attributes'] ?? []),
  );
}

/// =============================================================================
/// DivineNameCategory - فئة الاسم الإلهي
/// =============================================================================

class DivineNameCategory {
  final String name;
  final List<DivineName> names;
  final int count;

  const DivineNameCategory({
    required this.name,
    required this.names,
    required this.count,
  });

  /// الأسماء في هذه الفئة
  List<DivineName> get divineNames => names;

  /// اسم الفئة المعروض
  String get displayName => name;
}

/// =============================================================================
/// DivineNameStudy - دراسة الاسم الإلهي
/// =============================================================================

class DivineNameStudy {
  final int nameId;
  final DateTime studiedAt;
  final int reflectionScore;
  final String? notes;

  const DivineNameStudy({
    required this.nameId,
    required this.studiedAt,
    required this.reflectionScore,
    this.notes,
  });

  /// هل مستغرق؟
  bool get isDeepStudy => reflectionScore >= 8;
}

/// =============================================================================
/// DivineNameVisualization - تصور الاسم الإلهي
/// =============================================================================

class DivineNameVisualization {
  final int nameId;
  final String color;
  final String shape;
  final String frequency;
  final String energy;

  const DivineNameVisualization({
    required this.nameId,
    required this.color,
    required this.shape,
    required this.frequency,
    required this.energy,
  });

  /// الوصف
  String get description =>
      'اللون: $color\n'
      'الشكل: $shape\n'
      'التكرر: $frequency\n'
      'الطاقة: $energy';
}