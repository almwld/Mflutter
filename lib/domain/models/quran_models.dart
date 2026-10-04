class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int verseCount;
  final String revelationType;
  final int pageNumber;
  const Surah({required this.number,required this.nameArabic,required this.nameEnglish,required this.verseCount,required this.revelationType,required this.pageNumber});
  String get name => nameArabic;
  String get meaning => '';
  int get versesCount => verseCount;
}

class Juz {
  final int number;
  final String name;
  final int startPage;
  final int endPage;
  const Juz({required this.number, this.name='', this.startPage=1, this.endPage=1});
}
