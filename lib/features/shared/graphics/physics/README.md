# Mudabbir Physics Engine

The graphics physics module is a renderer-independent, fixed-step 3D particle
simulation intended for deformable educational and interactive scenes.

## Public API

Import `physics/physics_engine.dart` and construct a `PhysicsWorld`.
Each `SoftBody` stores packed world-space XYZ coordinates in `Float64List`
buffers. A zero inverse mass pins a particle. Add `DistanceConstraint`
instances for mesh edges, diagonals, or shape-preservation links. Use
`TetraVolumeConstraint` for tetrahedral cells when volume retention is required.

```dart
final body = SoftBody(
  positions: verticesWorldSpace,
  inverseMasses: inverseMasses,
  radii: collisionRadii,
  constraints: meshEdgeConstraints,
);
final world = PhysicsWorld(
  fixedTimeStep: 1 / 120,
  constraintIterations: 8,
);
world.addBody(body);
world.advance(frameDelta);
final deformedVertices = body.positions;
```

## Pipeline

1. Integrate velocities and gravity at a fixed timestep.
2. Build swept particle AABBs in a spatial hash.
3. Generate unique inter-body candidate pairs.
4. Resolve swept-sphere contacts using closest relative trajectories.
5. Project distance and tetrahedral volume constraints using inverse-mass weighting.
6. Reconstruct velocities and apply restitution impulses.

The broadphase uses a bounded spatial hash. Exceptionally long sweeps use a
conservative all-pairs fallback instead of silently dropping candidates.
Frame catch-up is capped by `maxSubSteps`.

## Important accuracy boundary

This version is a **particle-sampled soft-body solver**. CCD is performed
between particle collision spheres, not between arbitrary triangle pairs.
For production-quality dense meshes, add a triangle BVH, triangle-triangle
narrowphase, contact manifolds, friction constraints, and volume/tetrahedral
constraints before describing the result as exact mesh interpenetration
resolution. Input positions are world-space; apply skeletal transforms before
submitting them to the solver.

## Interactive preview

The universal template renderer exposes `physics_sandbox_block`. It runs two
spring-constrained soft bodies through the same engine and accepts pointer
forces. It is a diagnostic preview, not a benchmark or a promise of a fixed
frame rate on every device.
