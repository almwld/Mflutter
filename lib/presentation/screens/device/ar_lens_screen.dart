import 'package:arcore_flutter_plus/arcore_flutter_plus.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARLensScreen extends StatefulWidget {
  const ARLensScreen({super.key});
  @override
  State<ARLensScreen> createState() => _ARLensScreenState();
}

class _ARLensScreenState extends State<ARLensScreen> {
  ArCoreController? _controller;
  int _markers = 0;

  void _created(ArCoreController controller) {
    _controller = controller;
    controller.onPlaneTap = (hits) {
      if (hits.isEmpty) return;
      final hit = hits.first;
      final node = ArCoreNode(
        name: 'mudabbir_marker_$_markers',
        shape: ArCoreSphere(
          radius: 0.06,
          material: ArCoreMaterial(color: Colors.amber, metallic: 0.5, roughness: 0.25),
        ),
        position: hit.pose.translation,
      );
      controller.addArCoreNodeWithAnchor(node);
      setState(() => _markers++);
    };
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('عدسة التدبر AR')),
    body: Stack(children: [
      ArCoreView(
        onArCoreViewCreated: _created,
        enableTapRecognizer: true,
        enableUpdateListener: true,
      ),
      Positioned(
        left: 16, right: 16, bottom: 24,
        child: Card(child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('اضغط على سطح مكتشف لوضع علامة التدبر • العلامات: $_markers', textDirection: TextDirection.rtl),
        )),
      ),
    ]),
  );
}
