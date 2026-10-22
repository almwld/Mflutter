import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Optional large OCR/vision/checkpoint files are kept outside the APK.
/// Files are imported through Android's document picker into app-private storage.
class ExternalAssetService {
  ExternalAssetService._();

  static final ExternalAssetService instance = ExternalAssetService._();
  static const String directoryName = 'mudabbir_external_assets';

  Future<Directory> get externalRoot async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/$directoryName');
    await directory.create(recursive: true);
    return directory;
  }

  /// Maps a logical Flutter asset path to its optional external override.
  Future<File> fileForAsset(String assetPath) async {
    final normalized = _normalizeAssetPath(assetPath);
    final root = await externalRoot;
    return File('${root.path}/$normalized');
  }

  static String _normalizeAssetPath(String path) {
    final normalized = path.replaceAll('\\\\', '/').replaceFirst(RegExp(r'^/+'), '');
    if (!normalized.startsWith('assets/') ||
        normalized.split('/').any((part) => part == '..' || part.isEmpty)) {
      throw ArgumentError.value(path, 'assetPath', 'Expected a safe path below assets/.');
    }
    return normalized;
  }

  /// Loads an external override first, then falls back to the bundled asset.
  Future<String> loadString(String assetPath) async {
    final file = await fileForAsset(assetPath);
    if (await file.exists()) return file.readAsString();
    return rootBundle.loadString(assetPath);
  }

  /// Loads an external override first, then falls back to the bundled asset.
  Future<ByteData> loadBytes(String assetPath) async {
    final file = await fileForAsset(assetPath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      return ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes);
    }
    return rootBundle.load(assetPath);
  }

  Future<File?> findImportedFile(String fileName) async {
    final root = await externalRoot;
    final candidates = <File>[
      File('${root.path}/tessdata/$fileName'),
      File('${root.path}/assets/models/$fileName'),
      File('${root.path}/assets/$fileName'),
    ];
    for (final candidate in candidates) {
      if (await candidate.exists()) return candidate;
    }
    return null;
  }

  /// Imports optional files selected by the user; no broad storage permission is
  /// needed, and the files are copied into app-private storage.
  Future<List<String>> pickAndImportOptionalAssets() async {
    final selection = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
      withData: false,
    );
    if (selection == null) return const <String>[];

    final root = await externalRoot;
    final imported = <String>[];
    for (final selected in selection.files) {
      final sourcePath = selected.path;
      if (sourcePath == null || sourcePath.isEmpty) continue;
      final name = selected.name.split('/').last.split('\\\\').last;
      if (name.isEmpty || name == '.' || name == '..') continue;

      final lower = name.toLowerCase();
      final relative = lower.endsWith('.traineddata')
          ? 'tessdata/$name'
          : lower.endsWith('.task')
              ? 'assets/$name'
              : (lower.endsWith('.tflite') ||
                      lower == 'mudabbir_weights.json' ||
                      lower == 'training_history.json')
                  ? 'assets/models/$name'
                  : 'assets/$name';
      final destination = File('${root.path}/$relative');
      await destination.parent.create(recursive: true);
      await File(sourcePath).copy(destination.path);
      imported.add(relative);
    }
    return List<String>.unmodifiable(imported);
  }

  /// Canonical destination used for the common optional model files.
  static String destinationForFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.traineddata')) return 'tessdata/$name';
    if (lower.endsWith('.task')) return 'assets/$name';
    if (lower.endsWith('.tflite') ||
        lower == 'mudabbir_weights.json' ||
        lower == 'training_history.json') {
      return 'assets/models/$name';
    }
    return 'assets/$name';
  }
}
