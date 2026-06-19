import 'dart:math';

class VocalCryptoService {
  static bool _isUnlocked = false;
  static List<double>? _storedSignature;

  static bool get isUnlocked => _isUnlocked;

  static void registerSignature(List<double> samples) {
    _storedSignature = samples;
    _isUnlocked = true;
  }

  static bool verifySignature(List<double> samples) {
    if (_storedSignature == null || samples.length != _storedSignature!.length) return false;
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < samples.length; i++) {
      dot += samples[i] * _storedSignature![i];
      normA += pow(samples[i], 2);
      normB += pow(_storedSignature![i], 2);
    }
    if (normA == 0 || normB == 0) return false;
    _isUnlocked = (dot / (sqrt(normA) * sqrt(normB))) > 0.95;
    return _isUnlocked;
  }
}
