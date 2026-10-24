import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/on_device_training_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  List<Map<String, dynamic>> samples(List<String> labels) => labels
      .asMap()
      .entries
      .map((entry) => <String, dynamic>{
            'text': 'عينة تدريب صالحة رقم ${entry.key + 1}',
            'axis_type': entry.value,
          })
      .toList(growable: false);

  test('runtime rejects a single-class dataset even when called directly', () async {
    final service = OnDeviceTrainingService();
    await service.startTraining(
      verses: samples(List<String>.filled(6, 'cosmic')),
      epochs: 1,
    );

    expect(service.status, contains('فئة واحدة'));
    expect(service.status, startsWith('فشل التدريب:'));
  });

  test('runtime rejects underrepresented classes before feature extraction', () async {
    final service = OnDeviceTrainingService();
    await service.startTraining(
      verses: samples([
        'cosmic', 'cosmic', 'cosmic', 'cosmic', 'cosmic', 'tranquil',
      ]),
      epochs: 1,
    );

    expect(service.status, contains('عينتان على الأقل'));
    expect(service.status, startsWith('فشل التدريب:'));
  });
}
