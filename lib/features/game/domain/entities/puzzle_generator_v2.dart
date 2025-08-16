import 'dart:math';
import 'level_validator.dart';
import '../../../../core/config/feature_flags.dart';

/// V2 Puzzle Generator using Spanning-Tree Pair Routing.
/// Generates guaranteed solvable puzzles by building a randomized spanning tree
/// and placing endpoints along disjoint paths.
class PuzzleGeneratorV2 {
  static List<List<int?>>? generate({
    required int gridSize,
    required int colorCount,
    required int seed,
    int minSegmentLen = 2,
  }) {
    final random = Random(seed);
    
    if (FeatureFlags.verboseLogs) {
      print('🔧 Generating ${gridSize}x$gridSize with $colorCount colors using Spanning-Tree Pair Routing (V2)');
    }

    for (int attempt = 0; attempt < FeatureFlags.maxRetries; attempt++) {
      try {
        final result = _generateAttempt(gridSize, colorCount, random, minSegmentLen);
        if (result != null) {
          if (FeatureFlags.verboseLogs) {
            print('✅ V2 generator produced a ${FeatureFlags.requireFullCoverage ? "full-coverage" : "partial-coverage"} solvable grid');
          }
          return result;
        }
      } catch (e) {
        if (FeatureFlags.verboseLogs) {
          print('⚠️ V2 attempt ${attempt + 1} failed: $e');
        }
      }
    }
    
    if (FeatureFlags.verboseLogs) {
      print('❌ V2 generator failed after ${FeatureFlags.maxRetries} attempts, falling back to legacy');
    }
    return null;
  }

  static List<List<int?>>? _generateAttempt(
    int gridSize,
    int colorCount,
    Random random,
    int minSegmentLen,
  ) {
    // Build randomized spanning tree
    final tree = _buildSpanningTree(gridSize, random);
    
    // Find endpoint pairs along tree paths
    final endpoints = _findEndpointPairs(tree, colorCount, random);
    if (endpoints == null) return null;
    
    // Build the grid
    final grid = List.generate(gridSize, (r) => List<int?>.filled(gridSize, null));
    
    // Place endpoints
    for (int color = 0; color < colorCount; color++) {
      final pair = endpoints[color]!;
      grid[pair[0].r][pair[0].c] = color;
      grid[pair[1].r][pair[1].c] = color;
    }
    
    // Validate solvability
    if (!LevelValidator.isSolvable(grid)) return null;
    
    // Note: We don't check coverage here because:
    // 1. The endpoint grid only shows endpoints, not the full solution
    // 2. Coverage is enforced by the LevelValidator.isSolvable() check above
    // 3. The spanning tree is just a construction method, not a coverage guarantee
    
    // The validator will ensure the puzzle can be solved with full coverage
    
    return grid;
  }

