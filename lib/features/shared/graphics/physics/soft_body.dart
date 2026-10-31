import 'dart:typed_data';

import 'distance_constraint.dart';
import 'volume_constraint.dart';

/// Particle-based deformable body.
///
/// Positions and velocities are stored in world space as packed xyz triples.
/// A zero inverse mass marks a pinned particle. Surface meshes can use their
/// vertices as particles and add constraints along edges/diagonals.
class SoftBody {
  SoftBody({
    required this.positions,
    Float64List? velocities,
    required this.inverseMasses,
    required this.radii,
    this.constraints = const <DistanceConstraint>[],
    this.volumeConstraints = const <TetraVolumeConstraint>[],
    this.linearDamping = 0.04,
    this.name = 'soft-body',
  })  : velocities = velocities ?? Float64List(positions.length),
        previousPositions = Float64List.fromList(positions),
        _particleCount = positions.length ~/ 3 {
    if (positions.isEmpty || positions.length % 3 != 0) {
      throw ArgumentError.value(positions.length, 'positions.length',
          'Must contain one or more xyz triples.');
    }
    if (this.velocities.length != positions.length) {
      throw ArgumentError('velocities must have the same length as positions.');
    }
    if (inverseMasses.length != _particleCount ||
        radii.length != _particleCount) {
      throw ArgumentError('inverseMasses and radii must match particle count.');
    }
    if (positions.any((value) => !value.isFinite) ||
        this.velocities.any((value) => !value.isFinite)) {
      throw ArgumentError('Particle positions and velocities must be finite.');
    }
    if (!linearDamping.isFinite || linearDamping < 0) {
      throw ArgumentError.value(linearDamping, 'linearDamping');
    }
    for (var i = 0; i < _particleCount; i++) {
      if (!inverseMasses[i].isFinite || inverseMasses[i] < 0 ||
          !radii[i].isFinite || radii[i] < 0) {
        throw ArgumentError('Particle mass and radius values must be finite and non-negative.');
      }
    }
    for (final constraint in constraints) {
      if (constraint.a < 0 || constraint.b < 0 ||
          constraint.a >= _particleCount || constraint.b >= _particleCount ||
          !constraint.restLength.isFinite || constraint.restLength < 0 ||
          !constraint.stiffness.isFinite ||
          constraint.stiffness < 0 || constraint.stiffness > 1) {
        throw ArgumentError('A distance constraint references a missing particle.');
      }
    }
    for (final constraint in volumeConstraints) {
      final indices = <int>[
        constraint.a, constraint.b, constraint.c, constraint.d,
      ];
      if (indices.any((index) => index < 0 || index >= _particleCount) ||
          indices.toSet().length != 4 ||
          !constraint.restVolume.isFinite ||
          !constraint.stiffness.isFinite ||
          constraint.stiffness < 0 || constraint.stiffness > 1) {
        throw ArgumentError('A tetrahedral volume constraint is invalid.');
      }
    }
  }

  final Float64List positions;
  final Float64List velocities;
  final Float64List inverseMasses;
  final Float64List radii;
  final Float64List previousPositions;
  final List<DistanceConstraint> constraints;
  final List<TetraVolumeConstraint> volumeConstraints;
  final double linearDamping;
  final String name;
  final int _particleCount;

  int get particleCount => _particleCount;

  void capturePreviousPositions() {
    previousPositions.setAll(0, positions);
  }
}
