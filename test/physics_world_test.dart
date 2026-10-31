import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/features/shared/graphics/physics/distance_constraint.dart';
import 'package:mudabbir_al_asrar/features/shared/graphics/physics/soft_body.dart';
import 'package:mudabbir_al_asrar/features/shared/graphics/physics/simulation/physics_world.dart';

void main() {
  group('PhysicsWorld', () {
    test('uses fixed steps and bounds catch-up work', () {
      final world = PhysicsWorld(fixedTimeStep: .01, maxSubSteps: 3);
      final body = SoftBody(
        positions: Float64List.fromList([0, 0, 0]),
        inverseMasses: Float64List.fromList([1]),
        radii: Float64List.fromList([.05]),
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
