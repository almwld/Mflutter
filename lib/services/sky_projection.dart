import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Gnomonic projection from local horizontal coordinates to the camera view.
/// Horizontal FOV is calibrated by the user; vertical FOV follows the viewport
/// aspect ratio, matching a rectilinear camera lens.
class SkyProjection {
  const SkyProjection._();

  static Offset? project({
    required double azimuth,
    required double altitude,
    required double heading,
    required double pitch,
    required double roll,
    required double horizontalFov,
    required Size viewport,
    double horizonCutoff = -2,
  }) {
    if (!azimuth.isFinite ||
        !altitude.isFinite ||
        !heading.isFinite ||
        !pitch.isFinite ||
        !roll.isFinite ||
        !horizontalFov.isFinite ||
        viewport.width <= 0 ||
        viewport.height <= 0 ||
        horizontalFov <= 1 ||
        horizontalFov >= 179 ||
        altitude < horizonCutoff) {
      return null;
    }

    final deltaAz = _signedDegrees(azimuth - heading);
    final deltaAlt = altitude - pitch;
    // Gnomonic projection diverges at 90 degrees from the optical axis.
    if (deltaAz.abs() >= 89 || deltaAlt.abs() >= 89) return null;

    final horizontalHalf = horizontalFov * math.pi / 360;
    final verticalFov = 2 * math.atan(
      math.tan(horizontalHalf) * viewport.height / viewport.width,
    );
    final verticalHalf = verticalFov / 2;
    final xTangent = math.tan(deltaAz * math.pi / 180);
    final yTangent = math.tan(deltaAlt * math.pi / 180);
    final normalizedX = xTangent / math.tan(horizontalHalf);
    final normalizedY = yTangent / math.tan(verticalHalf);

    final rollRadians = roll * math.pi / 180;
    final rotatedX = normalizedX * math.cos(rollRadians) -
        normalizedY * math.sin(rollRadians);
    final rotatedY = normalizedX * math.sin(rollRadians) +
        normalizedY * math.cos(rollRadians);
    final point = Offset(
      viewport.width * (0.5 + rotatedX * 0.5),
      viewport.height * (0.5 - rotatedY * 0.5),
    );
    if (!point.dx.isFinite || !point.dy.isFinite) return null;
    if (point.dx < -36 ||
        point.dx > viewport.width + 36 ||
        point.dy < -36 ||
        point.dy > viewport.height + 36) {
      return null;
    }
    return point;
  }

  static double _signedDegrees(double value) {
    final normalized = ((value % 360) + 360) % 360;
    return normalized > 180 ? normalized - 360 : normalized;
  }
}
