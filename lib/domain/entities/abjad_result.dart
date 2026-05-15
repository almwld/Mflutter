class AbjadResult {
  final int major;   // جمل كبير
  final int minor;   // جمل صغير
  final int middle;  // جمل وسط
  final String element;
  final String planet;
  final String zodiac;
  final double energy;

  const AbjadResult({
    required this.major,
    required this.minor,
    required this.middle,
    this.element = 'نار',
    this.planet = 'الشمس',
    this.zodiac = 'الحمل',
    this.energy = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'major': major,
    'minor': minor,
    'middle': middle,
    'element': element,
    'planet': planet,
    'zodiac': zodiac,
    'energy': energy,
  };

  @override
  String toString() => 'جمل كبير: $major | صغير: $minor | وسط: $middle';
}
