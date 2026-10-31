import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/celestial_body.dart';
import '../../services/astronomy_service.dart';
import '../../services/sky_sensor_service.dart';
import '../../services/sky_projection.dart';

class _ConstellationSpec {
  const _ConstellationSpec(this.id, this.name, this.stars, this.edges);
  final String id;
  final String name;
  final List<String> stars;
  final List<(String, String)> edges;
}

const List<_ConstellationSpec> _skyConstellations = [
  _ConstellationSpec('orion', 'الجبار',
    ['betelgeuse', 'bellatrix', 'rigel', 'saiph', 'alnilam', 'mintaka', 'alnitak'],
    [('betelgeuse', 'bellatrix'), ('bellatrix', 'rigel'), ('rigel', 'saiph'),
     ('saiph', 'betelgeuse'), ('betelgeuse', 'rigel'), ('alnilam', 'mintaka'),
     ('alnilam', 'alnitak')]),
  _ConstellationSpec('ursa_major', 'الدب الأكبر',
    ['dubhe', 'merak', 'phecda', 'megrez', 'alioth', 'mizar', 'alkaid'],
    [('dubhe', 'merak'), ('merak', 'phecda'), ('phecda', 'megrez'),
     ('megrez', 'dubhe'), ('megrez', 'alioth'), ('alioth', 'mizar'),
     ('mizar', 'alkaid')]),
  _ConstellationSpec('cassiopeia', 'ذات الكرسي',
    ['schedar', 'caph', 'gamma_cas', 'ruchbah', 'segin'],
    [('schedar', 'caph'), ('caph', 'gamma_cas'), ('gamma_cas', 'ruchbah'),
     ('ruchbah', 'segin')]),
  _ConstellationSpec('cygnus', 'الدجاجة', ['deneb', 'sadr', 'albireo', 'gienah'],
    [('deneb', 'sadr'), ('sadr', 'albireo'), ('sadr', 'gienah')]),
  _ConstellationSpec('lyra', 'القيثارة', ['vega', 'sheliak', 'sulafat'],
    [('vega', 'sheliak'), ('sheliak', 'sulafat')]),
  _ConstellationSpec('aquila', 'العقاب', ['altair', 'tarazed', 'alshain'],
    [('altair', 'tarazed'), ('altair', 'alshain')]),
  _ConstellationSpec('taurus', 'الثور', ['aldebaran', 'elnath'],
    [('aldebaran', 'elnath')]),
  _ConstellationSpec('canis_major', 'الكلب الأكبر', ['sirius', 'wezen', 'adhara', 'aludra'],
    [('sirius', 'wezen'), ('wezen', 'adhara'), ('adhara', 'aludra')]),
  _ConstellationSpec('leo', 'الأسد', ['regulus', 'algieba', 'denebola'],
    [('regulus', 'algieba'), ('algieba', 'denebola')]),
  _ConstellationSpec('gemini', 'التوأمان', ['castor', 'pollux'],
    [('castor', 'pollux')]),
  _ConstellationSpec('andromeda', 'المرأة المسلسلة', ['alpheratz', 'mirach', 'almach'],
    [('alpheratz', 'mirach'), ('mirach', 'almach')]),
  _ConstellationSpec('scorpius', 'العقرب', ['antares', 'shaula', 'sargas'],
    [('antares', 'shaula'), ('shaula', 'sargas')]),
  _ConstellationSpec('crux', 'الصليب الجنوبي', ['acrux', 'mimosa', 'gacrux'],
    [('acrux', 'mimosa'), ('mimosa', 'gacrux')]),
];

class SkyAtlasScreen extends StatefulWidget {
  const SkyAtlasScreen({super.key});

  @override
  State<SkyAtlasScreen> createState() => _SkyAtlasScreenState();
}

