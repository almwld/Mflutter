import 'dart:math' as math;

import '../collision/ccd_solver.dart';
import '../collision/spatial_hash.dart';
import '../distance_constraint.dart';
import '../soft_body.dart';
import '../volume_constraint.dart';

/// Fixed-step position-based simulation world for deformable particle bodies.
///
/// The world is renderer-agnostic. Feed world-space vertices after skeletal
/// transforms, then consume [SoftBody.positions] for rendering.
class PhysicsWorld {
  PhysicsWorld({
    this.fixedTimeStep = 1 / 120,
    this.maxSubSteps = 8,
    this.constraintIterations = 6,
    this.gravityX = 0,
    this.gravityY = -9.81,
    this.gravityZ = 0,
    this.restitution = 0.05,
    this.spatialCellSize = 0.25,
  }) : _spatialHash = SpatialHash(cellSize: spatialCellSize) {
    if (!fixedTimeStep.isFinite || fixedTimeStep <= 0 ||
        maxSubSteps < 1 || constraintIterations < 1 ||
        !restitution.isFinite || restitution < 0 || restitution > 1 ||
        !gravityX.isFinite || !gravityY.isFinite || !gravityZ.isFinite) {
      throw ArgumentError('Invalid physics world configuration.');
    }
  }

  final double fixedTimeStep;
  final int maxSubSteps;
  final int constraintIterations;
  final double gravityX;
  final double gravityY;
  final double gravityZ;
  final double restitution;
  final double spatialCellSize;

  final List<SoftBody> _bodies = <SoftBody>[];
  final SpatialHash _spatialHash;
  final CcdSolver _ccd = const CcdSolver();
  double _accumulator = 0;

  List<SoftBody> get bodies => List<SoftBody>.unmodifiable(_bodies);

  void addBody(SoftBody body) {
    if (_bodies.contains(body)) {
      throw ArgumentError('The body is already part of this world.');
    }
    _bodies.add(body);
  }

  bool removeBody(SoftBody body) => _bodies.remove(body);

  /// Advances with a bounded accumulator and returns the number of fixed steps.
  int advance(double frameDelta) {
    if (!frameDelta.isFinite || frameDelta < 0) {
      throw ArgumentError.value(frameDelta, 'frameDelta');
    }
    _accumulator += math.min(frameDelta, fixedTimeStep * maxSubSteps).toDouble();
    var steps = 0;
    while (_accumulator + 1e-12 >= fixedTimeStep && steps < maxSubSteps) {
      _simulate(fixedTimeStep);
      _accumulator = math.max(0.0, _accumulator - fixedTimeStep).toDouble();
      steps++;
    }
    return steps;
  }

  /// Runs one deterministic fixed simulation step.
  void step() => _simulate(fixedTimeStep);

  void resetClock() => _accumulator = 0;

