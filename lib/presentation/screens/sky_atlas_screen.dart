import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/celestial_body.dart';
import '../../services/astronomy_service.dart';
import '../../services/sky_sensor_service.dart';
import '../../services/sky_projection.dart';

class SkyAtlasScreen extends StatefulWidget {
  const SkyAtlasScreen({super.key});

  @override
  State<SkyAtlasScreen> createState() => _SkyAtlasScreenState();
}

class _SkyAtlasScreenState extends State<SkyAtlasScreen>
    with WidgetsBindingObserver {
  static const _gold = Color(0xFFF2DC98);
  static const _filters = ['الكل', 'نجم', 'كوكب', 'القمر', 'الشمس'];
  static const _constellationStars = <String, List<String>>{
    'الجبار': ['betelgeuse', 'bellatrix', 'rigel', 'saiph'],
    'الدب الأكبر': ['dubhe', 'merak', 'phecda', 'megrez', 'alioth', 'mizar', 'alkaid'],
    'ذات الكرسي': ['schedar', 'caph', 'gamma_cas', 'ruchbah', 'segin'],
    'الدجاجة': ['deneb', 'sadr', 'albireo', 'gienah'],
    'القيثارة': ['vega', 'sheliak', 'sulafat'],
    'العقاب': ['altair', 'tarazed', 'alshain'],
    'الثور': ['aldebaran', 'elnath'],
    'الكلب الأكبر': ['sirius', 'wezen', 'adhara', 'aludra'],
    'الأسد': ['regulus', 'algieba', 'denebola'],
    'التوأمان': ['castor', 'pollux'],
    'المرأة المسلسلة': ['alpheratz', 'mirach', 'almach'],
    'العقرب': ['antares', 'shaula', 'sargas'],
    'الصليب الجنوبي': ['acrux', 'mimosa', 'gacrux'],
  };
  static const _constellationEdges = <String, List<(String, String)>>{
    'الجبار': [('betelgeuse', 'bellatrix'), ('bellatrix', 'rigel'), ('rigel', 'saiph'), ('saiph', 'betelgeuse'), ('betelgeuse', 'rigel'), ('alnilam', 'mintaka'), ('alnilam', 'alnitak')],
    'الدب الأكبر': [('dubhe', 'merak'), ('merak', 'phecda'), ('phecda', 'megrez'), ('megrez', 'dubhe'), ('megrez', 'alioth'), ('alioth', 'mizar'), ('mizar', 'alkaid')],
    'ذات الكرسي': [('schedar', 'caph'), ('caph', 'gamma_cas'), ('gamma_cas', 'ruchbah'), ('ruchbah', 'segin')],
    'الدجاجة': [('deneb', 'sadr'), ('sadr', 'albireo'), ('sadr', 'gienah')],
    'القيثارة': [('vega', 'sheliak'), ('sheliak', 'sulafat')],
    'العقاب': [('altair', 'tarazed'), ('altair', 'alshain')],
    'الثور': [('aldebaran', 'elnath')],
    'الكلب الأكبر': [('sirius', 'wezen'), ('wezen', 'adhara'), ('adhara', 'aludra')],
    'الأسد': [('regulus', 'algieba'), ('algieba', 'denebola')],
    'التوأمان': [('castor', 'pollux')],
    'المرأة المسلسلة': [('alpheratz', 'mirach'), ('mirach', 'almach')],
    'العقرب': [('antares', 'shaula'), ('shaula', 'sargas')],
    'الصليب الجنوبي': [('acrux', 'mimosa'), ('mimosa', 'gacrux')],
  };

  final SkySensorService _sensors = SkySensorService();
  StreamSubscription<SkyOrientation>? _orientationSubscription;
  SkyOrientation _orientation = SkyOrientation.unavailable;
  CameraController? _cameraController;
  bool _cameraRequested = false;
  bool _cameraInitializing = false;
  bool _locating = false;
  double? _latitude;
  double? _longitude;
  double _timeOffsetHours = 0;
  double _horizontalFov = 65;
  Set<String> _selectedConstellations = _constellationStars.keys.toSet();
  String _filter = 'الكل';
  String? _selectedId;
  String? _cameraError;
  List<CelestialBody> _bodies = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sensors.start();
    _orientationSubscription = _sensors.stream.listen((value) {
      if (mounted) setState(() => _orientation = value);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _orientationSubscription?.cancel();
    _sensors.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_stopCamera());
    } else if (state == AppLifecycleState.resumed && _cameraRequested) {
      unawaited(_initializeCamera());
    }
  }

  DateTime get _selectedUtc => DateTime.now().toUtc().add(
        Duration(minutes: (_timeOffsetHours * 60).round()),
      );

  List<CelestialBody> get _visibleBodies => _bodies.where((body) {
        switch (_filter) {
          case 'نجم':
            return body.kind == CelestialKind.star;
          case 'كوكب':
            return body.kind == CelestialKind.planet;
          case 'القمر':
            return body.kind == CelestialKind.moon;
          case 'الشمس':
            return body.kind == CelestialKind.sun;
          default:
            return true;
        }
      }).toList(growable: false);

  void _recalculate() {
    final lat = _latitude;
    final lon = _longitude;
    _bodies = lat == null || lon == null
        ? const []
        : AstronomyService.calculate(
            utc: _selectedUtc,
            latitude: lat,
            longitude: lon,
          );
  }

  Future<void> _requestLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message('فعّل خدمة الموقع في الهاتف ثم أعد المحاولة.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _message('لم يُمنح مُدَبِّر إذن الوصول إلى الموقع.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _recalculate();
      });
    } catch (error) {
      _message('تعذر تحديد الموقع: $error');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameraRequested) {
      _cameraRequested = false;
      await _stopCamera();
    } else {
      _cameraRequested = true;
      await _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameraInitializing || _cameraController != null) return;
    _cameraInitializing = true;
    try {
      final cameras = await availableCameras();
      final back = cameras.where(
        (item) => item.lensDirection == CameraLensDirection.back,
      );
      if (back.isEmpty) {
        throw CameraException('camera-not-found', 'لا توجد كاميرا خلفية.');
      }
      final controller = CameraController(
        back.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted || !_cameraRequested) {
        await controller.dispose();
        return;
      }
      setState(() {
        _cameraController = controller;
        _cameraError = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _cameraError = error.toString();
          _cameraRequested = false;
        });
        _message('تعذر تشغيل الكاميرا. تحقق من الإذن: $error');
      }
    } finally {
      _cameraInitializing = false;
    }
  }

  Future<void> _stopCamera() async {
    final old = _cameraController;
    _cameraController = null;
    if (mounted) setState(() {});
    await old?.dispose();
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  void _selectAt(Offset point, Size size) {
    CelestialBody? nearest;
    var distanceLimit = 34.0;
    for (final body in _visibleBodies) {
      final projected = _projectBody(body, size, _orientation, _horizontalFov);
      if (projected == null) continue;
      final distance = (projected - point).distance;
      if (distance < distanceLimit) {
        distanceLimit = distance;
        nearest = body;
      }
    }
    final selected = nearest;
    if (selected == null) return;
    setState(() => _selectedId = selected.id);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101D34),
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selected.nameAr, style: const TextStyle(
                  color: _gold, fontFamily: 'Amiri', fontSize: 25,
                )),
                Text(selected.nameEn, textDirection: TextDirection.ltr,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 14),
                Wrap(spacing: 18, runSpacing: 8, children: [
                  _detail('السمت', selected.azimuth.toStringAsFixed(1) + '°'),
                  _detail('الارتفاع', selected.altitude.toStringAsFixed(1) + '°'),
                  _detail('القدر الظاهري', selected.magnitude.toStringAsFixed(2)),
                  if (selected.distanceAu != null)
                    _detail('المسافة', _formatAu(selected.distanceAu!)),
                  if (selected.distanceLightYears != null)
                    _detail('المسافة التقريبية', '~${selected.distanceLightYears!.toStringAsFixed(1)} سنة ضوئية'),
                  if (selected.illuminatedFraction != null)
                    _detail('الجزء المضاء', '${(selected.illuminatedFraction! * 100).round()}%'),
                  if (selected.phaseName != null)
                    _detail('طور القمر', selected.phaseName!),
                  if (selected.phaseAngleDegrees != null)
                    _detail('زاوية الطور', '${selected.phaseAngleDegrees!.toStringAsFixed(1)}°'),
                ]),
                const SizedBox(height: 14),
                if (selected.verse != null) ...[
                  Text(selected.verse!, style: const TextStyle(
                    color: Colors.white, fontFamily: 'Amiri',
                    fontSize: 23, height: 1.8,
                  )),
                  Text(selected.reference ?? '', style: const TextStyle(
                    color: _gold, fontFamily: 'Amiri',
                  )),
                  const SizedBox(height: 10),
                ],
                Text(selected.note, style: const TextStyle(
                  color: Colors.white70, fontFamily: 'Amiri',
                  fontSize: 15, height: 1.6,
                )),
                const SizedBox(height: 8),
                const Text(
                  'الآية نص قرآني مستقل عن الحساب الفلكي؛ لا تُنسب إليها إحداثيات أو نتائج علمية غير منصوص عليها.',
                  style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedId = null);
    });
  }

  String _formatAu(double au) {
    if (au < 0.01) return '${(au * 149597870.7).round()} كم';
    return '${(au * 149.5978707).toStringAsFixed(2)} مليون كم';
  }

  Widget _detail(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final camera = _cameraController;
    final cameraReady = camera != null && camera.value.isInitialized;
    return Scaffold(
      backgroundColor: const Color(0xFF050B1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF081329),
        foregroundColor: _gold,
        title: const Text('مرصد السماء', style: TextStyle(
          fontFamily: 'Amiri', fontWeight: FontWeight.bold,
        )),
        actions: [
          IconButton(
            tooltip: 'دقة الحساب والمعايرة',
            onPressed: _showAccuracyInfo,
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatusBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _selectAt(details.localPosition, size),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (cameraReady) CameraPreview(camera),
                        if (cameraReady)
                          Container(color: Colors.black.withOpacity(.18)),
                        CustomPaint(
                          painter: _SkyPainter(
                            bodies: _visibleBodies,
                            orientation: _orientation,
                            selectedId: _selectedId,
                            transparentBackground: cameraReady,
                            horizontalFov: _horizontalFov,
                            selectedConstellations: _selectedConstellations,
                          ),
                        ),
                        if (_latitude == null)
                          Center(
                            child: Container(
                              margin: const EdgeInsets.all(24),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xE6101D34),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _gold.withOpacity(.35)),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.my_location_rounded, color: _gold, size: 30),
                                  SizedBox(height: 10),
                                  Text('حدد موقع الرصد أولاً', style: TextStyle(
                                    color: _gold, fontFamily: 'Amiri', fontSize: 20,
                                  )),
                                  SizedBox(height: 5),
                                  Text(
                                    'تُحسب مواقع الأجرام من إحداثياتك ووقت الرصد، ولا نستخدم موقعاً افتراضياً.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_cameraError != null && !cameraReady)
                          Positioned(
                            top: 12, left: 12, right: 12,
                            child: Text('الكاميرا غير متاحة: ' + _cameraError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final location = _latitude == null
        ? 'الموقع غير محدد'
        : _latitude!.toStringAsFixed(3) + ', ' + _longitude!.toStringAsFixed(3);
    final heading = _orientation.hasHeading
        ? _orientation.heading.toStringAsFixed(0) + '°'
        : '—°';
    final tilt = _orientation.hasTilt
        ? 'ميل ' + _orientation.pitch.toStringAsFixed(0) + '°'
        : 'الميل غير متاح';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          const Icon(Icons.explore_rounded, color: Color(0xFF8ED8E8), size: 19),
          const SizedBox(width: 5),
          Text('الاتجاه ' + heading,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(width: 8),
          Text(tilt, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const Spacer(),
          Flexible(
            child: Text(location, overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(color: _gold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    final time = _selectedUtc;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0A1428),
        border: Border(top: BorderSide(color: Color(0x223E6688))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _locating ? null : _requestLocation,
                icon: _locating
                    ? const SizedBox(width: 15, height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location_rounded, size: 17),
                label: Text(_latitude == null ? 'تحديد موقعي' : 'تحديث الموقع'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _toggleCamera,
                icon: Icon(_cameraRequested
                    ? Icons.videocam_off_rounded : Icons.videocam_rounded, size: 17),
                label: Text(_cameraRequested ? 'إيقاف الكاميرا' : 'عرض الكاميرا'),
              ),
            ),
          ]),
          const SizedBox(height: 9),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _filters.map((filter) {
              final active = _filter == filter;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 7),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: active,
                  onSelected: (_) => setState(() => _filter = filter),
                  selectedColor: _gold.withOpacity(.2),
                  backgroundColor: Colors.white.withOpacity(.04),
                  labelStyle: TextStyle(
                    color: active ? _gold : Colors.white60, fontSize: 11,
                  ),
                  side: BorderSide(
                    color: active ? _gold.withOpacity(.65) : Colors.white12,
                  ),
                ),
              );
            }).toList(growable: false)),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 16),
            const SizedBox(width: 6),
            Text('مجال الرؤية ${_horizontalFov.round()}°',
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Expanded(
              child: Slider(
                value: _horizontalFov, min: 35, max: 100, divisions: 65,
                activeColor: const Color(0xFF8ED8E8), inactiveColor: Colors.white12,
                onChanged: (value) => setState(() => _horizontalFov = value),
              ),
            ),
            IconButton(
              tooltip: 'إعادة ضبط مجال الرؤية',
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => _horizontalFov = 65),
              icon: const Icon(Icons.restart_alt, size: 18, color: Colors.white54),
            ),
          ]),
          Row(children: [
            const Icon(Icons.auto_awesome_motion, color: Colors.white54, size: 16),
            const SizedBox(width: 6),
            const Text('الكوكبات', style: TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: _constellationStars.keys.map((name) {
                  final active = _selectedConstellations.contains(name);
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: FilterChip(
                      label: Text(name),
                      selected: active,
                      onSelected: (value) => setState(() {
                        if (value) {
                          _selectedConstellations = {..._selectedConstellations, name};
                        } else {
                          _selectedConstellations = {..._selectedConstellations}..remove(name);
                        }
                      }),
                      selectedColor: const Color(0xFF8ED8E8).withOpacity(.18),
                      backgroundColor: Colors.white.withOpacity(.035),
                      labelStyle: TextStyle(
                        color: active ? const Color(0xFF8ED8E8) : Colors.white54,
                        fontSize: 10,
                      ),
                      side: BorderSide(color: active ? const Color(0xFF8ED8E8).withOpacity(.5) : Colors.white12),
                    ),
                  );
                }).toList(growable: false)),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.history_rounded, color: Colors.white54, size: 17),
            const SizedBox(width: 6),
            const Text('الزمن', style: TextStyle(color: Colors.white70, fontSize: 11)),
            Expanded(
              child: Slider(
                value: _timeOffsetHours,
                min: -24,
                max: 24,
                divisions: 96,
                activeColor: _gold,
                inactiveColor: Colors.white12,
                onChanged: (value) => setState(() {
                  _timeOffsetHours = value;
                  _recalculate();
                }),
              ),
            ),
            Text(_timeOffsetHours.toStringAsFixed(0) + 'h',
                style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ]),
          Text(
            time.toIso8601String().substring(0, 16).replaceFirst('T', ' ') +
                ' UTC  •  ' + _bodies.length.toString() + ' جرم/نجم',
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showAccuracyInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101D34),
        title: const Text('دقة المرصد وحدوده', style: TextStyle(
          color: _gold, fontFamily: 'Amiri',
        )),
        content: const Text(
          'تُحسب الشمس والكواكب باستخدام Meeus وVSOP87، والقمر مع تصحيح اختلاف المنظر الطبوغرافي. يعرض المرصد المسافات المتاحة في الكتالوج والجزء المضاء للقمر. الإسقاط الغنوموني يطابق مجال الرؤية الأفقي الذي تضبطه يدوياً، ويشتق المجال الرأسي من أبعاد الشاشة؛ يلزم ضبطه ليتوافق مع عدسة الهاتف. لا يُطبق الانكسار الجوي أو تصحيح الانحراف المغناطيسي المحلي، وهذه أداة استكشاف وليست جهاز ملاحة أو مرصداً احترافياً.'
          style: TextStyle(color: Colors.white70, fontFamily: 'Amiri', height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً')),
        ],
      ),
    );
  }
}

