import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/labeled_training_dataset_service.dart';

void main() {
  List<Map<String, dynamic>> rowsWithLabels(
    List<String> labels,
  ) => labels
      .asMap()
      .entries
      .map((entry) => <String, dynamic>{
            'text': 'نص تدريبي صالح رقم ${entry.key + 1}',
            'axis_type': entry.value,
          })
      .toList();

  group('LabeledTrainingDatasetService.parseJsonDataset', () {
    test('accepts a sufficiently sized dataset with multiple represented labels', () {
      final source = jsonEncode(rowsWithLabels([
        'cosmic', 'cosmic', 'cosmic',
        'tranquil', 'tranquil', 'tranquil',
      ]));

      final parsed = LabeledTrainingDatasetService.parseJsonDataset(source);

      expect(parsed, hasLength(6));
      expect(parsed.map((row) => row['axis_type']).toSet(),
          containsAll(<String>{'cosmic', 'tranquil'}));
      expect(() => parsed.add(<String, dynamic>{}), throwsUnsupportedError);
    });

    test('rejects the single-class Quran-default-label failure mode', () {
      final source = jsonEncode(rowsWithLabels(List<String>.filled(6, 'cosmic')));

      expect(
        () => LabeledTrainingDatasetService.parseJsonDataset(source),
        throwsA(isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('فئة واحدة'),
        )),
      );
    });

    test('rejects classes represented by only one sample', () {
      final source = jsonEncode(rowsWithLabels([
        'cosmic', 'cosmic', 'cosmic', 'cosmic', 'cosmic', 'tranquil',
      ]));

      expect(
        () => LabeledTrainingDatasetService.parseJsonDataset(source),
        throwsA(isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('عينتين على الأقل'),
        )),
      );
    });

    test('rejects unsupported labels instead of silently mapping them', () {
      final source = jsonEncode(rowsWithLabels([
        'cosmic', 'cosmic', 'cosmic', 'unknown', 'tranquil', 'tranquil',
      ]));

      expect(
        () => LabeledTrainingDatasetService.parseJsonDataset(source),
        throwsA(isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('غير مدعوم'),
        )),
      );
    });

    test('rejects too few samples and non-list JSON', () {
      expect(
        () => LabeledTrainingDatasetService.parseJsonDataset(
          jsonEncode(rowsWithLabels(['cosmic', 'cosmic', 'tranquil'])),
        ),
        throwsFormatException,
      );
      expect(
        () => LabeledTrainingDatasetService.parseJsonDataset('{"text":"not a list"}'),
        throwsFormatException,
      );
    });

    test('rejects blank text records', () {
      final rows = rowsWithLabels([
        'cosmic', 'cosmic', 'cosmic', 'tranquil', 'tranquil', 'tranquil',
      ]);
      rows[0]['text'] = '   ';
      expect(
        () => LabeledTrainingDatasetService.parseJsonDataset(jsonEncode(rows)),
        throwsFormatException,
      );
    });
  });
}
