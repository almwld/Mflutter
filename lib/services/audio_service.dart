class AudioService {
  static final Map<String, String> _audioUrls = {
    'الفاتحة': 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
    'البقرة': 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/2.mp3',
    'الإخلاص': 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/112.mp3',
  };

  static String getAudioUrl(String surahName) {
    return _audioUrls[surahName] ?? '';
  }

  static List<String> get availableReciters => ['العفاسي', 'السديس', 'ماهر المعيقلي'];
}
