/// Tetrahedral volume preservation constraint for a deformable body.
class TetraVolumeConstraint {
  TetraVolumeConstraint({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.restVolume,
    this.stiffness = 1,
  }) : assert(a >= 0 && b >= 0 && c >= 0 && d >= 0),
       assert(a != b && a != c && a != d &&
           b != c && b != d && c != d),
       assert(stiffness >= 0 && stiffness <= 1);

  final int a;
  final int b;
  final int c;
  final int d;
  final double restVolume;
  final double stiffness;
}