  void _simulate(double dt) {
    for (final body in _bodies) {
      body.capturePreviousPositions();
      final damping = math.exp(-body.linearDamping * dt);
      for (var i = 0; i < body.particleCount; i++) {
        final offset = i * 3;
        final inverseMass = body.inverseMasses[i];
        if (inverseMass <= 0) {
          body.velocities[offset] = 0;
          body.velocities[offset + 1] = 0;
          body.velocities[offset + 2] = 0;
          continue;
        }
        body.velocities[offset] =
            (body.velocities[offset] + gravityX * dt) * damping;
        body.velocities[offset + 1] =
            (body.velocities[offset + 1] + gravityY * dt) * damping;
        body.velocities[offset + 2] =
            (body.velocities[offset + 2] + gravityZ * dt) * damping;
        body.positions[offset] += body.velocities[offset] * dt;
        body.positions[offset + 1] += body.velocities[offset + 1] * dt;
        body.positions[offset + 2] += body.velocities[offset + 2] * dt;
      }
    }

    final contacts = _buildContactPairs();
    for (var iteration = 0; iteration < constraintIterations; iteration++) {
      for (final body in _bodies) {
        for (final constraint in body.constraints) {
          _solveDistanceConstraint(body, constraint);
        }
        for (final constraint in body.volumeConstraints) {
          _solveVolumeConstraint(body, constraint);
        }
      }
      for (final pair in contacts) {
        _ccd.resolvePair(
          bodyA: _bodies[pair.$1],
          particleA: pair.$2,
          bodyB: _bodies[pair.$3],
          particleB: pair.$4,
        );
      }
    }

    final inverseDt = 1 / dt;
    for (final body in _bodies) {
      for (var i = 0; i < body.particleCount; i++) {
        final offset = i * 3;
        if (body.inverseMasses[i] <= 0) continue;
        body.velocities[offset] =
            (body.positions[offset] - body.previousPositions[offset]) * inverseDt;
        body.velocities[offset + 1] =
            (body.positions[offset + 1] - body.previousPositions[offset + 1]) * inverseDt;
        body.velocities[offset + 2] =
            (body.positions[offset + 2] - body.previousPositions[offset + 2]) * inverseDt;
      }
    }
    if (restitution > 0) {
      for (final pair in contacts) {
        _ccd.applyRestitution(
          bodyA: _bodies[pair.$1],
          particleA: pair.$2,
          bodyB: _bodies[pair.$3],
          particleB: pair.$4,
          restitution: restitution,
        );
      }
    }
  }

  void _solveDistanceConstraint(SoftBody body, DistanceConstraint constraint) {
    final a = constraint.a * 3;
    final b = constraint.b * 3;
    final dx = body.positions[b] - body.positions[a];
    final dy = body.positions[b + 1] - body.positions[a + 1];
    final dz = body.positions[b + 2] - body.positions[a + 2];
    final distance2 = dx * dx + dy * dy + dz * dz;
    if (distance2 <= 1e-18) return;
    final distance = math.sqrt(distance2);
    final wa = body.inverseMasses[constraint.a];
    final wb = body.inverseMasses[constraint.b];
    final sum = wa + wb;
    if (sum <= 0) return;
    final correction = (distance - constraint.restLength) *
        constraint.stiffness / sum;
    final nx = dx / distance;
    final ny = dy / distance;
    final nz = dz / distance;
    body.positions[a] += nx * correction * wa;
    body.positions[a + 1] += ny * correction * wa;
    body.positions[a + 2] += nz * correction * wa;
    body.positions[b] -= nx * correction * wb;
    body.positions[b + 1] -= ny * correction * wb;
    body.positions[b + 2] -= nz * correction * wb;
  }

