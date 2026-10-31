import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/features/shared/graphics/physics/distance_constraint.dart';
import 'package:mudabbir_al_asrar/features/shared/graphics/physics/soft_body.dart';
import 'package:mudabbir_al_asrar/features/shared/graphics/physics/simulation/physics_world.dart';
import 'package:mudabbir_al_asrar/features/shared/graphics/physics/volume_constraint.dart';

void main() {
  group('PhysicsWorld', () {
    test('uses fixed steps and bounds catch-up work', () {
      final world = PhysicsWorld(fixedTimeStep: .01, maxSubSteps: 3);
      final body = SoftBody(
        positions: Float64List.fromList([0, 0, 0]),
        inverseMasses: Float64List.fromList([1]),
        radii: Float64List.fromList([.05]),
        linearDamping: 0,
      )..velocities[0] = 1;
      world.addBody(body);

      expect(world.advance(.1), 3);
      expect(body.positions[0], closeTo(.03, 1e-9));
    });

    test('distance constraints preserve structural length', () {
      final world = PhysicsWorld(
        fixedTimeStep: .01,
        gravityY: 0,
        constraintIterations: 12,
      );
      final body = SoftBody(
        positions: Float64List.fromList([0, 0, 0, 2, 0, 0]),
        velocities: Float64List.fromList([0, 0, 0, 0, 4, 0]),
        inverseMasses: Float64List.fromList([0, 1]),
        radii: Float64List.fromList([0, 0]),
        constraints: [
          DistanceConstraint(a: 0, b: 1, restLength: 1, stiffness: 1),
        ],
      );
      world.addBody(body);
      world.step();

      final dx = body.positions[3] - body.positions[0];
      final dy = body.positions[4] - body.positions[1];
      final dz = body.positions[5] - body.positions[2];
      expect((dx * dx + dy * dy + dz * dz), closeTo(1, 1e-6));
    });

    test('tetrahedral constraint restores deformed volume', () {
      final world = PhysicsWorld(
        fixedTimeStep: .05,
        gravityY: 0,
        constraintIterations: 20,
      );
      final body = SoftBody(
        positions: Float64List.fromList([
          0, 0, 0,
          1, 0, 0,
          0, 1, 0,
          0, 0, 1,
        ]),
        velocities: Float64List.fromList([
          0, 0, 0,
          0, 0, 0,
          0, 0, 0,
          0, 0, 10,
        ]),
        inverseMasses: Float64List.fromList([0, 1, 1, 1]),
        radii: Float64List(4),
        linearDamping: 0,
        volumeConstraints: [
          TetraVolumeConstraint(
            a: 0,
            b: 1,
            c: 2,
            d: 3,
            restVolume: 1 / 6,
          ),
        ],
      );
      world.addBody(body);
      world.step();

      final p = body.positions;
      final abx = p[3] - p[0], aby = p[4] - p[1], abz = p[5] - p[2];
      final acx = p[6] - p[0], acy = p[7] - p[1], acz = p[8] - p[2];
      final adx = p[9] - p[0], ady = p[10] - p[1], adz = p[11] - p[2];
      final volume = (abx * (acy * adz - acz * ady) +
              aby * (acz * adx - acx * adz) +
              abz * (acx * ady - acy * adx)) /
          6;
      expect(volume, closeTo(1 / 6, .01));
    });

    test('continuous collision prevents fast particle tunnelling', () {
      final world = PhysicsWorld(
        fixedTimeStep: .1,
        maxSubSteps: 1,
        gravityX: 0,
        gravityY: 0,
        gravityZ: 0,
        constraintIterations: 2,
        spatialCellSize: .1,
      );
      final moving = SoftBody(
        positions: Float64List.fromList([-1, 0, 0]),
        velocities: Float64List.fromList([20, 0, 0]),
        inverseMasses: Float64List.fromList([1]),
        radii: Float64List.fromList([.1]),
      );
      final fixed = SoftBody(
        positions: Float64List.fromList([0, 0, 0]),
        inverseMasses: Float64List.fromList([0]),
        radii: Float64List.fromList([.1]),
      );
      world.addBody(moving);
      world.addBody(fixed);

      world.step();

      expect(moving.positions[0], lessThanOrEqualTo(-.199));
      expect(fixed.positions[0], 0);
    });

    test('rejects malformed particle buffers', () {
      expect(
        () => SoftBody(
          positions: Float64List.fromList([0, 1]),
          inverseMasses: Float64List.fromList([1]),
          radii: Float64List.fromList([.1]),
        ),
        throwsArgumentError,
      );
    });
  });
}
