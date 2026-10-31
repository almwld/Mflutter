import '../math/vec3.dart';
import '../soft_body/soft_body_body.dart';
import 'spatial_hash_grid.dart';

class ContactMaterial {
  const ContactMaterial({
    this.friction = .35,
    this.restitution = 0,
    this.compliance = 0,
  }) : assert(friction >= 0),
       assert(restitution >= 0 && restitution <= 1),
       assert(compliance >= 0);
  final double friction;
  final double restitution;
  final double compliance;
}

class ContactStats {
  const ContactStats({
    required this.candidatePairs,
    required this.resolvedPairs,
    required this.maximumCorrection,
  });
  final int candidatePairs;
  final int resolvedPairs;
  final double maximumCorrection;
}

/// Symmetric vertex contact using a spatial broad phase and inverse-mass
/// weighted positional correction. It is deliberately renderer agnostic.
class MultiBodyContactSolver {
  MultiBodyContactSolver({
    this.contactDistance = .025,
    this.material = const ContactMaterial(),
  }) : _grid = SpatialHashGrid<int>(
          cellSize: contactDistance > 0 ? contactDistance : .025,
        ) {
    if (!contactDistance.isFinite || contactDistance <= 0) {
      throw ArgumentError.value(contactDistance, 'contactDistance');
    }
  }

  final double contactDistance;
  final ContactMaterial material;
  final SpatialHashGrid<int> _grid;

  ContactStats solve(
    SoftBodyBody bodyA,
    SoftBodyBody bodyB, {
    int iterations = 2,
  }) {
    if (bodyA.id == bodyB.id) {
      throw ArgumentError('Contact bodies must have different ids');
    }
    var candidates = 0;
    var resolved = 0;
    var maxCorrection = 0.0;

    for (var iteration = 0; iteration < iterations; iteration++) {
      _grid.rebuild(
        bodyB.nodes.indexed.map((entry) => (entry.$1, entry.$2.position)),
      );
      for (final nodeA in bodyA.nodes) {
        if (nodeA.isStatic) continue;
        final nearby = _grid.query(nodeA.position, contactDistance);
        for (final indexB in nearby) {
          final nodeB = bodyB.nodes[indexB];
          if (nodeB.isStatic && nodeA.isStatic) continue;
          candidates++;
          final delta = nodeA.position - nodeB.position;
          final distanceSquared = delta.lengthSquared;
          final thresholdSquared = contactDistance * contactDistance;
          if (distanceSquared >= thresholdSquared) continue;
          final distance = distanceSquared <= 1e-18 ? 0 : delta.length;
          final normal = distance <= 1e-9
              ? Vec3(1, 0, 0)
              : delta / distance;
          final penetration = contactDistance - distance;
          final wa = nodeA.inverseMass;
          final wb = nodeB.inverseMass;
          final totalWeight = wa + wb;
          if (totalWeight <= 0) continue;
          final correction = penetration / totalWeight;
          if (wa > 0) {
            nodeA.position = nodeA.position + normal * (correction * wa);
          }
          if (wb > 0) {
            nodeB.position = nodeB.position - normal * (correction * wb);
          }

          // Coulomb-like tangential velocity damping, bounded by the normal
          // correction so friction cannot pull separated nodes together.
          final relativeVelocity = nodeA.velocity - nodeB.velocity;
          final tangentVelocity =
              relativeVelocity - normal * relativeVelocity.dot(normal);
          final tangentLength = tangentVelocity.length;
          if (tangentLength > 1e-9 && material.friction > 0) {
            final frictionImpulse = tangentVelocity *
                (-material.friction.clamp(0.0, 1.0).toDouble() * .5);
            if (wa > 0) {
              nodeA.velocity = nodeA.velocity +
                  frictionImpulse * (wa / totalWeight);
            }
            if (wb > 0) {
              nodeB.velocity = nodeB.velocity -
                  frictionImpulse * (wb / totalWeight);
            }
          }
          resolved++;
          if (correction > maxCorrection) maxCorrection = correction;
        }
      }
    }
    return ContactStats(
      candidatePairs: candidates,
      resolvedPairs: resolved,
      maximumCorrection: maxCorrection,
    );
  }
}
