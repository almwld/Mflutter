# Biomechanics runtime

A renderer-agnostic, non-explicit human-motion and soft-body simulation foundation
for Mudabbir. It is not a medical-grade tissue model and it does not provide a
full articulated human rig or a 3D renderer.

## Runtime layers

- `math/vec3.dart`: immutable vector math without extra package dependencies.
- `collision/spatial_hash_grid.dart`: collision-safe 3D cell keys and neighbor
  queries across all cells intersecting the requested radius.
- `collision/contact_solver.dart`: broad-phase vertex proximity and symmetric,
  inverse-mass-weighted non-penetration correction with bounded tangential
  velocity damping.
- `soft_body/soft_body_body.dart`: damped particle integration, XPBD distance
  constraints, and tetrahedral signed-volume constraints.
- `core/biomechanics_engine.dart`: fixed-step accumulator, bounded catch-up,
  multi-body orchestration, interpolation alpha, reset and disposal.

## Minimal integration

```dart
final body = SoftBodyBody(
  id: 'prop-soft-body',
  nodes: [
    SoftBodyNode(position: const Vec3(0, 0, 0), inverseMass: 0),
    SoftBodyNode(position: const Vec3(0.2, 0, 0)),
  ],
  distanceConstraints: [
    DistanceConstraint(a: 0, b: 1, restLength: 0.2, compliance: 1e-7),
  ],
);

final engine = BiomechanicsEngine(
  contactSolvers: [
    MultiBodyContactSolver(contactDistance: 0.015),
  ],
)..addBody(body);

// Call from a ticker using elapsed frame delta.
final stats = engine.advance(frameDeltaSeconds);
final alpha = engine.interpolationAlpha;

// Dispose with the owning scene/controller.
engine.dispose();
```

## Important integration contracts

1. Mesh vertices are not renderer buffers. Keep simulation state separate, then
   copy/interpolate positions into the renderer-owned buffer.
2. Build tetrahedra and distance constraints from a validated mesh topology;
   arbitrary four vertices do not form a meaningful volume element.
3. Use consistent world units (prefer meters), positive finite masses, and a
   contact distance appropriate to the model scale.
4. The solver is CPU/Dart and has not yet been profiled on target devices. Do not
   claim 60 FPS or thousands of deforming vertices until device profiling.
5. This module is a foundation: production character animation still needs a
   rig adapter, inverse kinematics, collision primitives/triangle contacts,
   self-collision policy, and renderer-specific skinning/deformation.
