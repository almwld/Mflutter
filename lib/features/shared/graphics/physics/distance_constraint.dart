/// A structural constraint between two particles in a soft body.
class DistanceConstraint {
  DistanceConstraint({
    required this.a,
    required this.b,
    required this.restLength,
    this.stiffness = 1,
  }) : assert(a >= 0 && b >= 0 && a != b),
       assert(restLength >= 0),
       assert(stiffness >= 0 && stiffness <= 1);

  final int a;
  final int b;
  final double restLength;

  /// 0 keeps the current length; 1 fully projects to [restLength].
  final double stiffness;
}