Offset? _projectBody(
  CelestialBody body,
  Size size,
  SkyOrientation orientation,
  double horizontalFov,
) {
  if (!orientation.hasHeading || !orientation.hasTilt) return null;
  return SkyProjection.project(
    azimuth: body.azimuth,
    altitude: body.altitude,
    heading: orientation.heading,
    pitch: orientation.pitch,
    roll: orientation.roll,
    horizontalFov: horizontalFov,
    viewport: size,
  );
}

class _SkyPainter extends CustomPainter {
  final List<CelestialBody> bodies;
  final SkyOrientation orientation;
  final String? selectedId;
  final bool transparentBackground;
  final double horizontalFov;
  final Set<String> selectedConstellations;

  static final List<Offset> _backgroundStars = List<Offset>.generate(180, (i) {
    final random = math.Random(12000 + i);
    return Offset(random.nextDouble(), random.nextDouble());
  }, growable: false);

  const _SkyPainter({
    required this.bodies,
    required this.orientation,
    required this.selectedId,
    required this.transparentBackground,
    required this.horizontalFov,
    required this.selectedConstellations,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (!transparentBackground) {
      canvas.drawRect(rect, Paint()..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF101F3D), Color(0xFF071126), Color(0xFF030814)],
      ).createShader(rect));
      for (var i = 0; i < _backgroundStars.length; i++) {
        final star = _backgroundStars[i];
        canvas.drawCircle(
          Offset(star.dx * size.width, star.dy * size.height),
          .35 + (i % 4) * .18,
          Paint()..color = Colors.white.withOpacity(.2 + (i % 5) * .12),
        );
      }
    }

    if (!orientation.hasHeading || !orientation.hasTilt) {
      _drawMessage(canvas, size, 'حرّك الهاتف وانتظر قراءة المستشعرات');
      return;
    }

    final positions = <String, Offset>{};
    for (final body in bodies) {
      final point = _projectBody(body, size, orientation, horizontalFov);
      if (point != null) positions[body.id] = point;
    }
    _drawConstellations(canvas, positions);
    for (final body in bodies) {
      final point = positions[body.id];
      if (point != null) _drawBody(canvas, body, point, selectedId == body.id);
    }
    if (positions.isEmpty) {
      _drawMessage(canvas, size, 'لا توجد أجرام ضمن مجال الرؤية الحالي');
    }
  }

  void _drawConstellations(Canvas canvas, Map<String, Offset> points) {
    final linePaint = Paint()
      ..color = const Color(0x668ED8E8)
      ..strokeWidth = .8;
    for (final name in selectedConstellations) {
      for (final edge in _SkyAtlasScreenState._constellationEdges[name] ??
          const <(String, String)>[]) {
        final first = points[edge.$1];
        final second = points[edge.$2];
        if (first != null && second != null) {
          canvas.drawLine(first, second, linePaint);
        }
      }
      final visible = (_SkyAtlasScreenState._constellationStars[name] ??
              const <String>[])
          .map((id) => points[id])
          .whereType<Offset>()
          .toList(growable: false);
      if (visible.length < 2) continue;
      final center = visible.reduce((a, b) => a + b) / visible.length.toDouble();
      final text = TextPainter(
        text: TextSpan(text: name, style: const TextStyle(
          color: Color(0xA6F2DC98), fontFamily: 'Amiri', fontSize: 9,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        )),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: 90);
      text.paint(canvas, center.translate(-text.width / 2, -text.height / 2));
    }
  }

  void _drawBody(Canvas canvas, CelestialBody body, Offset point, bool selected) {
    final color = body.color;
    final radius = switch (body.kind) {
      CelestialKind.sun => 8.0,
      CelestialKind.moon => 6.5,
      CelestialKind.planet => 4.8,
      CelestialKind.star => (3.0 - body.magnitude * .45).clamp(1.2, 4.2).toDouble(),
    };
    canvas.drawCircle(point, radius * (selected ? 4.5 : 3.3), Paint()
      ..color = color.withOpacity(.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13));
    if (body.kind == CelestialKind.sun) {
      canvas.drawCircle(point, 14, Paint()..color = color.withOpacity(.18));
    }
    if (body.kind == CelestialKind.moon) {
      canvas.drawCircle(point, radius, Paint()..color = color);
      canvas.drawCircle(point.translate(3, -2), radius * .85,
          Paint()..color = const Color(0xFF15243B));
    } else {
      canvas.drawCircle(point, radius, Paint()..color = color);
    }
    if (selected) {
      canvas.drawCircle(point, radius + 8, Paint()
        ..color = const Color(0xCCF2DC98)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }
    if (body.kind != CelestialKind.star || body.magnitude <= 1.1 || selected) {
      final label = TextPainter(
        text: TextSpan(text: body.nameAr, style: TextStyle(
          color: selected ? const Color(0xFFF2DC98) : Colors.white70,
          fontFamily: 'Amiri', fontSize: 11,
          shadows: const [Shadow(color: Colors.black, blurRadius: 5)],
        )),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: 120);
      label.paint(canvas, Offset(point.dx - label.width / 2, point.dy + radius + 5));
    }
  }

  void _drawMessage(Canvas canvas, Size size, String message) {
    final painter = TextPainter(
      text: TextSpan(text: message, style: const TextStyle(
        color: Colors.white54, fontFamily: 'Amiri', fontSize: 14,
      )),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width * .8);
    painter.paint(canvas, Offset((size.width - painter.width) / 2, size.height * .72));
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) =>
      oldDelegate.bodies != bodies ||
      oldDelegate.orientation.heading != orientation.heading ||
      oldDelegate.orientation.pitch != orientation.pitch ||
      oldDelegate.orientation.roll != orientation.roll ||
      oldDelegate.selectedId != selectedId ||
      oldDelegate.transparentBackground != transparentBackground ||
      oldDelegate.horizontalFov != horizontalFov ||
      oldDelegate.selectedConstellations != selectedConstellations;
}
