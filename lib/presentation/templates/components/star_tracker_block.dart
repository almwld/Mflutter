import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/themes/mudabbir_design_tokens.dart';
import 'base_universal_block.dart';
import 'block_event_bus.dart';
import 'block_event_scope.dart';
import 'celestial_engine.dart';

/// Local sensor-guided sky chart. This is not a camera AR overlay or a precision ephemeris.
class StarTrackerBlock extends BaseUniversalBlock {
  const StarTrackerBlock({
    super.key,
    required super.title,
    required super.data,
    super.styleHints,
  });

  @override
  Widget buildBlockContent(BuildContext context) => _StarTrackerContent(
        data: data,
        blockId: data['_canvas_block_id'] is String
            ? data['_canvas_block_id'] as String
            : '',
      );
}

class _StarTrackerContent extends StatefulWidget {
  const _StarTrackerContent({required this.data, required this.blockId});
  final Map<String, dynamic> data;
  final String blockId;

  @override
  State<_StarTrackerContent> createState() => _StarTrackerContentState();
}

class _StarTrackerContentState extends State<_StarTrackerContent> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  StreamSubscription<MagnetometerEvent>? _magnetometerSub;
  BlockEventBus? _eventBus;
  double? _latitude;
  double? _longitude;
  double _pitch = 0, _roll = 0, _heading = 0;
  double _magX = 0, _magY = 0, _magZ = 0;
  double _accX = 0, _accY = 0, _accZ = 9.81;
  String? _status;
  String? _selectedStarId;
  DateTime _now = DateTime.now().toUtc();
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _latitude = _finiteNumber(widget.data['latitude'], -90, 90);
    _longitude = _finiteNumber(widget.data['longitude'], -180, 180);
    if (_latitude == null || _longitude == null) {
      _status = 'فعّل الموقع أو مرّر إحداثيات الراصد لاحتساب مواضع النجوم.';
    }
    _accelerometerSub = accelerometerEventStream().listen((event) {
      if (!mounted) return;
      _accX = event.x; _accY = event.y; _accZ = event.z;
      _updateOrientation();
    }, onError: (_) {
      if (mounted) setState(() => _status = 'حساس التسارع غير متاح على هذا الجهاز.');
    });
    _magnetometerSub = magnetometerEventStream().listen((event) {
      if (!mounted) return;
      _magX = event.x; _magY = event.y; _magZ = event.z;
      _updateOrientation();
    }, onError: (_) {
      if (mounted) setState(() => _status = 'حساس المجال المغناطيسي غير متاح؛ الاتجاه تقريبي.');
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now().toUtc());
    });
  }

  double? _finiteNumber(Object? value, double min, double max) {
    if (value is! num || !value.isFinite || value < min || value > max) return null;
    return value.toDouble();
  }

  void _updateOrientation() {
    final norm = math.sqrt(_accX * _accX + _accY * _accY + _accZ * _accZ);
    if (norm < 0.1) return;
    final ax = _accX / norm, ay = _accY / norm, az = _accZ / norm;
    final pitch = math.atan2(-ax, math.sqrt(ay * ay + az * az));
    final roll = math.atan2(ay, az);
    final xh = _magX * math.cos(pitch) + _magZ * math.sin(pitch);
    final yh = _magX * math.sin(roll) * math.sin(pitch) +
        _magY * math.cos(roll) - _magZ * math.sin(roll) * math.cos(pitch);
    final heading = (math.atan2(-yh, xh) * 180 / math.pi + 360) % 360;
    if ((pitch - _pitch).abs() < 0.008 &&
        (roll - _roll).abs() < 0.008 &&
        (heading - _heading).abs() < 0.8) return;
    setState(() { _pitch = pitch; _roll = roll; _heading = heading; });
  }

  Future<void> _requestLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _status = 'لم يُمنح إذن الموقع؛ يمكنك إدخال الإحداثيات في بيانات الكتلة.');
        return;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _status = 'خدمة الموقع معطلة؛ فعّلها أو أدخل الإحداثيات يدويًا.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _status = 'تم استخدام موقع الجهاز محليًا لحساب مواضع النجوم.';
      });
    } catch (_) {
      if (mounted) setState(() => _status = 'تعذر تحديد الموقع. يمكن متابعة العرض بإحداثيات محلية.');
    }
  }

  void _selectStar(CelestialStar star) {
    HapticFeedback.selectionClick();
    setState(() => _selectedStarId = star.id);
    final target = widget.data['target_block_id'];
    _eventBus?.publish(BlockEvent(
      type: 'selection_changed',
      sourceBlockId: widget.blockId,
      targetBlockId: target is String ? target : null,
      payload: <String, Object?>{'selection_id': star.id, 'label': star.name, 'source': 'star_tracker_block'},
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventBus = BlockEventScope.maybeOf(context);
  }

  @override
  void dispose() {
    unawaited(_accelerometerSub?.cancel());
    unawaited(_magnetometerSub?.cancel());
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lat = _latitude, lon = _longitude;
    final visible = <_ProjectedStar>[];
    if (lat != null && lon != null) {
      for (final star in CelestialEngine.brightStars) {
        final horizontal = CelestialEngine.toHorizontal(
          star: star, utc: _now, latitudeDegrees: lat, longitudeDegrees: lon,
        );
        if (horizontal.altitudeDegrees < 0) continue;
        final deltaAz = ((horizontal.azimuthDegrees - _heading + 540) % 360) - 180;
        final deltaAlt = horizontal.altitudeDegrees - (-_pitch * 180 / math.pi);
        if (deltaAz.abs() > 35 || deltaAlt.abs() > 35) continue;
        visible.add(_ProjectedStar(star: star, x: 0.5 + deltaAz / 70, y: 0.5 - deltaAlt / 70));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        const Icon(Icons.explore_outlined, color: MudabbirDesignTokens.cyan, size: 19),
        const SizedBox(width: 8),
        const Expanded(child: Text('مرصد السماء المحلي', textDirection: TextDirection.rtl)),
        Text('${_heading.toStringAsFixed(0)}°', style: Theme.of(context).textTheme.labelMedium),
      ]),
      const SizedBox(height: 8),
      SizedBox(
        height: 250,
        child: RepaintBoundary(
          child: GestureDetector(
            onTapUp: (details) {
              if (visible.isEmpty) return;
              final local = details.localPosition;
              final chartWidth = (MediaQuery.sizeOf(context).width - 48).clamp(180.0, 1200.0);
              const chartHeight = 250.0;
              _ProjectedStar? nearest;
              var best = 26.0;
              for (final item in visible) {
                final dx = item.x * chartWidth - local.dx;
                final dy = item.y * chartHeight - local.dy;
                final distance = math.sqrt(dx * dx + dy * dy);
                if (distance < best) { best = distance; nearest = item; }
              }
              if (nearest != null) _selectStar(nearest.star);
            },
            child: CustomPaint(
              painter: _CelestialPainter(stars: visible, heading: _heading, pitch: _pitch, selectedId: _selectedStarId),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      if (lat == null || lon == null)
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _requestLocation,
            icon: const Icon(Icons.my_location, size: 17),
            label: const Text('تحديد موقع الراصد'),
          ),
        )
      else
        Text('الموقع: ${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}° · UTC ${_now.toIso8601String().substring(11, 19)}',
            textDirection: TextDirection.ltr, style: Theme.of(context).textTheme.labelSmall),
      Text(_selectedStarId == null
          ? 'كتالوج نجوم ساطعة تقريبي وإسقاط موجّه بالحساسات؛ ليس عرض كاميرا AR ولا تقويمًا فلكيًا عالي الدقة.'
          : 'العنصر المحدد: $_selectedStarId',
        textDirection: TextDirection.rtl, style: Theme.of(context).textTheme.bodySmall),
      if (_status != null)
        Text(_status!, textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MudabbirDesignTokens.cyan)),
    ]);
  }
}

