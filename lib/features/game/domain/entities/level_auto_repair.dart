import 'level_validator.dart';

/// Minimal, deterministic auto-repair: if a level is unsolvable, relocate
/// exactly one endpoint of one color to the first empty cell that yields a
/// solvable grid (row-major scan). Returns a deep copy.
class LevelAutoRepair {
  static List<List<int?>> autoRepairIfNeeded(List<List<int?>> grid) {
    final copy = List.generate(grid.length, (r) => List<int?>.from(grid[r]));
    if (LevelValidator.isSolvable(copy)) return copy;

    // Collect endpoints
    final endpoints = <int, List<_Pt>>{};
    for (int r = 0; r < copy.length; r++) {
      for (int c = 0; c < copy[r].length; c++) {
        final v = copy[r][c];
        if (v != null) {
          endpoints.putIfAbsent(v, () => <_Pt>[]).add(_Pt(r, c));
        }
      }
    }

    // Try moving ONE endpoint of ONE color to the earliest empty cell
    final empties = <_Pt>[];
    for (int r = 0; r < copy.length; r++) {
      for (int c = 0; c < copy[r].length; c++) {
        if (copy[r][c] == null) empties.add(_Pt(r, c));
      }
    }

    for (final color in endpoints.keys) {
      final pts = endpoints[color]!;
      for (int i = 0; i < 2; i++) {
        final moving = pts[i];
        final fixed = pts[1 - i];
        for (final e in empties) {
          if (e.r == fixed.r && e.c == fixed.c) continue;
          // temp move
          copy[moving.r][moving.c] = null;
          final prev = copy[e.r][e.c];
          copy[e.r][e.c] = color;
          if (LevelValidator.isSolvable(copy)) {
            return copy;
          }
          // revert
          copy[e.r][e.c] = prev;
          copy[moving.r][moving.c] = color;
        }
      }
    }
    return copy; // give up (won't be worse than original)
  }
}

class _Pt {
  final int r, c;
  const _Pt(this.r, this.c);
  @override
  bool operator ==(Object o) => o is _Pt && r == o.r && c == o.c;
  @override
  int get hashCode => Object.hash(r, c);
}
