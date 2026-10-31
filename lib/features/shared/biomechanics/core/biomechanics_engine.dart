import '../collision/contact_solver.dart';
import '../math/vec3.dart';
import '../soft_body/soft_body_body.dart';

class BiomechanicsSettings {
  const BiomechanicsSettings({
    this.fixedTimeStep = 1 / 60,
    this.maxSubSteps = 4,
    this.constraintIterations = 6,
    this.gravity = const Vec3(0, -9.81, 0),
    this.maxFrameDelta = .1,
  }) : assert(fixedTimeStep > 0),
       assert(maxSubSteps > 0),
       assert(constraintIterations > 0);
  final double fixedTimeStep;
  final int maxSubSteps;
  final int constraintIterations;
  final Vec3 gravity;
  final double maxFrameDelta;
}

class BiomechanicsFrameStats {
  const BiomechanicsFrameStats({
    required this.subSteps,
    required this.droppedTime,
    required this.contactStats,
  });
  final int subSteps;
  final double droppedTime;
  final List<ContactStats> contactStats;
}

/// Deterministic fixed-step simulation coordinator. Rendering should consume
/// interpolated snapshots and must never mutate solver state.
class BiomechanicsEngine {
  BiomechanicsEngine({
    this.settings = const BiomechanicsSettings(),
    List<MultiBodyContactSolver> contactSolvers = const [],
  }) : contactSolvers = List.unmodifiable(contactSolvers);

  final BiomechanicsSettings settings;
  final List<MultiBodyContactSolver> contactSolvers;
  final List<SoftBodyBody> _bodies = [];
  double _accumulator = 0;
  bool _disposed = false;

  List<SoftBodyBody> get bodies => List.unmodifiable(_bodies);
  bool get isDisposed => _disposed;

  void addBody(SoftBodyBody body) {
    _ensureActive();
    if (_bodies.any((existing) => existing.id == body.id)) {
      throw ArgumentError('Duplicate body id: ${body.id}');
    }
    _bodies.add(body);
  }

  bool removeBody(String id) {
    _ensureActive();
    final index = _bodies.indexWhere((body) => body.id == id);
    if (index < 0) return false;
    _bodies.removeAt(index);
    return true;
  }

  BiomechanicsFrameStats advance(double frameDelta) {
    _ensureActive();
    if (!frameDelta.isFinite || frameDelta < 0) {
      throw ArgumentError.value(frameDelta, 'frameDelta');
    }
    final accepted = frameDelta.clamp(0.0, settings.maxFrameDelta).toDouble();
    final dropped = frameDelta - accepted;
    _accumulator += accepted;
    var steps = 0;
    final contactStats = <ContactStats>[];

    while (_accumulator >= settings.fixedTimeStep &&
        steps < settings.maxSubSteps) {
      final dt = settings.fixedTimeStep;
      for (final body in _bodies) {
        body.integrate(settings.gravity, dt);
      }
      for (final body in _bodies) {
        body.solveConstraints(
          dt,
          iterations: settings.constraintIterations,
        );
      }
      for (final solver in contactSolvers) {
        for (var a = 0; a < _bodies.length; a++) {
          for (var b = a + 1; b < _bodies.length; b++) {
            contactStats.add(solver.solve(
              _bodies[a],
              _bodies[b],
              iterations: 2,
            ));
          }
        }
      }
      _accumulator -= dt;
      steps++;
    }

    var remainingDropped = dropped;
    if (_accumulator >= settings.fixedTimeStep) {
      final retained = _accumulator % settings.fixedTimeStep;
      remainingDropped += _accumulator - retained;
      _accumulator = retained;
    }
    return BiomechanicsFrameStats(
      subSteps: steps,
      droppedTime: remainingDropped,
      contactStats: List.unmodifiable(contactStats),
    );
  }

  double get interpolationAlpha =>
      (_accumulator / settings.fixedTimeStep).clamp(0.0, 1.0).toDouble();

  void reset() {
    _ensureActive();
    _accumulator = 0;
    for (final body in _bodies) {
      for (final node in body.nodes) {
        node.velocity = Vec3.zero;
      }
    }
  }

  void dispose() {
    _disposed = true;
    _accumulator = 0;
    _bodies.clear();
  }

  void _ensureActive() {
    if (_disposed) throw StateError('BiomechanicsEngine is disposed');
  }
}
