class AbjadResult {
  final int major, minor, middle;
  final String element, planet, zodiac, divineName;
  final double energy, frequency;
  final int color;
  final List<LetterResult> letterResults;
  const AbjadResult({required this.major,required this.minor,required this.middle,this.element='نار',this.planet='الشمس',this.zodiac='الحمل',this.divineName='الله',this.energy=0.0,this.frequency=0.0,this.color=0xFF1A237E,this.letterResults=const []});
  int get kabir=>major; int get saghir=>minor; int get wasat=>middle;
  List<LetterResult> get letterValues => letterResults;
  int get kabirValue => major;
  int get saghirValue => minor;
  int get wasatValue => middle;
  Map<String,dynamic> toMap()=>{'major':major,'minor':minor,'middle':middle,'element':element,'planet':planet,'zodiac':zodiac,'divineName':divineName,'energy':energy,'frequency':frequency,'color':color,'letterResults':letterResults.map((e)=>{'letter':e.letter,'value':e.value}).toList()};
}
class LetterResult {final String letter; final int value; const LetterResult({required this.letter,required this.value});}