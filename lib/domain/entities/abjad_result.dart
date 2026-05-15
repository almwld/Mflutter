class AbjadResult {
  final int kabir;
  final int saghir;
  final int wasat;

  const AbjadResult({required this.kabir, required this.saghir, required this.wasat});

  factory AbjadResult.fromText(String text) {
    int sum = 0;
    for (int i = 0; i < text.length; i++) {
      sum += text.codeUnitAt(i);
    }
    return AbjadResult(kabir: sum, saghir: sum % 10, wasat: sum % 100);
  }
}
