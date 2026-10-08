import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'external_model_service.dart';

class LocalModelSelectionService {
  static const _pathKey = 'local_model.selected_path';
  static const _nameKey = 'local_model.selected_name';

  static Future<String?> pickAndLoadTflite() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['tflite'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return null;
    final path = result.files.single.path!;
    final name = await ExternalModelService().importAndLoadModel(path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pathKey, path);
    await prefs.setString(_nameKey, name);
    return name;
  }

  static Future<String?> selectedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }
}