class _SkyAtlasScreenState extends State<SkyAtlasScreen>
    with WidgetsBindingObserver {
  static const _gold = Color(0xFFF2DC98);
  static const _filters = ['الكل', 'نجم', 'كوكب', 'القمر', 'الشمس'];

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
  Set<String> _selectedConstellations = _skyConstellations.map((item) => item.id).toSet();
  String _filter = 'الكل';
  String? _selectedId;
  String? _cameraError;
  List<CelestialBody> _bodies = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sensors.start();
    unawaited(_loadCameraCalibration());
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

  Future<void> _loadCameraCalibration() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getDouble('sky_atlas_horizontal_fov');
      if (mounted && stored != null && stored >= 30 && stored <= 110) {
        setState(() => _horizontalFov = stored);
      }
    } catch (_) {
      // Calibration remains usable for this session if preferences are unavailable.
    }
  }

  Future<void> _saveCameraCalibration(double value) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setDouble('sky_atlas_horizontal_fov', value);
    } catch (_) {
      _message('تعذر حفظ معايرة مجال الرؤية؛ ستبقى فعالة حتى إغلاق الشاشة.');
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


  /// Finds the catalogued body closest to the optical-axis reticle.
  /// Drawing, hit-testing and target lock share the same projection.
  CelestialBody? _findAimedBody(Size size) {
    if (!_orientation.hasHeading || !_orientation.hasTilt || _visibleBodies.isEmpty) {
      return null;
    }
    final opticalAxis = Offset(size.width / 2, size.height / 2);
    CelestialBody? nearest;
    var nearestDistance = 42.0;
    for (final body in _visibleBodies) {
      final point = _projectBody(body, size, _orientation, _horizontalFov);
      if (point == null) continue;
      final distance = (point - opticalAxis).distance;
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = body;
      }
    }
    return nearest;
  }

  Widget _buildAimedObjectCard(CelestialBody body, Offset point, Size viewport) {
    final distance = body.distanceKilometers != null
        ? '${body.distanceKilometers!.toStringAsFixed(0)} كم'
        : body.distanceAu != null
            ? '${body.distanceAu!.toStringAsFixed(4)} وحدة فلكية'
            : body.distanceLightYears != null
                ? '~${body.distanceLightYears!.toStringAsFixed(1)} سنة ضوئية'
                : 'المسافة غير متاحة في الفهرس';
    final left = (point.dx - 112).clamp(8.0, math.max(8.0, viewport.width - 232)).toDouble();
    final top = (point.dy - 104).clamp(8.0, math.max(8.0, viewport.height - 100)).toDouble();
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 224),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xE9101D34),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: body.color.withOpacity(.85), width: 1.2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(body.nameAr, style: const TextStyle(
                  color: _gold, fontFamily: 'Amiri', fontWeight: FontWeight.bold, fontSize: 17,
                )),
                Text(body.nameEn, textDirection: TextDirection.ltr,
                  style: const TextStyle(color: Colors.white60, fontSize: 10)),
                const SizedBox(height: 4),
                Text('المسافة: $distance', style: const TextStyle(color: Colors.white, fontSize: 11)),
                Text('الارتفاع ${body.altitude.toStringAsFixed(1)}°  •  السمت ${body.azimuth.toStringAsFixed(1)}°',
                  style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectAt(Offset point, Size size) {
    CelestialBody? nearest;
    var distanceLimit = 34.0;
    for (final body in _visibleBodies) {
      final projected = _projectBody(
        body, size, _orientation, _horizontalFov,
      );
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
                  if (selected.distanceKilometers != null)
                    _detail('المسافة', selected.distanceKilometers!.toStringAsFixed(0) + ' كم'),
                  if (selected.distanceAu != null)
                    _detail('المسافة الفلكية', selected.distanceAu!.toStringAsFixed(5) + ' AU'),
                  if (selected.distanceLightYears != null)
                    _detail('المسافة التقريبية', '~' + selected.distanceLightYears!.toStringAsFixed(1) + ' سنة ضوئية'),
                  if (selected.illuminatedFraction != null)
                    _detail('إضاءة القمر', (selected.illuminatedFraction! * 100).toStringAsFixed(1) + '%'),
                  if (selected.phaseName != null)
                    _detail('طور القمر', selected.phaseName!),
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
                const Text(
                  'القدر الظاهري: كلما كانت القيمة أكثر سلبية كان الجرم أشد سطوعاً. مسافات النجوم تقريبية وتعتمد على القيم الفهرسية المتاحة.',
                  style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
                ),
                const SizedBox(height: 8),
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
                  final aimedBody = _findAimedBody(size);
                  final aimedPoint = aimedBody == null
                      ? null
                      : _projectBody(aimedBody, size, _orientation, _horizontalFov);
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
                            selectedId: aimedBody?.id ?? _selectedId,
                            horizontalFov: _horizontalFov,
                            selectedConstellations: _selectedConstellations,
                            transparentBackground: cameraReady,
                          ),
                        ),
                        if (aimedBody != null && aimedPoint != null && cameraReady)
                          _buildAimedObjectCard(aimedBody, aimedPoint, size),
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
          const SizedBox(height: 6),
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
          Row(children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 16),
            const SizedBox(width: 6),
            const Text('مجال الكاميرا', style: TextStyle(color: Colors.white70, fontSize: 11)),
            Expanded(
              child: Slider(
                value: _horizontalFov,
                min: 30,
                max: 110,
                divisions: 80,
                activeColor: _gold,
                inactiveColor: Colors.white12,
                onChanged: (value) => setState(() => _horizontalFov = value),
                onChangeEnd: _saveCameraCalibration,
              ),
            ),
            Text(_horizontalFov.toStringAsFixed(0) + '°',
              style: const TextStyle(color: _gold, fontSize: 10)),
          ]),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'عاير المجال حتى تتطابق الأجرام مع مواضعها في الكاميرا؛ تحفظ القيمة تلقائياً.',
              style: TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              FilterChip(
                label: const Text('كل الكوكبات'),
                selected: _selectedConstellations.length == _skyConstellations.length,
                onSelected: (selected) => setState(() {
                  _selectedConstellations = selected
                    ? _skyConstellations.map((item) => item.id).toSet()
                    : <String>{};
                }),
                selectedColor: _gold.withOpacity(.2),
              ),
              ..._skyConstellations.map((constellation) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 6),
                child: FilterChip(
                  label: Text(constellation.name),
                  selected: _selectedConstellations.contains(constellation.id),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _selectedConstellations.add(constellation.id);
                    } else {
                      _selectedConstellations.remove(constellation.id);
                    }
                    _selectedConstellations = Set<String>.from(_selectedConstellations);
                  }),
                  selectedColor: _gold.withOpacity(.2),
                ),
              )),
            ]),
          ),
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
          'تُحسب مواقع الشمس والكواكب باستخدام Meeus وVSOP87، والقمر مع اختلاف المنظر الطبوغرافي وطور الإضاءة والمسافة. إسقاط الشاشة غنوموني، ويمكن معايرة مجال الرؤية أفقياً وحفظه على الجهاز. زاوية العدسة الفعلية ومحاذاة المستشعرات لا تُستخرجان تلقائياً، لذا يلزم ضبط يدوي على الجهاز. لا يُطبّق الانكسار الجوي أو تصحيح الانحراف المغناطيسي المحلي، والقدر الظاهري للكواكب تقريبي. هذه أداة استكشاف وليست جهاز ملاحة أو مرصداً احترافياً.',
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
  final double horizontalFov;
  final Set<String> selectedConstellations;
  final bool transparentBackground;

  static final List<Offset> _backgroundStars = List<Offset>.generate(180, (i) {
    final random = math.Random(12000 + i);
    return Offset(random.nextDouble(), random.nextDouble());
  }, growable: false);

  const _SkyPainter({
    required this.bodies,
    required this.orientation,
    required this.selectedId,
    required this.horizontalFov,
    required this.selectedConstellations,
    required this.transparentBackground,
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
    for (final constellation in _skyConstellations) {
      if (!selectedConstellations.contains(constellation.id)) continue;
      for (final edge in constellation.edges) {
        final first = points[edge.$1];
        final second = points[edge.$2];
        if (first != null && second != null) {
          canvas.drawLine(first, second, linePaint);
        }
      }
      final visible = constellation.stars
          .map((id) => points[id])
          .whereType<Offset>()
          .toList(growable: false);
      if (visible.length < 2) continue;
      final center = visible.reduce((a, b) => a + b) / visible.length.toDouble();
      final text = TextPainter(
        text: TextSpan(text: constellation.name, style: const TextStyle(
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
      oldDelegate.horizontalFov != horizontalFov ||
      oldDelegate.selectedConstellations != selectedConstellations ||
      oldDelegate.transparentBackground != transparentBackground;
}
