class AbjadResult {
  final int major;
  final int minor;
  final int middle;
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

  // Getters التي تبحث عنها abjad_screen.dart
  int get kabir => major;
  int get saghir => minor;
  int get wasat => middle;

  Map<String, dynamic> toMap() => {
    'major': major, 'minor': minor, 'middle': middle,
    'element': element, 'planet': planet, 'zodiac': zodiac, 'energy': energy,
  };
}
