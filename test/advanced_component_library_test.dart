import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mudabbir_al_asrar/presentation/templates/components/block_event_bus.dart';
import 'package:mudabbir_al_asrar/presentation/templates/components/block_registry.dart';
import 'package:mudabbir_al_asrar/presentation/templates/components/metric_card_block.dart';
import 'package:mudabbir_al_asrar/presentation/templates/components/spatial_map_block.dart';
import 'package:mudabbir_al_asrar/presentation/templates/universal_template_renderer.dart';

void main() {
  group('Advanced component library', () {
    testWidgets('registry resolves metrics to a real widget', (tester) async {
      final widget = BlockRegistry.buildBlock(
        type: 'metric',
        title: 'عدد النتائج',
        data: const <String, dynamic>{'value': 12, 'unit': 'نتيجة'},
      );

      expect(widget, isA<MetricCardBlock>());
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widget!),
      ));

      expect(find.text('عدد النتائج'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('نتيجة'), findsOneWidget);
    });

    testWidgets('registry resolves coordinate blocks to a bounded painter', (tester) async {
      final widget = BlockRegistry.buildBlock(
        type: 'spatial_map_block',
        title: 'خريطة إحداثية',
        data: const <String, dynamic>{
          'points': [
            {'x': 0.2, 'y': 0.4, 'label': 'A'},
            {'x': 0.8, 'y': 0.6, 'label': 'B'},
          ],
        },
      );

      expect(widget, isA<SpatialMapBlock>());
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: widget!),
      ));

      expect(find.text('خريطة إحداثية'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.textContaining('إسقاط إحداثي ثنائي الأبعاد'), findsOneWidget);
    });

    test('registry refuses to replace a trusted component type', () {
      expect(
        BlockRegistry.register(
          'metric',
          ({required title, required data}) => const SizedBox.shrink(),
        ),
        isFalse,
      );
      expect(BlockRegistry.register('test_component', ({required title, required data}) => const SizedBox.shrink()), isTrue);
      expect(BlockRegistry.register('test_component', ({required title, required data}) => const SizedBox.shrink()), isFalse);
    });

    testWidgets('table selection highlights the matching relation graph node', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: UniversalTemplateRenderer(
            dataPayload: {
              'template_id': 'universal_dynamic_canvas',
              'schema_version': 1,
              'blocks': [
                {
                  'type': 'table',
                  'id': 'table-1',
                  'title': 'العناصر',
                  'columns': ['المعرّف', 'الاسم'],
                  'rows': [['node-7', 'العقدة السابعة']],
                  'row_ids': ['node-7'],
                  'target_block_id': 'graph-1',
                },
                {
                  'type': 'relation_graph_block',
                  'id': 'graph-1',
                  'title': 'شبكة العلاقات',
                  'nodes': [
                    {'id': 'node-7', 'label': 'العقدة السابعة'},
                    {'id': 'node-8', 'label': 'العقدة الثامنة'},
                  ],
                  'edges': [],
                },
              ],
            },
          ),
        ),
      ));

      expect(find.text('العنصر المحدد: node-7'), findsNothing);
      await tester.tap(find.text('العقدة السابعة').first);
      await tester.pumpAndSettle();

      expect(find.text('العنصر المحدد: node-7'), findsOneWidget);
    });

    testWidgets('table selection highlights the matching spatial point', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: UniversalTemplateRenderer(
            dataPayload: {
              'template_id': 'universal_dynamic_canvas',
              'schema_version': 1,
              'blocks': [
                {
                  'type': 'table',
                  'id': 'table-map',
                  'title': 'النقاط',
                  'columns': ['المعرّف'],
                  'rows': [['point-2']],
                  'row_ids': ['point-2'],
                  'target_block_id': 'map-1',
                },
                {
                  'type': 'spatial_map_block',
                  'id': 'map-1',
                  'title': 'الخريطة',
                  'points': [
                    {'id': 'point-2', 'x': 0.7, 'y': 0.3},
                    {'id': 'point-3', 'x': 0.2, 'y': 0.6},
                  ],
                },
              ],
            },
          ),
        ),
      ));

      await tester.tap(find.text('point-2').first);
      await tester.pumpAndSettle();

      expect(find.text('تم تحديد العنصر: point-2'), findsOneWidget);
    });

    test('event bus delivers typed events and closes safely', () async {
      final bus = BlockEventBus();
      final event = BlockEvent(
        type: 'selection_changed',
        sourceBlockId: 'table-1',
        targetBlockId: 'graph-1',
        payload: const <String, Object?>{'node_id': 'node-7'},
      );
      final nextEvent = bus.events.first;
      bus.publish(event);

      expect(await nextEvent, same(event));
      await bus.close();
      expect(bus.isClosed, isTrue);
      bus.publish(event); // closed buses ignore later events
    });
  });
}
