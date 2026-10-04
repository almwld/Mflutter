class Science {
  final int id; final String name; final String description; final String icon; final List<String> topics; final int relatedSciencesCount; final List<int> relatedScienceIds; final int level; final bool isActive; final ScienceType type;
  const Science({this.id=0,required this.name,required this.description,this.icon='science',this.topics=const [],this.relatedSciencesCount=0,this.relatedScienceIds=const [],this.level=1,this.isActive=false,this.type=ScienceType.other});
  int get count=>relatedSciencesCount;
  String get info=>'\${description}\\nمواضيع: \${topics.take(3).join(' • ')}';
}
enum ScienceType {letters,numbers,elements,planets,zodiac,names,other}
class Letter {final String value; final int abjadValue; const Letter({this.value='',this.abjadValue=0});}
class Number {final int value; const Number({this.value=0});}
class Element {final String name; const Element({this.name=''});}
class Planet {final String name; const Planet({this.name=''});}
class ZodiacSign {final String name; const ZodiacSign({this.name=''});}
class ScienceConnection {final int sourceId,targetId;final String connectionType;final int strength;const ScienceConnection({required this.sourceId,required this.targetId,required this.connectionType,required this.strength});}
class ScienceProgress {final int scienceId,completedTopics,totalTopics,studyMinutes;final DateTime lastStudied;const ScienceProgress({required this.scienceId,required this.completedTopics,required this.totalTopics,required this.lastStudied,required this.studyMinutes});double get completionPercent=>totalTopics>0?(completedTopics/totalTopics)*100:0;bool get isCompleted=>completedTopics>=totalTopics;String get description=>'\${completedTopics} من \${totalTopics} موضوع\\nوقت الدراسة: \${studyMinutes} دقيقة';}
