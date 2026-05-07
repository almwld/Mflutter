class AbjadResult {
  final int kabir;
  final int saghir;
  final int wasat;
  final String element;
  final String planet;
  final String zodiac;
  final String divineName;

  const AbjadResult({
    required this.kabir,
    required this.saghir,
    required this.wasat,
    this.element = '',
    this.planet = '',
    this.zodiac = '',
    this.divineName = '',
  });

  factory AbjadResult.fromText(String text) {
    int j = 0;
    for (int i = 0; i < text.length; i++) {
      j += text.codeUnitAt(i);
    }
    return AbjadResult(kabir: j, saghir: j % 10, wasat: j % 100);
  }
}
