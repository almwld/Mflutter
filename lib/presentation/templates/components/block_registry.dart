import 'package:flutter/widgets.dart';

import 'metric_card_block.dart';
import 'spatial_map_block.dart';
import 'star_tracker_block.dart';

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

  static Widget _buildSpatial({
    required String title,
    required Map<String, dynamic> data,
  }) =>
      SpatialMapBlock(title: title, data: data);
}
