import '../services/abjad_service.dart';

/// =============================================================================
/// AbjadResult - نتيجة حساب الجمل
/// =============================================================================

class AbjadResult {
  final int kabir;
  final int saghir;
  final int wasat;
  final String element;
  final String planet;
  final String zodiac;
  final String divineName;
  final double frequency;
  final int color;
  final List<LetterResult> letterResults;

  AbjadResult({
    required this.kabir,
    required this.saghir,
    required this.wasat,
    required this.element,
    required this.planet,
    required this.zodiac,
    required this.divineName,
    required this.frequency,
    required this.color,
    required this.letterResults,
  });

  factory AbjadResult.fromJson(Map<String, dynamic> json) {
    return AbjadResult(
      kabir: json['kabir'] as int,
      saghir: json['saghir'] as int,
      wasat: json['wasat'] as int,
      element: json['element'] as String,
      planet: json['planet'] as String,
      zodiac: json['zodiac'] as String,
      divineName: json['divineName'] as String,
      frequency: (json['frequency'] as num).toDouble(),
      color: json['color'] as int,
      letterResults: (json['letterResults'] as List?)
              ?.map((e) => LetterResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kabir': kabir,
      'saghir': saghir,
      'wasat': wasat,
      'element': element,
      'planet': planet,
      'zodiac': zodiac,
      'divineName': divineName,
      'frequency': frequency,
      'color': color,
      'letterResults': letterResults.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'AbjadResult(kabir: $kabir, element: $element, planet: $planet)';
  }
}