import 'package:flutter/widgets.dart';

import 'metric_card_block.dart';
import 'spatial_map_block.dart';
import 'star_tracker_block.dart';
import '../../../features/shared/graphics/particle_matrix_block.dart';
import '../../../features/shared/graphics/connected_nodes_path.dart';
import '../../../features/shared/graphics/physics_sandbox_block.dart';

typedef BlockBuilder = Widget Function({
  required String title,
  required Map<String, dynamic> data,
});

/// Allowlisted atomic component factory. Registration is explicit and duplicate
/// identifiers are rejected so a runtime payload cannot replace a trusted block.
abstract final class BlockRegistry {
  static final Map<String, BlockBuilder> _registry = <String, BlockBuilder>{
    'metric': _buildMetric,
    'metric_card': _buildMetric,
    'spatial_map_block': _buildSpatial,
    'star_map_block': _buildSpatial,
    'vector_space_block': _buildSpatial,
    'quantum_particle_block': _buildSpatial,
    'star_tracker_block': _buildStarTracker,
    'particle_matrix_block': _buildParticleMatrix,
    'connected_nodes_path_block': _buildConnectedNodes,
    'physics_sandbox_block': _buildPhysicsSandbox,
  };

  static Set<String> get registeredTypes =>
      Set<String>.unmodifiable(_registry.keys);

  static bool register(String type, BlockBuilder builder) {
    final normalized = type.trim();
    if (normalized.isEmpty || _registry.containsKey(normalized)) return false;
    _registry[normalized] = builder;
    return true;
  }

  static Widget? buildBlock({
    required String type,
    required String title,
    required Map<String, dynamic> data,
  }) {
    final builder = _registry[type];
    if (builder == null) return null;
    return builder(title: title, data: data);
  }

  static Widget _buildMetric({
    required String title,
    required Map<String, dynamic> data,
  }) =>
      MetricCardBlock(title: title, data: data);

  static Widget _buildStarTracker({
    required String title,
    required Map<String, dynamic> data,
  }) =>
      StarTrackerBlock(title: title, data: data);


  static Widget _buildParticleMatrix({
    required String title,
    required Map<String, dynamic> data,
  }) {
    final rawNodes = data['active_nodes'];
    final activeNodes = rawNodes is List
        ? rawNodes.whereType<int>().toList(growable: false)
        : const <int>[];
    return _BlockCard(
      title: title,
      child: ParticleMatrixBlockWidget(
        count: data['count'] is int ? data['count'] as int : 2400,
        columns: data['columns'] is int ? data['columns'] as int : 80,
        activeRow: data['active_row'] is int ? data['active_row'] as int : null,
        activeNodes: activeNodes,
        speed: data['speed'] is num ? (data['speed'] as num).toDouble() : 1,
        height: data['height'] is num ? (data['height'] as num).toDouble() : 260,
        blockId: data['_canvas_block_id'] is String
            ? data['_canvas_block_id'] as String
            : 'particle-matrix',
        targetBlockId: data['target_block_id'] is String
            ? data['target_block_id'] as String
            : null,
        nodeIds: data['node_ids'] is List
            ? (data['node_ids'] as List).whereType<String>().toList(growable: false)
            : const <String>[],
      ),
    );
  }

  static Widget _buildConnectedNodes({
    required String title,
    required Map<String, dynamic> data,
  }) {
    final rawNodes = data['nodes'];
    final rawEdges = data['edges'];
    final nodes = rawNodes is List
        ? rawNodes.whereType<Map>().map((node) => Map<String, dynamic>.from(node)).toList(growable: false)
        : const <Map<String, dynamic>>[];
    final edges = rawEdges is List
        ? rawEdges.whereType<Map>().map((edge) => Map<String, dynamic>.from(edge)).toList(growable: false)
        : const <Map<String, dynamic>>[];
    return _BlockCard(
      title: title,
      child: ConnectedNodesPathWidget(
        nodes: nodes,
        edges: edges,
        height: data['height'] is num ? (data['height'] as num).toDouble() : 280,
        blockId: data['_canvas_block_id'] is String
            ? data['_canvas_block_id'] as String
            : 'connected-nodes',
        targetBlockId: data['target_block_id'] is String
            ? data['target_block_id'] as String
            : null,
      ),
    );
  }

  static Widget _buildPhysicsSandbox({
    required String title,
    required Map<String, dynamic> data,
  }) =>
      _BlockCard(
        title: title,
        child: PhysicsSandboxBlockWidget(
          height: data['height'] is num
              ? (data['height'] as num).toDouble()
              : 300,
        ),
      );

  static Widget _buildSpatial({
    required String title,
    required Map<String, dynamic> data,
  }) =>
      SpatialMapBlock(title: title, data: data);
}


class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF334155)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title.isNotEmpty) ...[
          Text(title, textDirection: TextDirection.rtl,
            style: const TextStyle(color: Color(0xFFE2E8F0), fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
        ],
        child,
      ],
    ),
  );
}
