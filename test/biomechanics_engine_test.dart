import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/features/shared/biomechanics/motion/pose_preset_manager.dart';
import 'package:mudabbir_al_asrar/features/shared/biomechanics/motion/spring_damper.dart';
import 'package:mudabbir_al_asrar/features/shared/biomechanics/motion/two_bone_ik.dart';
import 'package:mudabbir_al_asrar/features/shared/biomechanics/collision/contact_solver.dart';
import 'package:mudabbir_al_asrar/features/shared/biomechanics/collision/spatial_hash_grid.dart';
import 'package:mudabbir_al_asrar/features/shared/biomechanics/core/biomechanics_engine.dart';
import 'package:mudabbir_al_asrar/features/shared/biomechanics/math/vec3.dart';
import 'package:mudabbir_al_asrar/features/shared/biomechanics/soft_body/soft_body_body.dart';

void main() {
  group('SpatialHashGrid', () {
    test('queries neighboring cells, including negative coordinates', () {
      final grid = SpatialHashGrid<String>(cellSize: .1);
      grid.insert('near', const Vec3(-.01, 0, 0));
      grid.insert('far', const Vec3(2, 0, 0));
      expect(grid.query(const Vec3(.01, 0, 0), .05), contains('near'));
      expect(grid.query(const Vec3(.01, 0, 0), .05), isNot(contains('far')));
    });

    test('rejects invalid cell sizes', () {
      expect(() => SpatialHashGrid<int>(cellSize: 0), throwsArgumentError);
    });
  });

  group('soft body constraints', () {
    test('distance constraint converges toward rest length', () {
      final nodes = [
        SoftBodyNode(position: const Vec3(0, 0, 0), inverseMass: 0),
        SoftBodyNode(position: const Vec3(2, 0, 0)),
      ];
      final body = SoftBodyBody(
        id: 'test',
        nodes: nodes,
        distanceConstraints: [
          DistanceConstraint(a: 0, b: 1, restLength: 1),
        ],
      );
      body.solveConstraints(1 / 60, iterations: 12);
      expect((nodes[1].position - nodes[0].position).length,
          closeTo(1, .001));
    });

    test('tetra volume constraint restores signed volume', () {
      final nodes = [
        SoftBodyNode(position: const Vec3(0, 0, 0), inverseMass: 0),
        SoftBodyNode(position: const Vec3(1, 0, 0)),
        SoftBodyNode(position: const Vec3(0, 1, 0)),
        SoftBodyNode(position: const Vec3(0, 0, 1)),
      ];
      final constraint = TetraVolumeConstraint(
        a: 0, b: 1, c: 2, d: 3, restVolume: 1 / 6,
      );
      nodes[3].position = const Vec3(0, 0, .5);
      for (var i = 0; i < 20; i++) {
        constraint.solve(nodes, 1 / 60);
      }
      final volume = (nodes[1].position - nodes[0].position).dot(
        (nodes[2].position - nodes[0].position)
            .cross(nodes[3].position - nodes[0].position),
      ) / 6;
      expect(volume, closeTo(1 / 6, .01));
    });
  });

  group('MultiBodyContactSolver', () {
    test('resolves bilateral overlap with inverse mass weighting', () {
      final a = SoftBodyBody(
        id: 'a',
        nodes: [SoftBodyNode(position: const Vec3(0, 0, 0))],
      );
      final b = SoftBodyBody(
        id: 'b',
        nodes: [SoftBodyNode(position: const Vec3(.01, 0, 0))],
      );
      final stats = MultiBodyContactSolver(contactDistance: .1)
          .solve(a, b);
      expect(stats.resolvedPairs, 1);
      expect((a.nodes.first.position - b.nodes.first.position).length,
          closeTo(.1, 1e-8));
    });
  });

  group('BiomechanicsEngine', () {
    test('uses fixed steps and caps excessive frame deltas', () {
      final engine = BiomechanicsEngine(
        settings: const BiomechanicsSettings(
          fixedTimeStep: 1 / 60,
          maxSubSteps: 2,
        ),
      );
      engine.addBody(SoftBodyBody(
        id: 'body',
        nodes: [SoftBodyNode(position: Vec3.zero)],
      ));
      final stats = engine.advance(.2);
      expect(stats.subSteps, 2);
      expect(stats.droppedTime, greaterThan(0));
      expect(engine.interpolationAlpha, inInclusiveRange(0, 1));
    });

    test('rejects duplicate ids and use after dispose', () {
      final engine = BiomechanicsEngine();
      final body = SoftBodyBody(
        id: 'same',
        nodes: [SoftBodyNode(position: Vec3.zero)],
      );
      engine.addBody(body);
      expect(() => engine.addBody(body), throwsArgumentError);
      engine.dispose();
      expect(() => engine.advance(1 / 60), throwsStateError);
    });
  });

  group('motion primitives', () {
    test('blends registered skeletal poses without dropping joints', () {
      final poses = PosePresetManager.standard();
      final blended = poses.blend('standing', 'embrace', .5);
      expect(blended.joints.keys, containsAll(['pelvis', 'leftUpperArm']));
      expect(blended.joints['leftUpperArm']!.rotationEuler.z,
          closeTo(-.425, 1e-9));
    });

    test('spring damper converges toward target', () {
      final spring = SpringDamper(value: 0, stiffness: 80, damping: 16);
      for (var i = 0; i < 240; i++) {
        spring.step(1, 1 / 60);
      }
      expect(spring.value, closeTo(1, .01));
      expect(spring.velocity.abs(), lessThan(.1));
    });

    test('two-bone IK reaches a reachable target', () {
      final result = TwoBoneIk.solve(
        root: Vec3.zero,
        target: const Vec3(1, 0, 0),
        pole: const Vec3(0, 1, 0),
        upperLength: 1,
        lowerLength: 1,
      );
      expect(result.reachedTarget, isTrue);
      expect((result.joint - result.root).length, closeTo(1, 1e-8));
      expect((result.end - result.joint).length, closeTo(1, 1e-8));
    });
  });

}
