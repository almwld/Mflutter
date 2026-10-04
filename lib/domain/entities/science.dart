class Science {
  final int id; final String name; final String description; final String icon; final List<String> topics; final int relatedSciencesCount; final List<int> relatedScienceIds; final int level; final bool isActive;
  const Science({required this.id,required this.name,required this.description,required this.icon,this.topics=const [],this.relatedSciencesCount=0,this.relatedScienceIds=const [],this.level=1,this.isActive=false});
  int get count=>relatedSciencesCount;
  String get info=>'\$description\\nمواضيع: \$topics.take(3).join(' • ')';
  ScienceType get type { switch(icon.toLowerCase()){case 'abc':return ScienceType.letters;case 'numbers':return ScienceType.numbers;case 'science':return ScienceType.elements;case 'public':return ScienceType.planets;case 'star':return ScienceType.zodiac;case 'badge':return ScienceType.names;default:return ScienceType.other;} }
}
enum ScienceType {letters,numbers,elements,planets,zodiac,names,other}
class ScienceConnection {final int sourceId,targetId;final String connectionType;final int strength;const ScienceConnection({required this.sourceId,required this.targetId,required this.connectionType,required this.strength});}
class ScienceProgress {final int scienceId,completedTopics,totalTopics,studyMinutes;final DateTime lastStudied;const ScienceProgress({required this.scienceId,required this.completedTopics,required this.totalTopics,required this.lastStudied,required this.studyMinutes});double get completionPercent=>totalTopics>0?(completedTopics/totalTopics)*100:0;bool get isCompleted=>completedTopics>=totalTopics;String get description=>'\$completedTopics من \$totalTopics موضوع\\nوقت الدراسة: \$studyMinutes دقيقة';}