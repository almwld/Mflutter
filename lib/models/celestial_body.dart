import 'package:flutter/material.dart';

enum CelestialKind { star, planet, moon, sun }

class CelestialBody {
  final String id;
  final String nameAr;
  final String nameEn;
  final CelestialKind kind;
  final double azimuth;
  final double altitude;
  final double magnitude;
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
    required this.colorValue,
    this.verse,
    this.reference,
    required this.note,
  });

  Color get color => Color(colorValue);
  bool get isAboveHorizon => altitude >= -2;
}
