import '../math/vec3.dart';

class TwoBoneIkResult {
  const TwoBoneIkResult({
    required this.root,
    required this.joint,
    required this.end,
    required this.reachedTarget,
  });
  final Vec3 root;
  final Vec3 joint;
  final Vec3 end;
  final bool reachedTarget;
}

/// Geometric two-bone IK solver. The pole vector selects the bend plane.
class TwoBoneIk {
  static TwoBoneIkResult solve({
    required Vec3 root,
    required Vec3 target,
    required Vec3 pole,
    required double upperLength,
    required double lowerLength,
  }) {
    if (!upperLength.isFinite || !lowerLength.isFinite ||
        upperLength <= 0 || lowerLength <= 0) {
      throw ArgumentError('Bone lengths must be finite and positive');
    }
    final offset = target - root;
    final rawDistance = offset.length;
    final direction = offset.normalized(const Vec3(0, 0, 1));
    final minimum = (upperLength - lowerLength).abs() + 1e-6;
    final maximum = upperLength + lowerLength - 1e-6;
    final distance = rawDistance.clamp(minimum, maximum).toDouble();

    var bend = pole - root;
    bend = bend - direction * bend.dot(direction);
    if (bend.length < 1e-8) {
      final fallback = direction.cross(const Vec3(0, 1, 0));
      bend = fallback.length < 1e-8
          ? direction.cross(const Vec3(1, 0, 0))
          : fallback;
    }
    bend = bend.normalized();

    final along = (upperLength * upperLength -
            lowerLength * lowerLength +
            distance * distance) /
        (2 * distance);
    final heightSquared = upperLength * upperLength - along * along;
    final height = heightSquared <= 0 ? 0 : _sqrt(heightSquared);
    final joint = root + direction * along + bend * height;
    final end = root + direction * distance;

    return TwoBoneIkResult(
      root: root,
      joint: joint,
      end: end,
      reachedTarget: (end - target).length < 1e-5,
    );
  }

  static double _sqrt(double value) {
    var result = value > 1 ? value : 1.0;
    for (var i = 0; i < 12; i++) {
      result = (result + value / result) * .5;
    }
    return result;
  }
}
