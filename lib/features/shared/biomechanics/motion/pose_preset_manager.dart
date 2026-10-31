import '../math/vec3.dart';

class JointPose {
  const JointPose({
    this.translation = Vec3.zero,
    this.rotationEuler = Vec3.zero,
  });
  final Vec3 translation;
  final Vec3 rotationEuler;

  static JointPose blend(JointPose a, JointPose b, double t) => JointPose(
        translation: Vec3.lerp(a.translation, b.translation, t),
        rotationEuler: Vec3.lerp(a.rotationEuler, b.rotationEuler, t),
      );
}

class PosePreset {
  PosePreset({required this.id, required Map<String, JointPose> joints})
      : joints = Map.unmodifiable(joints) {
    if (id.isEmpty || joints.isEmpty) {
      throw ArgumentError('Pose preset needs an id and joint transforms');
    }
  }
  final String id;
  final Map<String, JointPose> joints;
}

class PosePresetManager {
  PosePresetManager([Iterable<PosePreset> presets = const []]) {
    for (final preset in presets) {
      register(preset);
    }
  }

  final Map<String, PosePreset> _presets = {};

  void register(PosePreset preset) {
    if (_presets.containsKey(preset.id)) {
      throw ArgumentError('Duplicate pose preset: ${preset.id}');
    }
    _presets[preset.id] = preset;
  }

  PosePreset? operator [](String id) => _presets[id];
  List<String> get ids => List.unmodifiable(_presets.keys);

  /// Blends only joints present in either pose; absent joints use identity.
  PosePreset blend(String fromId, String toId, double progress) {
    final from = _presets[fromId];
    final to = _presets[toId];
    if (from == null || to == null) {
      throw ArgumentError('Unknown pose preset: $fromId / $toId');
    }
    final t = progress.clamp(0.0, 1.0).toDouble();
    final names = <String>{...from.joints.keys, ...to.joints.keys};
    return PosePreset(
      id: '${fromId}_to_${toId}_${t.toStringAsFixed(3)}',
      joints: {
        for (final name in names)
          name: JointPose.blend(
            from.joints[name] ?? const JointPose(),
            to.joints[name] ?? const JointPose(),
            t,
          ),
      },
    );
  }

  static PosePresetManager standard() => PosePresetManager([
        PosePreset(id: 'standing', joints: {
          'pelvis': JointPose(),
          'spine': JointPose(),
          'head': JointPose(),
          'leftUpperArm': JointPose(),
          'rightUpperArm': JointPose(),
          'leftUpperLeg': JointPose(),
          'rightUpperLeg': JointPose(),
        }),
        PosePreset(id: 'seated', joints: {
          'pelvis': JointPose(translation: Vec3(0, -.35, 0)),
          'spine': JointPose(rotationEuler: Vec3(.12, 0, 0)),
          'leftUpperLeg': JointPose(rotationEuler: Vec3(-1.25, 0, 0)),
          'rightUpperLeg': JointPose(rotationEuler: Vec3(-1.25, 0, 0)),
        }),
        PosePreset(id: 'leaning', joints: {
          'pelvis': JointPose(translation: Vec3(0, 0, .08)),
          'spine': JointPose(rotationEuler: Vec3(.22, 0, 0)),
          'head': JointPose(rotationEuler: Vec3(-.08, 0, 0)),
        }),
        PosePreset(id: 'embrace', joints: {
          'spine': JointPose(rotationEuler: Vec3(.04, 0, 0)),
          'leftUpperArm': JointPose(rotationEuler: Vec3(0, 0, -.85)),
          'rightUpperArm': JointPose(rotationEuler: Vec3(0, 0, .85)),
        }),
        PosePreset(id: 'sideLying', joints: {
          'pelvis': JointPose(rotationEuler: Vec3(0, 0, 1.5708)),
          'spine': JointPose(rotationEuler: Vec3(0, 0, 1.5708)),
          'head': JointPose(rotationEuler: Vec3(0, 0, 1.5708)),
        }),
      ]);
}
