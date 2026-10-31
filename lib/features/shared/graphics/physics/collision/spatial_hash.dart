/// Swept-AABB spatial hash used to generate conservative particle candidates.
///
/// Each particle is inserted into every cell touched by its previous-to-current
/// motion segment expanded by its collision radius. This lets the narrow phase
/// consider fast movers that would otherwise tunnel between frames.
class SpatialHash {
  SpatialHash({this.cellSize = 0.25}) {
    if (!cellSize.isFinite || cellSize <= 0) {
      throw ArgumentError.value(cellSize, 'cellSize');
    }
  }

  final double cellSize;
  final Map<(int, int, int), List<int>> _cells = {};

  void clear() => _cells.clear();

  /// Returns false when the swept bounds are too large for grid insertion.
  /// The caller must then use a conservative all-pairs fallback for that step.
  bool insertSweptParticle({
    required int particleId,
    required double previousX,
    required double previousY,
    required double previousZ,
    required double currentX,
    required double currentY,
    required double currentZ,
    required double radius,
  }) {
    final minX = _cell((previousX < currentX ? previousX : currentX) - radius);
    final minY = _cell((previousY < currentY ? previousY : currentY) - radius);
    final minZ = _cell((previousZ < currentZ ? previousZ : currentZ) - radius);
    final maxX = _cell((previousX > currentX ? previousX : currentX) + radius);
    final maxY = _cell((previousY > currentY ? previousY : currentY) + radius);
    final maxZ = _cell((previousZ > currentZ ? previousZ : currentZ) + radius);

    final cellCount = (maxX - minX + 1) *
        (maxY - minY + 1) * (maxZ - minZ + 1);
    if (cellCount > 4096) return false;

    for (var x = minX; x <= maxX; x++) {
      for (var y = minY; y <= maxY; y++) {
        for (var z = minZ; z <= maxZ; z++) {
          _cells.putIfAbsent((x, y, z), () => <int>[]).add(particleId);
        }
      }
    }
    return true;
  }

  Iterable<List<int>> get buckets => _cells.values;

  int _cell(double coordinate) => (coordinate / cellSize).floor();
}
