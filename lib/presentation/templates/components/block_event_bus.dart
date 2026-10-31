import 'dart:async';

/// A small, canvas-scoped event bus for block-to-block coordination.
///
/// Create one instance per rendered canvas and dispose it with that canvas.
/// Events are data-only; listeners must validate identifiers before acting.
class BlockEventBus {
  BlockEventBus();

  final StreamController<BlockEvent> _controller =
      StreamController<BlockEvent>.broadcast(sync: true);
  bool _closed = false;

  Stream<BlockEvent> get events => _controller.stream;
  bool get isClosed => _closed;

  void publish(BlockEvent event) {
    if (_closed) return;
    _controller.add(event);
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _controller.close();
  }
}

class BlockEvent {
  const BlockEvent({
    required this.type,
    required this.sourceBlockId,
    this.targetBlockId,
    this.payload = const <String, Object?>{},
  });

  final String type;
  final String sourceBlockId;
  final String? targetBlockId;
  final Map<String, Object?> payload;
}
