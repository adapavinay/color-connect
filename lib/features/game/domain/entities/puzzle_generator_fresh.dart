import 'dart:math';

/// Fresh Puzzle Generator using Hamiltonian Snake Paths.
/// Generates guaranteed solvable puzzles by building a snake path that visits
/// every cell once, then splitting it into segments for each color.
class PuzzleGeneratorFresh {
  static List<List<int?>> generate({
    required int gridSize,
    required int colorCount,
    required int seed,
    int minSegmentLen = 2,
  }) {
    final random = Random(seed);
    
    print('🔧 Generating ${gridSize}x$gridSize with $colorCount colors using Fresh Hamiltonian Snake Path');
    
    // Build the Hamiltonian snake path
    final snakePath = _buildSnakePath(gridSize);
    
    // Apply random transformations for variety
    final transformedPath = _applyTransformations(snakePath, gridSize, random);
    
    // Split into segments for each color
    final segments = _createSegments(transformedPath, colorCount, minSegmentLen, random);
    
    // Create the endpoint grid
    final grid = List.generate(gridSize, (y) => List.generate(gridSize, (x) => null as int?));
    
    // Place endpoints at segment boundaries
    for (int color = 0; color < colorCount; color++) {
      final segment = segments[color];
      final start = segment.first;
      final end = segment.last;
      
      grid[start.y][start.x] = color;
      grid[end.y][end.x] = color;
      
      print('🎨 Color $color: segment length ${segment.length}, endpoints: (${start.x},${start.y}) -> (${end.x},${end.y})');
    }
    
    print('✅ Fresh generator produced a guaranteed solvable grid with full coverage');
    return grid;
  }
  
  /// Build a standard serpentine Hamiltonian path
  static List<_Point> _buildSnakePath(int gridSize) {
    final path = <_Point>[];
    
    for (int y = 0; y < gridSize; y++) {
      if (y.isEven) {
        // Left to right
        for (int x = 0; x < gridSize; x++) {
          path.add(_Point(x, y));
        }
      } else {
        // Right to left
        for (int x = gridSize - 1; x >= 0; x--) {
          path.add(_Point(x, y));
        }
      }
    }
    
    return path;
  }
  
  /// Apply random transformations while preserving path continuity
  static List<_Point> _applyTransformations(List<_Point> path, int gridSize, Random random) {
    // Apply random symmetries (flip X, flip Y, transpose)
    // These preserve Manhattan adjacency and path continuity
    final flipX = random.nextBool();
    final flipY = random.nextBool();
    final transpose = random.nextBool();
    
    return path.map((point) {
      int x = point.x;
      int y = point.y;
      
      if (transpose) {
        final temp = x;
        x = y;
        y = temp;
      }
      
      if (flipX) {
        x = gridSize - 1 - x;
      }
      
      if (flipY) {
        y = gridSize - 1 - y;
      }
      
      return _Point(x, y);
    }).toList();
  }
  
  /// Split the path into segments for each color
  static List<List<_Point>> _createSegments(
    List<_Point> path,
    int colorCount,
    int minSegmentLen,
    Random random,
  ) {
    final totalCells = path.length;
    final segments = <List<_Point>>[];
    
    // Calculate segment lengths (ensure minimum length)
    final baseLen = totalCells ~/ colorCount;
    final remainder = totalCells % colorCount;
    
    final lengths = List<int>.generate(
      colorCount,
      (i) => max(minSegmentLen, baseLen + (i < remainder ? 1 : 0)),
    );
    
    // Adjust lengths to fit total cells while maintaining minimum
    int totalAllocated = lengths.fold(0, (sum, len) => sum + len);
    if (totalAllocated > totalCells) {
      // Reduce lengths while keeping minimum
      for (int i = lengths.length - 1; i >= 0 && totalAllocated > totalCells; i--) {
        if (lengths[i] > minSegmentLen) {
          lengths[i]--;
          totalAllocated--;
        }
      }
    }
    
    // Create segments by cutting the path
    int currentIndex = 0;
    for (int i = 0; i < colorCount; i++) {
      final segmentLength = lengths[i];
      final segment = path.sublist(currentIndex, currentIndex + segmentLength);
      segments.add(segment);
      currentIndex += segmentLength;
    }
    
    // Randomize segment order for variety
    final startSegment = random.nextInt(colorCount);
    final rotatedSegments = [...segments.sublist(startSegment), ...segments.sublist(0, startSegment)];
    
    print('🔧 Created ${rotatedSegments.length} segments with lengths: ${lengths.join(', ')}');
    print('🔧 Starting segment: $startSegment for variety');
    
    return rotatedSegments;
  }
}

/// Simple point class for coordinate handling
class _Point {
  final int x, y;
  const _Point(this.x, this.y);
  
  @override
  bool operator ==(Object other) => other is _Point && x == other.x && y == other.y;
  @override
  int get hashCode => Object.hash(x, y);
  
  @override
  String toString() => '($x,$y)';
}
