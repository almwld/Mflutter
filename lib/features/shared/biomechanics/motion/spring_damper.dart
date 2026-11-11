/// Scalar spring-damper state for secondary motion and soft constraints.
class SpringDamper {
  SpringDamper({
    required this.value,
    this.velocity = 0,
    this.stiffness = 120,
    this.damping = 18,
    this.mass = 1,
    this.maxSpeed = 100,
  }) {
    if (stiffness < 0 || damping < 0 || mass <= 0 || maxSpeed <= 0) {
      throw ArgumentError('Invalid spring-damper parameters');
    }
  }

  double value;
  double velocity;
  final double stiffness;
  final double damping;
  final double mass;
  final double maxSpeed;

  /// Semi-implicit Euler with bounded substeps for stable frame-rate variance.
  double step(double target, double deltaTime, {double maxStep = 1 / 120}) {
    if (!target.isFinite || !deltaTime.isFinite || deltaTime < 0 ||
        !maxStep.isFinite || maxStep <= 0) {
      throw ArgumentError('Target and time values must be finite and valid');
    }
    var remaining = deltaTime;
    while (remaining > 0) {
      final dt = remaining < maxStep ? remaining : maxStep;
      final force = stiffness * (target - value) - damping * velocity;
      velocity = (velocity + force / mass * dt)
          .clamp(-maxSpeed, maxSpeed).toDouble();
      value += velocity * dt;
      remaining -= dt;
    }
    return value;
  }

  void reset(double nextValue) {
    if (!nextValue.isFinite) throw ArgumentError.value(nextValue);
    value = nextValue;
    velocity = 0;
  }
}