  void _solveVolumeConstraint(
    SoftBody body,
    TetraVolumeConstraint constraint,
  ) {
    final ia = constraint.a * 3;
    final ib = constraint.b * 3;
    final ic = constraint.c * 3;
    final id = constraint.d * 3;
    final p = body.positions;

    final abx = p[ib] - p[ia];
    final aby = p[ib + 1] - p[ia + 1];
    final abz = p[ib + 2] - p[ia + 2];
    final acx = p[ic] - p[ia];
    final acy = p[ic + 1] - p[ia + 1];
    final acz = p[ic + 2] - p[ia + 2];
    final adx = p[id] - p[ia];
    final ady = p[id + 1] - p[ia + 1];
    final adz = p[id + 2] - p[ia + 2];

    final crossX = acy * adz - acz * ady;
    final crossY = acz * adx - acx * adz;
    final crossZ = acx * ady - acy * adx;
    final volume = (abx * crossX + aby * crossY + abz * crossZ) / 6;
    final error = volume - constraint.restVolume;
    if (error.abs() <= 1e-10) return;

    final gbx = crossX / 6;
    final gby = crossY / 6;
    final gbz = crossZ / 6;
    final gcx = (ady * abz - adz * aby) / 6;
    final gcy = (adz * abx - adx * abz) / 6;
    final gcz = (adx * aby - ady * abx) / 6;
    final gdx = (aby * acz - abz * acy) / 6;
    final gdy = (abz * acx - abx * acz) / 6;
    final gdz = (abx * acy - aby * acx) / 6;
    final gax = -(gbx + gcx + gdx);
    final gay = -(gby + gcy + gdy);
    final gaz = -(gbz + gcz + gdz);

    final wa = body.inverseMasses[constraint.a];
    final wb = body.inverseMasses[constraint.b];
    final wc = body.inverseMasses[constraint.c];
    final wd = body.inverseMasses[constraint.d];
    final denominator =
        wa * (gax * gax + gay * gay + gaz * gaz) +
        wb * (gbx * gbx + gby * gby + gbz * gbz) +
        wc * (gcx * gcx + gcy * gcy + gcz * gcz) +
        wd * (gdx * gdx + gdy * gdy + gdz * gdz);
    if (denominator <= 1e-18) return;

    final lambda = -error * constraint.stiffness / denominator;
    p[ia] += wa * lambda * gax;
    p[ia + 1] += wa * lambda * gay;
    p[ia + 2] += wa * lambda * gaz;
    p[ib] += wb * lambda * gbx;
    p[ib + 1] += wb * lambda * gby;
    p[ib + 2] += wb * lambda * gbz;
    p[ic] += wc * lambda * gcx;
    p[ic + 1] += wc * lambda * gcy;
    p[ic + 2] += wc * lambda * gcz;
    p[id] += wd * lambda * gdx;
    p[id + 1] += wd * lambda * gdy;
    p[id + 2] += wd * lambda * gdz;
  }

  List<(int, int, int, int)> _buildContactPairs() {
    _spatialHash.clear();
    final offsets = List<int>.filled(_bodies.length, 0);
    var totalParticles = 0;
    for (var bodyIndex = 0; bodyIndex < _bodies.length; bodyIndex++) {
      offsets[bodyIndex] = totalParticles;
      totalParticles += _bodies[bodyIndex].particleCount;
    }
    final bodyForParticle = List<int>.filled(totalParticles, 0);
    var requiresFallback = false;
    for (var bodyIndex = 0; bodyIndex < _bodies.length; bodyIndex++) {
      final body = _bodies[bodyIndex];
      for (var particle = 0; particle < body.particleCount; particle++) {
        final id = offsets[bodyIndex] + particle;
        bodyForParticle[id] = bodyIndex;
        final p = particle * 3;
        final inserted = _spatialHash.insertSweptParticle(
          particleId: id,
          previousX: body.previousPositions[p],
          previousY: body.previousPositions[p + 1],
          previousZ: body.previousPositions[p + 2],
          currentX: body.positions[p],
          currentY: body.positions[p + 1],
          currentZ: body.positions[p + 2],
          radius: body.radii[particle],
        );
        requiresFallback = requiresFallback || !inserted;
      }
    }

    final uniquePairs = <(int, int)>{};
    if (requiresFallback) {
      // Conservative fallback for exceptionally long sweeps. It is rare and
      // intentionally trades speed for not silently missing a collision.
      for (var a = 0; a < totalParticles; a++) {
        for (var b = a + 1; b < totalParticles; b++) {
          if (bodyForParticle[a] != bodyForParticle[b]) {
            uniquePairs.add((a, b));
          }
        }
      }
    } else {
      for (final bucket in _spatialHash.buckets) {
        for (var i = 0; i < bucket.length; i++) {
          for (var j = i + 1; j < bucket.length; j++) {
            final a = bucket[i], b = bucket[j];
            if (bodyForParticle[a] == bodyForParticle[b]) continue;
            uniquePairs.add(a < b ? (a, b) : (b, a));
          }
        }
      }
    }

    final result = <(int, int, int, int)>[];
    for (final pair in uniquePairs) {
      final bodyA = bodyForParticle[pair.$1];
      final bodyB = bodyForParticle[pair.$2];
      result.add((
        bodyA,
        pair.$1 - offsets[bodyA],
        bodyB,
        pair.$2 - offsets[bodyB],
      ));
    }
    return result;
  }
}
