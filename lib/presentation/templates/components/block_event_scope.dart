import 'package:flutter/widgets.dart';

import 'block_event_bus.dart';

/// Provides one event bus to every block inside a single rendered canvas.
/// The bus is deliberately not global: events cannot leak across canvases.
class BlockEventScope extends InheritedWidget {
  const BlockEventScope({
    super.key,
    required this.bus,
    required super.child,
  });

  final BlockEventBus bus;

  static BlockEventBus? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BlockEventScope>()?.bus;

  @override
  bool updateShouldNotify(BlockEventScope oldWidget) => bus != oldWidget.bus;
}