class _ProjectedStar {
  const _ProjectedStar({required this.star, required this.x, required this.y});
  final CelestialStar star;
  final double x, y;
}

class _CelestialPainter extends CustomPainter {
  const _CelestialPainter({required this.stars, required this.heading, required this.pitch, required this.selectedId});
  final List<_ProjectedStar> stars;
  final double heading, pitch;
  final String? selectedId;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      Paint()..color = const Color(0xFF050B18),
    );
    final grid = Paint()..color = MudabbirDesignTokens.glassBorder.withOpacity(0.65)
      ..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final center = Paint()..color = MudabbirDesignTokens.cyan.withOpacity(0.45)..strokeWidth = 1;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), center);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), center);
    for (final item in stars) {
      final position = Offset(item.x * size.width, item.y * size.height);
      final selected = item.star.id == selectedId;
      final radius = (3.2 - item.star.magnitude * 0.35).clamp(2.0, 5.0).toDouble();
      canvas.drawCircle(position, selected ? radius + 5 : radius + 2,
        Paint()..color = (selected ? MudabbirDesignTokens.goldBright : MudabbirDesignTokens.cyan).withOpacity(0.13));
      canvas.drawCircle(position, selected ? radius + 1 : radius,
        Paint()..color = selected ? MudabbirDesignTokens.goldBright : Colors.white);
      final label = TextPainter(
        text: TextSpan(text: item.star.name, style: TextStyle(
          color: selected ? MudabbirDesignTokens.goldBright : const Color(0xFFB8C5D6),
          fontSize: 10, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
        textDirection: TextDirection.rtl, maxLines: 1,
      )..layout(maxWidth: size.width * 0.42);
      label.paint(canvas, Offset(
        (position.dx + 7).clamp(0.0, size.width - label.width).toDouble(),
        (position.dy - 16).clamp(0.0, size.height - label.height).toDouble()));
    }
    final hud = TextPainter(
      text: TextSpan(text: 'AZ ${heading.toStringAsFixed(0)}° · ALT ${(-pitch * 180 / math.pi).toStringAsFixed(0)}°',
        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    hud.paint(canvas, Offset(8, size.height - hud.height - 8));
  }

  @override
  bool shouldRepaint(covariant _CelestialPainter oldDelegate) =>
      oldDelegate.heading != heading || oldDelegate.pitch != pitch ||
      oldDelegate.selectedId != selectedId || !identical(oldDelegate.stars, stars);
}
