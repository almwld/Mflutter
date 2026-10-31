import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../presentation/templates/components/block_event_bus.dart';
import '../../../presentation/templates/components/block_event_scope.dart';

/// Named entities connected by animated cubic Bézier paths.
class ConnectedNodesPathWidget extends StatefulWidget {
  const ConnectedNodesPathWidget({
    super.key,
    required this.nodes,
    this.edges = const <Map<String, dynamic>>[],
    this.height = 280,
    this.blockId = 'connected-nodes',
    this.targetBlockId,
    this.accentColor = const Color(0xFF38BDF8),
    this.backgroundColor = const Color(0xFF0F172A),
    this.onNodeSelected,
  });

  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> edges;
  final double height;
  final String blockId;
  final String? targetBlockId;
  final Color accentColor;
  final Color backgroundColor;
  final ValueChanged<String>? onNodeSelected;

  @override
  State<ConnectedNodesPathWidget> createState() =>
      _ConnectedNodesPathWidgetState();
}

class _ConnectedNodesPathWidgetState extends State<ConnectedNodesPathWidget>
    with TickerProviderStateMixin {
  late final AnimationController _flow;
  late final AnimationController _selection;
  late Float32List _coordinates;
  late List<String> _ids;
  late List<String> _labels;
  List<TextPainter>? _labelPainters;
  late List<(int, int)> _edges;
  BlockEventBus? _bus;
  StreamSubscription<BlockEvent>? _subscription;
  int _selected = -1;

  @override
  void initState() {
    super.initState();
    _flow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _selection = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _prepareGraph();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextBus = BlockEventScope.maybeOf(context);
    if (identical(nextBus, _bus)) return;
    unawaited(_subscription?.cancel());
    _bus = nextBus;
    _subscription = nextBus?.events.listen((event) {
      if (event.type != 'selection_changed' ||
          event.targetBlockId != widget.blockId) return;
      final id = event.payload['selection_id'];
      if (id is String) _selectById(id, publish: false);
    });
  }

  @override
  void didUpdateWidget(covariant ConnectedNodesPathWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodes != widget.nodes || oldWidget.edges != widget.edges) {
      _prepareGraph();
    }
  }

  void _prepareGraph() {
    for (final painter in _labelPainters ?? const <TextPainter>[]) {
      painter.dispose();
    }
    final nodes = widget.nodes.take(250).toList(growable: false);
    _ids = <String>[];
    _labels = <String>[];
    _coordinates = Float32List(nodes.length * 2);
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final angle = -math.pi / 2 + (2 * math.pi * i / math.max(1, nodes.length));
      final x = node['x'] is num ? (node['x'] as num).toDouble() : .5 + .38 * math.cos(angle);
      final y = node['y'] is num ? (node['y'] as num).toDouble() : .5 + .36 * math.sin(angle);
      _coordinates[i * 2] = x.clamp(0, 1).toDouble();
      _coordinates[i * 2 + 1] = y.clamp(0, 1).toDouble();
      _ids.add(node['id'] is String ? node['id'] as String : 'node-$i');
      _labels.add(node['label'] is String ? node['label'] as String : _ids.last);
    }
    _labelPainters = List<TextPainter>.generate(_labels.length, (index) {
      return TextPainter(
        text: TextSpan(
          text: _labels[index],
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.rtl,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: 110);
    }, growable: false);
    final indexes = <String, int>{for (var i = 0; i < _ids.length; i++) _ids[i]: i};
    _edges = <(int, int)>[];
    for (final edge in widget.edges.take(500)) {
      final from = edge['from'], to = edge['to'];
      final a = from is String ? indexes[from] : null;
      final b = to is String ? indexes[to] : null;
      if (a != null && b != null && a != b) _edges.add((a, b));
    }
    if (_selected >= _ids.length) _selected = -1;
  }

  void _selectById(String id, {bool publish = true}) {
    final index = _ids.indexOf(id);
    if (index < 0 || !mounted) return;
    setState(() => _selected = index);
    _selection.forward(from: 0);
    widget.onNodeSelected?.call(id);
    if (publish) {
      _bus?.publish(BlockEvent(
        type: 'selection_changed',
        sourceBlockId: widget.blockId,
        targetBlockId: widget.targetBlockId,
        payload: <String, Object?>{
          'selection_id': id,
          'node_index': index,
          'label': _labels[index],
        },
      ));
    }
  }

  void _handleTap(TapUpDetails details, Size size) {
    final radius = math.max(18.0, size.shortestSide * .075);
    var best = -1;
    var bestDistance = radius * radius;
    for (var i = 0; i < _ids.length; i++) {
      final dx = details.localPosition.dx - _coordinates[i * 2] * size.width;
      final dy = details.localPosition.dy - _coordinates[i * 2 + 1] * size.height;
      final distance = dx * dx + dy * dy;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = i;
      }
    }
    if (best >= 0) _selectById(_ids[best]);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _flow.dispose();
    _selection.dispose();
    for (final painter in _labelPainters ?? const <TextPainter>[]) {
      painter.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(double.infinity, widget.height.clamp(120, 900).toDouble());
    return SizedBox(
      height: size.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(builder: (context, constraints) {
          final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _handleTap(details, canvasSize),
            child: CustomPaint(
              painter: _ConnectedNodesPainter(
                flow: _flow,
                selection: _selection,
                coordinates: _coordinates,
                labelPainters: _labelPainters ?? const <TextPainter>[],
                edges: _edges,
                selected: _selected,
                accentColor: widget.accentColor,
                backgroundColor: widget.backgroundColor,
              ),
              child: const SizedBox.expand(),
            ),
          );
        }),
      ),
    );
  }
}

