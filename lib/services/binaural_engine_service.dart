class BinauralEngineService {
  static bool _playing = false;
  static double _frequency = 7.83; // Schumann Resonance

  static bool get playing => _playing;

  static void playTranquility() { _playing = true; _frequency = 7.83; }
  static void playFocus() { _playing = true; _frequency = 14.0; }
  static void playDeepMeditation() { _playing = true; _frequency = 4.0; }
  static void stop() { _playing = false; }

  static String get currentMode => _frequency <= 8 ? 'سكينة عميقة' : _frequency <= 12 ? 'تأمل' : 'تركيز';
}
