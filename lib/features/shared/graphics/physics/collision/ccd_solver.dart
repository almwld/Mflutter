import 'dart:math' as math;

import '../soft_body.dart';

/// Continuous particle-particle contact projection.
///
/// The narrow phase computes the closest point between two swept relative
/// trajectories. If their swept spheres overlap, it projects the pair back to
/// the non-crossed side of the impact normal. This is a robust vertex-sampled
/// CCD layer; it is not a triangle-triangle mesh intersection test.
class CcdSolver {
  const CcdSolver();

  bool resolvePair({
    required SoftBody bodyA,
    required int particleA,
    required SoftBody bodyB,
    required int particleB,
    required double restitution,
  }) {
    final ia = particleA * 3;
    final ib = particleB * 3;
    final a0 = bodyA.previousPositions;
    final b0 = bodyB.previousPositions;
    final a1 = bodyA.positions;
    final b1 = bodyB.positions;

    final sx = a0[ia] - b0[ib];
    final sy = a0[ia + 1] - b0[ib + 1];
    final sz = a0[ia + 2] - b0[ib + 2];
    final dx = (a1[ia] - a0[ia]) - (b1[ib] - b0[ib]);
    final dy = (a1[ia + 1] - a0[ia + 1]) -
        (b1[ib + 1] - b0[ib + 1]);
    final dz = (a1[ia + 2] - a0[ia + 2]) -
        (b1[ib + 2] - b0[ib + 2]);

    final motionLength2 = dx * dx + dy * dy + dz * dz;
    final t = motionLength2 > 1e-18
        ? (-(sx * dx + sy * dy + sz * dz) / motionLength2)
            .clamp(0.0, 1.0).toDouble()
        : 0.0;
    final cx = sx + dx * t;
    final cy = sy + dy * t;
    final cz = sz + dz * t;
    final distance2 = cx * cx + cy * cy + cz * cz;
    final radius = bodyA.radii[particleA] + bodyB.radii[particleB];
    if (distance2 >= radius * radius) return false;

    final distance = math.sqrt(distance2);
    double nx, ny, nz;
    if (distance > 1e-9) {
      nx = cx / distance;
      ny = cy / distance;
      nz = cz / distance;
    } else {
      final speed = math.sqrt(motionLength2);
      if (speed > 1e-9) {
        nx = -dx / speed;
        ny = -dy / speed;
        nz = -dz / speed;
      } else {
        nx = 1;
        ny = 0;
        nz = 0;
      }
    }

    final weightA = bodyA.inverseMasses[particleA];
    final weightB = bodyB.inverseMasses[particleB];
    final totalWeight = weightA + weightB;
    if (totalWeight <= 0) return false;

    // Use signed separation at the end of the step. If the particles crossed,
    // this deliberately pushes them back to the same side of the impact plane.
    final endX = a1[ia] - b1[ib];
    final endY = a1[ia + 1] - b1[ib + 1];
    final endZ = a1[ia + 2] - b1[ib + 2];
    final signedDistance = endX * nx + endY * ny + endZ * nz;
    final correction = radius - signedDistance;
    if (correction <= 0) return false;

    final moveA = correction * weightA / totalWeight;
    final moveB = correction * weightB / totalWeight;
    a1[ia] += nx * moveA;
    a1[ia + 1] += ny * moveA;
    a1[ia + 2] += nz * moveA;
    b1[ib] -= nx * moveB;
    b1[ib + 1] -= ny * moveB;
    b1[ib + 2] -= nz * moveB;
    return true;
  }
}
