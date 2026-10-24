import 'dart:io';

import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'quran_loader_service.dart';
import 'external_asset_service.dart';

/// Offline-first smart-lens services. Arabic OCR and Quran matching run locally
/// after the Arabic Tesseract model has been downloaded once.
class SmartLensService {
  SmartLensService._();
  static final SmartLensService instance = SmartLensService._();
  static Future<void>? _arabicModelDownload;
  static Future<List<_IndexedLensAyah>>? _indexedAyahs;

  Future<void> _ensureArabicOcrModel() async {
    final path = await FlutterTesseractOcr.getTessdataPath();
    final model = File('$path/ara.traineddata');
    if (await model.exists() && await model.length() > 1000000) return;

    // Optional model may be imported manually instead of downloaded at runtime.
    final imported = await ExternalAssetService.instance.findImportedFile('ara.traineddata');
    if (imported != null && await imported.length() > 1000000) {
      await model.parent.create(recursive: true);
      await imported.copy(model.path);
      return;
    }

    final pending = _arabicModelDownload;
    if (pending != null) {
      await pending;
      return;
    }
    final download = _downloadArabicModel(model);
    _arabicModelDownload = download;
    try {
      await download;
    } catch (_) {
      _arabicModelDownload = null;
      rethrow;
    }
  }

  Future<void> _downloadArabicModel(File destination) async {
    await destination.parent.create(recursive: true);
    final temporary = File('${destination.path}.download');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 25);
    try {
      final request = await client
          .getUrl(Uri.parse('https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/main/ara.traineddata'))
          .timeout(const Duration(seconds: 30));
      final response = await request.close().timeout(const Duration(seconds: 60));
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('تعذر تنزيل نموذج OCR العربي (HTTP ${response.statusCode}).', uri: request.uri);
      }
      final sink = temporary.openWrite();
      await response.pipe(sink).timeout(const Duration(minutes: 2));
      if (!await temporary.exists() || await temporary.length() < 1000000) {
        throw const FormatException('ملف نموذج OCR العربي غير مكتمل.');
      }
      if (await destination.exists()) await destination.delete();
      await temporary.rename(destination.path);
    } finally {
      client.close(force: true);
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<String> extractArabicText(String imagePath) async {
    await _ensureArabicOcrModel();
    final text = await FlutterTesseractOcr.extractText(
      imagePath,
      language: 'ara',
      args: const <String, String>{'psm': '6', 'preserve_interword_spaces': '1'},
    );
    return text.trim();
  }

  /// Heuristic matching against the canonical bundled Hafs corpus. Never
  /// generates or rewrites Quran text; results are suggestions for verification.
  Future<List<_IndexedLensAyah>> _loadIndexedAyahs() {
    final cached = _indexedAyahs;
    if (cached != null) return cached;

    late final Future<List<_IndexedLensAyah>> guarded;
    guarded = _buildIndexedAyahs().catchError((Object error, StackTrace stackTrace) {
      // A transient asset-load failure must not poison all later OCR scans.
      if (identical(_indexedAyahs, guarded)) _indexedAyahs = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
    _indexedAyahs = guarded;
    return guarded;
  }

  Future<List<_IndexedLensAyah>> _buildIndexedAyahs() async {
    final ayahs = await QuranLoaderService.loadAllAyahs();
    return List<_IndexedLensAyah>.unmodifiable(ayahs.map((ayah) {
      final normalized = normalizeArabic(ayah.text);
      final tokens = normalized.split(' ').where((word) => word.length > 1).toSet();
      return _IndexedLensAyah(
        surahName: ayah.surahName,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        canonicalText: ayah.text,
        normalizedText: normalized,
        tokens: Set<String>.unmodifiable(tokens),
      );
    }));
  }

  Future<List<QuranLensMatch>> matchQuranText(String recognizedText, {int limit = 3}) async {
    if (limit <= 0) return const [];
    final query = normalizeArabic(recognizedText);
    final queryTokens = query.split(' ').where((word) => word.length > 1).toSet();
    if (queryTokens.length < 3) return const [];

    // The 6,236-ayah corpus is normalized and tokenized once per process,
    // rather than re-normalizing every verse for every camera/OCR result.
    final ayahs = await _loadIndexedAyahs();
    final matches = <QuranLensMatch>[];
    for (final ayah in ayahs) {
      final verseTokens = ayah.tokens;
      if (verseTokens.isEmpty) continue;
      final overlap = queryTokens.intersection(verseTokens).length;
      final coverage = overlap / queryTokens.length;
      final dice = (2 * overlap) / (queryTokens.length + verseTokens.length);
      final contains = query.length >= 12 &&
          (ayah.normalizedText.contains(query) || query.contains(ayah.normalizedText));
      final score = contains ? 1.0 : (dice * 0.65 + coverage * 0.35);
      if (score >= 0.30) {
        matches.add(QuranLensMatch(
          surahName: ayah.surahName,
          surahNumber: ayah.surahNumber,
          ayahNumber: ayah.ayahNumber,
          canonicalText: ayah.canonicalText,
          score: score.clamp(0.0, 1.0).toDouble(),
        ));
      }
    }
    matches.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final bySurah = a.surahNumber.compareTo(b.surahNumber);
      return bySurah != 0 ? bySurah : a.ayahNumber.compareTo(b.ayahNumber);
    });
    return matches.take(limit).toList(growable: false);
  }

  Future<List<ObjectLensLabel>> analyzeObjects(String imagePath) async {
    final labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.45));
    try {
      final labels = await labeler.processImage(InputImage.fromFilePath(imagePath));
      return labels.map((label) => ObjectLensLabel(
        label: label.label,
        confidence: label.confidence,
      )).toList(growable: false);
    } finally {
      await labeler.close();
    }
  }

  /// Downloads Arabic and English translation models on first use, then
  /// translates locally on device.
  Future<String> translateArabicToEnglish(String text) async {
    if (text.trim().isEmpty) throw ArgumentError('لا يوجد نص لترجمته.');
    final manager = OnDeviceTranslatorModelManager();
    const source = TranslateLanguage.arabic;
    const target = TranslateLanguage.english;
    for (final language in <TranslateLanguage>[source, target]) {
      if (!await manager.isModelDownloaded(language.bcpCode)) {
        await manager.downloadModel(language.bcpCode, isWifiRequired: false);
      }
    }
    final translator = OnDeviceTranslator(sourceLanguage: source, targetLanguage: target);
    try {
      return await translator.translateText(text);
    } finally {
      await translator.close();
    }
  }

  static String normalizeArabic(String value) => value
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
      .replaceAll(RegExp(r'[إأآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[^\u0600-\u06FF0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
}

class _IndexedLensAyah {
  const _IndexedLensAyah({
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.canonicalText,
    required this.normalizedText,
    required this.tokens,
  });

  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final String canonicalText;
  final String normalizedText;
  final Set<String> tokens;
}

class QuranLensMatch {
  const QuranLensMatch({
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.canonicalText,
    required this.score,
  });
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final String canonicalText;
  final double score;
  String get reference => 'سورة $surahName، الآية $ayahNumber';
}

class ObjectLensLabel {
  const ObjectLensLabel({required this.label, required this.confidence});
  final String label;
  final double confidence;
}
