import 'dart:collection';

/// Lightweight backtracking solver to validate that a level has at least one solution.
/// This does NOT run during gameplay—only as a debug-time assert to catch bad data.
class LevelValidator {
  /// Colors present in the grid and their two endpoints.
  static Map<String, List<Point>> _collectEndpoints(List<List<String?>> grid) {
    final map = <String, List<Point>>{};
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        final color = grid[r][c];
        if (color != null) {
          map.putIfAbsent(color, () => <Point>[]).add(Point(r, c));
        }
      }
    }
    return map;
  }

  /// Public entry to validate a level grid.
  static bool isSolvable(List<List<String?>> grid) {
    final endpoints = _collectEndpoints(grid);
    // Quick sanity: every color must have exactly 2 endpoints.
    for (final e in endpoints.entries) {
      if (e.value.length != 2) return false;
    }

    final n = grid.length, m = grid.first.length;
    final board = List.generate(n, (r) => List.generate(m, (c) => grid[r][c]));

    // Order colors by Manhattan distance (harder first for pruning).
    final colors = endpoints.keys.toList()
      ..sort((a, b) {
        int da = (endpoints[a]![0] - endpoints[a]![1]).manhattan;
        int db = (endpoints[b]![0] - endpoints[b]![1]).manhattan;
        return db.compareTo(da);
      });

    bool backtrack(int colorIdx) {
      if (colorIdx == colors.length) {
        // Check full cover: no nulls left
        for (var row in board) {
          for (var cell in row) {
            if (cell == null) return false;
          }
        }
        return true;
      }
      final color = colors[colorIdx];
      final ends = endpoints[color]!;
      final start = ends[0], goal = ends[1];
      final path = <Point>[];
      final visited = HashSet<Point>();

      bool dfs(Point p) {
        if (p == goal) {
          // lock path color on board
          for (final q in path) {
            board[q.r][q.c] = color;
          }
          final ok = backtrack(colorIdx + 1);
          // undo
          for (final q in path) {
            if (!(grid[q.r][q.c] == color)) {
              board[q.r][q.c] = null;
            }
          }
          return ok;
        }
        // Heuristic: prefer moves that reduce Manhattan distance to goal
        final dirs = <Point>[
          Point(p.r - 1, p.c),
          Point(p.r + 1, p.c),
          Point(p.r, p.c - 1),
          Point(p.r, p.c + 1),
        ]..sort((a, b) => (a - goal).manhattan.compareTo((b - goal).manhattan));

        for (final np in dirs) {
          if (np.r < 0 || np.c < 0 || np.r >= n || np.c >= m) continue;
          if (visited.contains(np)) continue;
          final cell = board[np.r][np.c];
          if (cell != null && np != goal) continue; // cannot pass through other colors

          // Tentatively occupy if empty (goal may already be color)
          final occupied = (board[np.r][np.c] != null);
          if (!occupied || np == goal) {
            visited.add(np);
            path.add(np);

            // Degree-2 rule: avoid creating isolated single empty pockets
            if (!_createsIsolatedPocket(board, np)) {
              if (dfs(np)) return true;
            }

            path.removeLast();
            visited.remove(np);
          }
        }
        return false;
      }

      visited.add(start);
      return dfs(start);
    }

    return backtrack(0);
  }

  // Simple isolation check: if we enclose a 1-cell island of nulls surrounded by color, prune.
  static bool _createsIsolatedPocket(List<List<String?>> board, Point last) {
    final n = board.length, m = board.first.length;
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < m; c++) {
        if (board[r][c] != null) continue;
        int freeNbrs = 0;
        if (r > 0 && board[r - 1][c] == null) freeNbrs++;
        if (r + 1 < n && board[r + 1][c] == null) freeNbrs++;
        if (c > 0 && board[r][c - 1] == null) freeNbrs++;
        if (c + 1 < m && board[r][c + 1] == null) freeNbrs++;
        if (freeNbrs == 0) return true;
      }
    }
    return false;
  }
}

class Point {
  final int r, c;
  const Point(this.r, this.c);
  @override
  bool operator ==(Object other) => other is Point && r == other.r && c == other.c;
  @override
  int get hashCode => Object.hash(r, c);
  Point operator -(Point o) => Point(r - o.r, c - o.c);
  int get manhattan => r.abs() + c.abs();
}