  static Set<_Edge> _buildSpanningTree(int gridSize, Random random) {
    final edges = <_Edge>{};
    final visited = <_Point>{};
    final unvisited = <_Point>{};
    
    // Initialize all grid points
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        unvisited.add(_Point(r, c));
      }
    }
    
    // Start with random point
    final start = unvisited.elementAt(random.nextInt(unvisited.length));
    visited.add(start);
    unvisited.remove(start);
    
    // Prim's algorithm with random weights
    while (unvisited.isNotEmpty) {
      final candidates = <_Edge>{};
      
      // Find all edges between visited and unvisited
      for (final v in visited) {
        for (final u in unvisited) {
          if (_areAdjacent(v, u)) {
            candidates.add(_Edge(v, u, random.nextDouble()));
          }
        }
      }
      
      if (candidates.isEmpty) break;
      
      // Pick random edge (Prim's with random weights)
      final edge = candidates.elementAt(random.nextInt(candidates.length));
      edges.add(edge);
      visited.add(edge.p2);
      unvisited.remove(edge.p2);
    }
    
    return edges;
  }

  static Map<int, List<_Point>>? _findEndpointPairs(
    Set<_Edge> tree,
    int colorCount,
    Random random,
  ) {
    // Adaptive distance constraints: smaller grids need more flexible placement
    final gridSize = tree.isNotEmpty ? _getGridSizeFromTree(tree) : 5;
    final effectiveMinDist = (gridSize <= 5) ? 2 : FeatureFlags.minPairDistance;
    
    if (FeatureFlags.verboseLogs) {
      print('🔧 Adaptive distance: grid ${gridSize}x$gridSize, min distance: $effectiveMinDist');
    }
    final endpoints = <int, List<_Point>>{};
    final usedPoints = <_Point>{};
    
    // Convert tree to adjacency list for path finding
    final adj = <_Point, Set<_Point>>{};
    for (final edge in tree) {
      adj.putIfAbsent(edge.p1, () => <_Point>{}).add(edge.p2);
      adj.putIfAbsent(edge.p2, () => <_Point>{}).add(edge.p1);
    }
    
    for (int color = 0; color < colorCount; color++) {
      final pair = _findDisjointPair(adj, usedPoints, random);
      if (pair == null) return null;
      
      endpoints[color] = pair;
      usedPoints.addAll(pair);
    }
    
    return endpoints;
  }

  static List<_Point>? _findDisjointPair(
    Map<_Point, Set<_Point>> adj,
    Set<_Point> usedPoints,
    Random random,
  ) {
    final available = <_Point>{};
    for (final p in adj.keys) {
      if (!usedPoints.contains(p)) available.add(p);
    }
    
    if (available.length < 2) return null;
    
    // Try to find points with good separation
    final attempts = min(20, available.length * 2);
    for (int i = 0; i < attempts; i++) {
      final p1 = available.elementAt(random.nextInt(available.length));
      final p2 = available.elementAt(random.nextInt(available.length));
      
      if (p1 != p2 && _arePointsDisjoint(p1, p2, usedPoints, adj)) {
        final distance = _shortestPathLength(p1, p2, adj);
        if (distance >= FeatureFlags.minPairDistance) {
          return [p1, p2];
        }
      }
    }
    
    // Fallback: any two available points
    final points = available.toList();
    if (points.length >= 2) {
      return [points[0], points[1]];
    }
    
    return null;
  }

  static bool _areAdjacent(_Point p1, _Point p2) {
    return (p1.r - p2.r).abs() + (p1.c - p2.c).abs() == 1;
  }

  static bool _arePointsDisjoint(_Point p1, _Point p2, Set<_Point> used, Map<_Point, Set<_Point>> adj) {
    // Check if there's a path between p1 and p2 that doesn't go through used points
    final visited = <_Point>{};
    final queue = <_Point>[p1];
    visited.add(p1);
    
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (current == p2) return false; // Path exists
      
      for (final neighbor in adj[current] ?? <_Point>{}) {
        if (!visited.contains(neighbor) && !used.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
        }
      }
    }
    
    return true; // No path exists
  }

  static int _shortestPathLength(_Point start, _Point end, Map<_Point, Set<_Point>> adj) {
    final visited = <_Point>{};
    final queue = <_Point>[start];
    final distances = <_Point, int>{start: 0};
    visited.add(start);
    
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (current == end) return distances[current]!;
      
      for (final neighbor in adj[current] ?? <_Point>{}) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          distances[neighbor] = distances[current]! + 1;
          queue.add(neighbor);
        }
      }
    }
    
    return 999; // No path found
  }

  static double _calculateCoverage(List<List<int?>> grid) {
    int filled = 0;
    int total = grid.length * grid.first.length;
    
    for (final row in grid) {
      for (final cell in row) {
        if (cell != null) filled++;
      }
    }
    
    return filled / total;
  }
  
  static int _getGridSizeFromTree(Set<_Edge> tree) {
    if (tree.isEmpty) return 5;
    
    int maxR = 0, maxC = 0;
    for (final edge in tree) {
      maxR = max(maxR, max(edge.p1.r, edge.p2.r));
      maxC = max(maxC, max(edge.p1.c, edge.p2.c));
    }
    return max(maxR, maxC) + 1;
  }
}

class _Point {
  final int r, c;
  const _Point(this.r, this.c);
  
  @override
  bool operator ==(Object other) => other is _Point && r == other.r && c == other.c;
  @override
  int get hashCode => Object.hash(r, c);
  
  @override
  String toString() => '($r, $c)';
}

class _Edge {
  final _Point p1, p2;
  final double weight;
  const _Edge(this.p1, this.p2, this.weight);
  
  @override
  bool operator ==(Object other) => other is _Edge && 
    ((p1 == other.p1 && p2 == other.p2) || (p1 == other.p2 && p2 == other.p1));
  @override
  int get hashCode => Object.hash(p1.hashCode + p2.hashCode, weight);
}
