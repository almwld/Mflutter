import 'package:flutter/material.dart';

enum CelestialKind { star, planet, moon, sun }

class CelestialBody {
  final String id;
  final String nameAr;
  final String nameEn;
  final CelestialKind kind;
  final double azimuth;
  final double altitude;
  /// Apparent visual magnitude. Smaller/negative values are brighter.
  final double magnitude;
  /// Geocentric distance in AU for solar-system bodies.
  final double? distanceAu;
  /// Approximate catalog distance for stars; null when not curated.
  final double? distanceLightYears;
  /// Illuminated fraction in [0, 1], currently populated for the Moon.
  final double? illuminatedFraction;
  /// Phase angle at the body in degrees; populated for the Moon.
  final double? phaseAngleDegrees;
  final String? phaseName;
  final int colorValue;
  final String? verse;
  final String? reference;
  final String note;

  const CelestialBody({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.kind,
    required this.azimuth,
    required this.altitude,
    required this.magnitude,
    this.distanceAu,
    this.distanceLightYears,
    this.illuminatedFraction,
    this.phaseAngleDegrees,
    this.phaseName,
    required this.colorValue,
    this.verse,
    this.reference,
    required this.note,
  });

  Color get color => Color(colorValue);
  bool get isAboveHorizon => altitude >= -2;
}
