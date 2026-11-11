import '../math/vec3.dart';

class SoftBodyNode {
  SoftBodyNode({
    required this.position,
    this.velocity = Vec3.zero,
    this.inverseMass = 1,
    Vec3? restPosition,
  }) : restPosition = restPosition ?? position {
    if (!inverseMass.isFinite || inverseMass < 0) {
      throw ArgumentError.value(inverseMass, 'inverseMass');
    }
  }

  Vec3 position;
  Vec3 previousPosition = Vec3.zero;
  Vec3 velocity;
  final Vec3 restPosition;
  final double inverseMass;
  bool get isStatic => inverseMass == 0;
}

class DistanceConstraint {
  DistanceConstraint({
    required this.a,
    required this.b,
    required this.restLength,
    this.compliance = 0,
  }) {
    if (a == b || restLength < 0 || compliance < 0) {
      throw ArgumentError('Invalid distance constraint');
    }
  }
  final int a;
  final int b;
  final double restLength;
  final double compliance;
  double _lambda = 0;
  void resetLambda() => _lambda = 0;

  void solve(List<SoftBodyNode> nodes, double dt) {
    final first = nodes[a];
    final second = nodes[b];
    final delta = first.position - second.position;
    final distance = delta.length;
    if (distance < 1e-9) return;
    final wa = first.inverseMass;
    final wb = second.inverseMass;
    final alpha = compliance / (dt * dt);
    final denominator = wa + wb + alpha;
    if (denominator <= 1e-12) return;
    final constraint = distance - restLength;
    final dlambda = (-constraint - alpha * _lambda) / denominator;
    _lambda += dlambda;
    final gradient = delta / distance;
    if (wa > 0) first.position = first.position + gradient * (wa * dlambda);
    if (wb > 0) second.position = second.position - gradient * (wb * dlambda);
  }
}

/// Tetrahedral volume constraint. Its gradients are evaluated from current
/// positions and corrections are mass weighted (XPBD compliance supported).
class TetraVolumeConstraint {
  TetraVolumeConstraint({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.restVolume,
    this.compliance = 0,
  }) {
    if ({a, b, c, d}.length != 4 || compliance < 0) {
      throw ArgumentError('Invalid tetrahedron constraint');
    }
  }
  final int a, b, c, d;
  final double restVolume;
  final double compliance;
  double _lambda = 0;
  void resetLambda() => _lambda = 0;

  double _volume(Vec3 a, Vec3 b, Vec3 c, Vec3 d) =>
      (b - a).dot((c - a).cross(d - a)) / 6.0;

  void solve(List<SoftBodyNode> nodes, double dt) {
    final na = nodes[a], nb = nodes[b], nc = nodes[c], nd = nodes[d];
    final pa = na.position, pb = nb.position;
    final pc = nc.position, pd = nd.position;
    final gb = (pc - pa).cross(pd - pa) / 6.0;
    final gc = (pd - pa).cross(pb - pa) / 6.0;
    final gd = (pb - pa).cross(pc - pa) / 6.0;
    final ga = -(gb + gc + gd);
    final gradients = [ga, gb, gc, gd];
    final selected = [na, nb, nc, nd];
    var denominator = compliance / (dt * dt);
    for (var i = 0; i < 4; i++) {
      denominator += selected[i].inverseMass * gradients[i].lengthSquared;
    }
    if (denominator <= 1e-12) return;
    final constraint = _volume(pa, pb, pc, pd) - restVolume;
    final alpha = compliance / (dt * dt);
    final dlambda = (-constraint - alpha * _lambda) / denominator;
    _lambda += dlambda;
    for (var i = 0; i < 4; i++) {
      final weight = selected[i].inverseMass;
      if (weight > 0) {
        selected[i].position =
            selected[i].position + gradients[i] * (weight * dlambda);
      }
    }
  }
}

class SoftBodyBody {
  SoftBodyBody({
    required this.id,
    required this.nodes,
    this.distanceConstraints = const [],
    this.volumeConstraints = const [],
    this.linearDamping = 0.985,
    this.maxSpeed = 30,
  }) {
    if (id.isEmpty || nodes.isEmpty) throw ArgumentError('Body needs id/nodes');
    if (linearDamping < 0 || linearDamping > 1 || maxSpeed <= 0) {
      throw ArgumentError('Invalid soft-body parameters');
    }
  }

  final String id;
  final List<SoftBodyNode> nodes;
  final List<DistanceConstraint> distanceConstraints;
  final List<TetraVolumeConstraint> volumeConstraints;
  final double linearDamping;
  final double maxSpeed;

  void integrate(Vec3 gravity, double dt) {
    for (final node in nodes) {
      node.previousPosition = node.position;
      if (node.isStatic) {
        node.velocity = Vec3.zero;
        continue;
      }
      node.velocity = (node.velocity + gravity * dt) * linearDamping;
      node.velocity = node.velocity.clampMagnitude(maxSpeed);
      node.position = node.position + node.velocity * dt;
    }
  }

  void solveConstraints(double dt, {int iterations = 5}) {
    for (final constraint in distanceConstraints) {
      constraint.resetLambda();
    }
    for (final constraint in volumeConstraints) {
      constraint.resetLambda();
    }
    for (var iteration = 0; iteration < iterations; iteration++) {
      for (final constraint in distanceConstraints) {
        constraint.solve(nodes, dt);
      }
      for (final constraint in volumeConstraints) {
        constraint.solve(nodes, dt);
      }
    }
    for (final node in nodes) {
      if (!node.isStatic) {
        node.velocity = (node.position - node.previousPosition) / dt;
        node.velocity = node.velocity.clampMagnitude(maxSpeed);
      }
    }
  }
}
