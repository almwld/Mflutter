class Ayah {
  final int id; final int surahNumber; final String surahName; final int ayahNumber; final String text;
  final bool isMakki; final int juzNumber; final int pageNumber; final int jummal; final String axisType; final double energyLevel;
  const Ayah({required this.id,required this.surahNumber,required this.surahName,required this.ayahNumber,required this.text,this.isMakki=true,this.juzNumber=1,this.pageNumber=1,this.jummal=0,this.axisType='cosmic',this.energyLevel=0.5});
  String get textWithDiacritics=>text; String get surah=>surahName; int get ayah=>ayahNumber;
  factory Ayah.fromJson(Map<String,dynamic> json)=>Ayah(id:(json['id'] as num?)?.toInt()??0,surahNumber:(json['surah_number'] as num?)?.toInt()??(json['surah'] as num?)?.toInt()??1,surahName:(json['surah_name']??'').toString(),ayahNumber:(json['ayah_number'] as num?)?.toInt()??(json['ayah'] as num?)?.toInt()??1,text:(json['text']??json['ayah_text']??'').toString(),isMakki:(json['is_makki'] as bool?) ?? true,juzNumber:(json['juz_number'] as num?)?.toInt()??(json['juz'] as num?)?.toInt()??1,pageNumber:(json['page_number'] as num?)?.toInt()??(json['page'] as num?)?.toInt()??1,jummal:(json['jummal'] as num?)?.toInt()??0,axisType:(json['axis_type']??'cosmic').toString(),energyLevel:(json['energy_level'] as num?)?.toDouble()??0.5);
}
typedef Verse = Ayah;
export '../models/quran_models.dart';
