import 'dart:math' as math;
import 'level_validator.dart';

typedef Grid = List<List<String?>>;

class LevelAutoRepair {
  /// Returns a deep-copied grid. If the level is unsolvable, tries minimal
  /// endpoint relocation (move ONE endpoint of ONE color) to make it solvable.
  /// Does not mutate the input.
  static Grid autoRepairIfUnsolvable(Grid grid,
      {int maxCandidatesPerColor = 40}) {
    final copy = _deepCopy(grid);
    if (LevelValidator.isSolvable(copy)) return copy;

    final endpoints = _collectEndpoints(copy);
    final colors = endpoints.keys.toList();

    // Candidate cells for placing an endpoint, sorted to prefer edges and
    // cells far from other endpoints (reduces forced crossings).
    final endpointSet = <_Pt>{};
    for (final pts in endpoints.values) {
      endpointSet.addAll(pts.map((e) => _Pt(e.r, e.c)));
    }
    final candidates = _sortedCandidateCells(copy, endpointSet);

    for (final color in colors) {
      final pts = endpoints[color]!;
      // Try moving exactly ONE endpoint; keep the other fixed.
      for (int movingIdx = 0; movingIdx < 2; movingIdx++) {
        final fixed = pts[1 - movingIdx];
        final moving = pts[movingIdx];

        int tried = 0;
        for (final cand in candidates) {
          if (tried >= maxCandidatesPerColor) break;
          // Skip if target is current location or occupied by another endpoint
          if ((cand.r == moving.r && cand.c == moving.c) ||
              copy[cand.r][cand.c] != null) {
            continue;
          }
          // Don't place on top of the fixed endpoint of same color
          if (cand.r == fixed.r && cand.c == fixed.c) continue;

          // Temp move
          copy[moving.r][moving.c] = null;
          final prev = copy[cand.r][cand.c];
          copy[cand.r][cand.c] = color;

          if (LevelValidator.isSolvable(copy)) {
            return copy; // success with a single minimal move
          }

          // revert
          copy[cand.r][cand.c] = prev;
          copy[moving.r][moving.c] = color;
          tried++;
        }
      }
    }

    // If we get here, we couldn't repair with a single move; return original copy.
    return copy;
  }

  // --- helpers ---
  static Map<String, List<_Pt>> _collectEndpoints(Grid g) {
    final map = <String, List<_Pt>>{};
    for (int r = 0; r < g.length; r++) {
      for (int c = 0; c < g[r].length; c++) {
        final col = g[r][c];
        if (col != null) {
          map.putIfAbsent(col, () => <_Pt>[]).add(_Pt(r, c));
        }
      }
    }
    return map;
  }

  static List<_Pt> _sortedCandidateCells(Grid g, Set<_Pt> endpoints) {
    final n = g.length, m = g.first.length;
    final list = <_Pt>[];
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < m; c++) {
        if (g[r][c] == null) list.add(_Pt(r, c));
      }
    }
    // score: prefer edges and distance from other endpoints
    double score(_Pt p) {
      final edgeBias = (p.r == 0 || p.c == 0 || p.r == n - 1 || p.c == m - 1) ? 0.0 : 1.0;
      // larger is better: sum of distances to all endpoints
      double dist = 0;
      for (final e in endpoints) {
        dist += (p.r - e.r).abs() + (p.c - e.c).abs().toDouble();
      }
      return edgeBias + (1.0 / (1 + dist)); // lower is better in sort
    }

    list.sort((a, b) => score(a).compareTo(score(b)));
    return list;
  }

  static Grid _deepCopy(Grid g) =>
      List.generate(g.length, (r) => List<String?>.from(g[r]));
}

class _Pt {
  final int r, c;
  const _Pt(this.r, this.c);
  @override
  bool operator ==(Object other) => other is _Pt && r == other.r && c == other.c;
  @override
  int get hashCode => Object.hash(r, c);
}
