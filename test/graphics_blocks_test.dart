import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/features/shared/graphics/connected_nodes_path.dart';
import 'package:mudabbir_al_asrar/features/shared/graphics/particle_matrix_block.dart';
import 'package:mudabbir_al_asrar/presentation/templates/adaptive_template_selector.dart';
import 'package:mudabbir_al_asrar/presentation/templates/components/block_registry.dart';
import 'package:mudabbir_al_asrar/presentation/templates/universal_template_renderer.dart';

void main() {
  group('animated graphics block contracts', () {
    test('accepts bounded particle matrix configuration', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'universal_dynamic_canvas',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'particle_matrix_block',
            'title': 'Particle field',
            'data': {
              'count': 4200,
              'columns': 84,
              'active_row': 12,
              'active_nodes': [3, 120, 900],
              'speed': 1.2,
            },
          },
        ],
      });

      expect(schema.envelopeValid, isTrue);
      expect(schema.blocks, hasLength(1));
      expect(schema.validationErrors, isEmpty);
      expect(BlockRegistry.registeredTypes, contains('particle_matrix_block'));
      expect(AdaptiveTemplateSelector.select(
        requestedTemplateId: schema.templateId,
        domain: '',
        query: '',
        blocks: schema.blocks,
      ), 'quantum_mesh_template');
    });

    test('rejects excessive particle counts and invalid active indexes', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'universal_dynamic_canvas',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'particle_matrix_block',
            'count': 9001,
            'active_nodes': [9000],
          },
        ],
      });

      expect(schema.blocks, isEmpty);
      expect(schema.validationErrors, isNotEmpty);
    });

    test('validates connected nodes and edge references', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'universal_dynamic_canvas',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'connected_nodes_path_block',
            'nodes': [
              {'id': 'source', 'label': 'المصدر', 'x': .12, 'y': .5},
              {'id': 'engine', 'label': 'المحرك', 'x': .5, 'y': .5},
              {'id': 'output', 'label': 'المخرجات', 'x': .88, 'y': .5},
            ],
            'edges': [
              {'from': 'source', 'to': 'engine'},
              {'from': 'engine', 'to': 'output'},
            ],
          },
        ],
      });

      expect(schema.blocks, hasLength(1));
      expect(schema.validationErrors, isEmpty);
      expect(BlockRegistry.registeredTypes, contains('connected_nodes_path_block'));
      expect(AdaptiveTemplateSelector.select(
        requestedTemplateId: schema.templateId,
        domain: 'network',
        query: '',
        blocks: schema.blocks,
      ), 'graph_template');
    });

    test('rejects connected edges that reference unknown nodes', () {
      final schema = TemplatePayloadSchema.fromMap({
        'ui_template': 'generic_template',
        'schema_version': 1,
        'blocks': [
          {
            'type': 'connected_nodes_path_block',
            'nodes': [
              {'id': 'a', 'label': 'A'},
              {'id': 'b', 'label': 'B'},
            ],
            'edges': [{'from': 'a', 'to': 'missing'}],
          },
        ],
      });

      expect(schema.blocks, isEmpty);
      expect(schema.validationErrors, isNotEmpty);
    });

    test('graphics widgets expose stable defaults for direct composition', () {
      const particles = ParticleMatrixBlockWidget();
      const graph = ConnectedNodesPathWidget(nodes: [
        {'id': 'a', 'label': 'A'},
        {'id': 'b', 'label': 'B'},
      ]);
      expect(particles.count, 2400);
      expect(particles.columns, 80);
      expect(graph.nodes, hasLength(2));
    });
  });
}
