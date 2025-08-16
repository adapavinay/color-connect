import 'dart:collection';

/// Lightweight backtracking solver to verify that a given endpoint grid
/// has at least one valid solution with 4-neighbor moves and no overlaps.
/// Intended for debug/validation and auto-repair; not used during play.
class LevelValidator {
  static bool isSolvable(List<List<int?>> grid) {
    final endpoints = _collectEndpoints(grid);
    // exactly two endpoints per color
    for (final e in endpoints.entries) {
      if (e.value.length != 2) return false;
    }
    final n = grid.length, m = grid.first.length;
    final board = List.generate(n, (r) => List<int?>.from(grid[r]));

    final colors = endpoints.keys.toList()
      ..sort((a, b) {
        final da = (endpoints[a]![0] - endpoints[a]![1]).manhattan;
        final db = (endpoints[b]![0] - endpoints[b]![1]).manhattan;
        return db.compareTo(da); // harder first
      });

    bool backtrack(int idx) {
      if (idx == colors.length) {
        // require full coverage
        for (final row in board) {
          for (final c in row) {
            if (c == null) return false;
          }
        }
        return true;
      }
      final color = colors[idx];
      final s = endpoints[color]![0], t = endpoints[color]![1];
      final visited = HashSet<Point>()..add(s);
      final path = <Point>[];

      bool dfs(Point p) {
        if (p == t) {
          // lock path cells
          for (final q in path) {
            board[q.r][q.c] = color;
          }
          final ok = backtrack(idx + 1);
          // undo
          for (final q in path) {
            if (grid[q.r][q.c] != color) board[q.r][q.c] = null;
          }
          return ok;
        }
        final nbrs = <Point>[
          Point(p.r - 1, p.c),
          Point(p.r + 1, p.c),
          Point(p.r, p.c - 1),
          Point(p.r, p.c + 1),
        ]..sort((a, b) => (a - t).manhattan.compareTo((b - t).manhattan));

        for (final np in nbrs) {
          if (np.r < 0 || np.c < 0 || np.r >= n || np.c >= m) continue;
          if (visited.contains(np)) continue;
          final cell = board[np.r][np.c];
          if (cell != null && np != t) continue; // cannot cross other colors
          visited.add(np);
          path.add(np);
          if (!_isolatedPocket(board)) {
            if (dfs(np)) return true;
          }
          path.removeLast();
          visited.remove(np);
        }
        return false;
      }

      return dfs(s);
    }

    return backtrack(0);
  }

  static bool _isolatedPocket(List<List<int?>> b) {
    final n = b.length, m = b.first.length;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < m; c++) {
        if (b[r][c] != null) continue;
        var free = 0;
        if (r > 0 && b[r - 1][c] == null) free++;
        if (r + 1 < n && b[r + 1][c] == null) free++;
        if (c > 0 && b[r][c - 1] == null) free++;
        if (c + 1 < m && b[r][c + 1] == null) free++;
        if (free == 0) return true;
      }
    }
    return false;
  }

  static Map<int, List<Point>> _collectEndpoints(List<List<int?>> g) {
    final map = <int, List<Point>>{};
    for (var r = 0; r < g.length; r++) {
      for (var c = 0; c < g[r].length; c++) {
        final v = g[r][c];
        if (v != null) map.putIfAbsent(v, () => <Point>[]).add(Point(r, c));
      }
    }
    return map;
  }
}

class Point {
  final int r, c;
  const Point(this.r, this.c);
  @override
  bool operator ==(Object o) => o is Point && r == o.r && c == o.c;
  @override
  int get hashCode => Object.hash(r, c);
  Point operator -(Point o) => Point(r - o.r, c - o.c);
  int get manhattan => r.abs() + c.abs();
}
