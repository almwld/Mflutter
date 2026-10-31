import 'dart:math' as math;

/// Small immutable vector type used by the biomechanics runtime.
///
/// Keeping the solver independent from rendering and third-party math APIs
/// makes it deterministic and straightforward to test on every Flutter target.
class Vec3 {
  const Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  static const zero = Vec3(0, 0, 0);
  static const one = Vec3(1, 1, 1);

  Vec3 operator +(Vec3 other) =>
      Vec3(x + other.x, y + other.y, z + other.z);
  Vec3 operator -(Vec3 other) =>
      Vec3(x - other.x, y - other.y, z - other.z);
  Vec3 operator -() => Vec3(-x, -y, -z);
  Vec3 operator *(double scalar) =>
      Vec3(x * scalar, y * scalar, z * scalar);
  Vec3 operator /(double scalar) {
    if (scalar.abs() < 1e-12) {
      throw ArgumentError.value(scalar, 'scalar', 'Must be non-zero');
    }
    return Vec3(x / scalar, y / scalar, z / scalar);
  }

  double dot(Vec3 other) => x * other.x + y * other.y + z * other.z;
  Vec3 cross(Vec3 other) => Vec3(
        y * other.z - z * other.y,
        z * other.x - x * other.z,
        x * other.y - y * other.x,
      );
  double get lengthSquared => dot(this);
  double get length => math.sqrt(lengthSquared);
  Vec3 normalized([Vec3 fallback = zero]) {
    final magnitude = length;
    return magnitude < 1e-9 ? fallback : this / magnitude;
  }
  Vec3 withLength(double value) => normalized() * value;
  Vec3 clampMagnitude(double maximum) {
    final squared = lengthSquared;
    if (squared <= maximum * maximum) return this;
    return this * (maximum / math.sqrt(squared));
  }
  static Vec3 lerp(Vec3 a, Vec3 b, double t) {
    final u = t.clamp(0.0, 1.0);
    return a + (b - a) * u;
  }

  @override
  bool operator ==(Object other) =>
      other is Vec3 && x == other.x && y == other.y && z == other.z;
  @override
  int get hashCode => Object.hash(x, y, z);
  @override
  String toString() => 'Vec3($x, $y, $z)';
}

extension on double {
  double sqrt() {
    if (this <= 0) return 0;
    // Newton iteration avoids an extra dependency in this tiny math layer.
    var x = this > 1 ? this : 1.0;
    for (var i = 0; i < 8; i++) {
      x = (x + this / x) * .5;
    }
    return x;
  }
}
