import '../math/vec3.dart';

/// Integer cell coordinate. Equality compares the full coordinate, not a
/// lossy hash value, so hash collisions cannot merge unrelated cells.
class GridCell {
  const GridCell(this.x, this.y, this.z);
  final int x;
  final int y;
  final int z;

  @override
  bool operator ==(Object other) =>
      other is GridCell && x == other.x && y == other.y && z == other.z;
  @override
  int get hashCode => Object.hash(x, y, z);
}

/// Reusable broad-phase grid for point and particle proximity queries.
class SpatialHashGrid<T> {
  SpatialHashGrid({this.cellSize = .1}) {
    if (!cellSize.isFinite || cellSize <= 0) {
      throw ArgumentError.value(cellSize, 'cellSize', 'Must be finite and > 0');
    }
  }

  final double cellSize;
  final Map<GridCell, List<T>> _cells = <GridCell, List<T>>{};

  int get occupiedCellCount => _cells.length;
  void clear() => _cells.clear();

  GridCell cellFor(Vec3 position) => GridCell(
        (position.x / cellSize).floor(),
        (position.y / cellSize).floor(),
        (position.z / cellSize).floor(),
      );

  void insert(T value, Vec3 position) {
    (_cells[cellFor(position)] ??= <T>[]).add(value);
  }

  void rebuild(Iterable<(T, Vec3)> entries) {
    clear();
    for (final entry in entries) {
      insert(entry.$1, entry.$2);
    }
  }

  /// Returns all entries in cells intersecting [radius] around [position].
  /// Exact distance filtering remains the caller's responsibility.
  Iterable<T> query(Vec3 position, double radius) sync* {
    if (!radius.isFinite || radius < 0) {
      throw ArgumentError.value(radius, 'radius', 'Must be finite and >= 0');
    }
    final center = cellFor(position);
    final range = (radius / cellSize).ceil();
    for (var x = -range; x <= range; x++) {
      for (var y = -range; y <= range; y++) {
        for (var z = -range; z <= range; z++) {
          final values = _cells[GridCell(
            center.x + x,
            center.y + y,
            center.z + z,
          )];
          if (values != null) yield* values;
        }
      }
    }
  }
}