class _ConnectedNodesPainter extends CustomPainter {
  _ConnectedNodesPainter({
    required this.flow,
    required this.selection,
    required this.coordinates,
    required this.labelPainters,
    required this.edges,
    required this.selected,
    required this.accentColor,
    required this.backgroundColor,
  }) : super(repaint: Listenable.merge(<Listenable>[flow, selection])) {
    _background = Paint()..color = backgroundColor;
    _line = Paint()
      ..color = accentColor.withOpacity(.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;
    _activeLine = Paint()
      ..color = accentColor.withOpacity(.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1;
    _node = Paint()..color = const Color(0xFFCBD5E1);
    _activeNode = Paint()..color = accentColor;
    _glow = Paint()..color = accentColor.withOpacity(.16);
  }

  final Animation<double> flow;
  final Animation<double> selection;
  final Float32List coordinates;
  final List<TextPainter> labelPainters;
  final List<(int, int)> edges;
  final int selected;
  final Color accentColor;
  final Color backgroundColor;
  late final Paint _background, _line, _activeLine, _node, _activeNode, _glow;
  final Path _path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _background);
    final pulse = .5 + .5 * math.sin(flow.value * math.pi * 2);
    for (final edge in edges) {
      final ax = coordinates[edge.$1 * 2] * size.width;
      final ay = coordinates[edge.$1 * 2 + 1] * size.height;
      final bx = coordinates[edge.$2 * 2] * size.width;
      final by = coordinates[edge.$2 * 2 + 1] * size.height;
      final bend = (bx - ax).abs() * .22;
      _path.reset();
      _path.moveTo(ax, ay);
      _path.cubicTo(ax + bend, ay, bx - bend, by, bx, by);
      canvas.drawPath(_path, _line);
      final progress = (flow.value + edge.$1 * .137) % 1;
      final inverse = 1 - progress;
      final inverseSquared = inverse * inverse;
      final progressSquared = progress * progress;
      final pointX = inverseSquared * inverse * ax +
          3 * inverseSquared * progress * (ax + bend) +
          3 * inverse * progressSquared * (bx - bend) +
          progressSquared * progress * bx;
      final pointY = inverseSquared * inverse * ay +
          3 * inverseSquared * progress * ay +
          3 * inverse * progressSquared * by +
          progressSquared * progress * by;
      canvas.drawCircle(Offset(pointX, pointY), 2.1 + pulse, _activeLine);
    }
    for (var i = 0; i < labels.length; i++) {
      final x = coordinates[i * 2] * size.width;
      final y = coordinates[i * 2 + 1] * size.height;
      final active = i == selected;
      if (active) {
        canvas.drawCircle(Offset(x, y), 15 + selection.value * 5, _glow);
        canvas.drawCircle(Offset(x, y), 8 + selection.value * 2, _activeNode);
      } else {
        canvas.drawCircle(Offset(x, y), 5.2, _node);
      }
      final text = labelPainters[i];
      final labelY = y + (y < size.height * .55 ? 12 : -text.height - 12);
      text.paint(canvas, Offset(
        (x - text.width / 2).clamp(4, math.max(4, size.width - text.width - 4)).toDouble(),
        labelY.clamp(2, math.max(2, size.height - text.height - 2)).toDouble(),
      ));
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectedNodesPainter oldDelegate) =>
      oldDelegate.coordinates != coordinates ||
      oldDelegate.labelPainters != labelPainters ||
      oldDelegate.edges != edges ||
      oldDelegate.selected != selected ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
