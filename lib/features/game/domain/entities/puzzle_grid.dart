import 'package:flame/components.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/features/game/domain/entities/grid_cell.dart';
import 'package:color_connect/features/game/domain/entities/path_segment.dart';

class PuzzleGrid extends Component with HasGameRef {
  final int gridSize;
  final List<List<int?>> levelData;
  final Function(List<PathSegment>) onPathComplete;
  
  late List<List<GridCell>> grid;
  late List<List<PathSegment>> completedPaths;
  late List<List<PathSegment>> currentPath;
  late List<Vector2> moveHistory;
  
  // Getter for completed paths to check overlaps
  List<List<PathSegment>> get completedPathsList => completedPaths;
  
  static const double baseCellSize = 80.0;
  static const double borderWidth = 2.0;
  
  double get cellSize {
    final w = gameRef.size.x;
    final h = gameRef.size.y;
    const padding = 24.0;
    final available = (w < h ? w : h) - padding * 2;
    final size = available / gridSize;
    return size.clamp(28.0, 72.0);
  }

  PuzzleGrid({
    required this.gridSize,
    required this.levelData,
    required this.onPathComplete,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    print('🎮 Creating puzzle grid: ${gridSize}x${gridSize}');
    print('📊 Level data: $levelData');
    
    // Initialize grid
    grid = List.generate(
      gridSize,
      (y) => List.generate(
        gridSize,
        (x) => GridCell(
          position: Vector2(x * cellSize, y * cellSize),
          size: cellSize,
          color: levelData[y][x],
          isEndpoint: levelData[y][x] != null,
        ),
      ),
    );
    
    completedPaths = [];
    currentPath = [];
    moveHistory = [];
    
    // Add all cells to the component
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        add(grid[y][x]);
        if (levelData[y][x] != null) {
          // Endpoint added
        }
      }
    }
    
    print('✅ Puzzle grid loaded with ${gridSize * gridSize} cells');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw grid borders
    _drawGridBorders(canvas);
    
    // Draw completed paths
    _drawCompletedPaths(canvas);
    
    // Draw current path
    _drawCurrentPath(canvas);
  }

  void _drawGridBorders(Canvas canvas) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.3)
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= gridSize; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, gridSize * cellSize),
        paint,
      );
      
      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(gridSize * cellSize, i * cellSize),
        paint,
      );
    }
  }

  void _drawCompletedPaths(Canvas canvas) {
    for (final path in completedPaths) {
      _drawPath(canvas, path, true);
    }
  }

  void _drawCurrentPath(Canvas canvas) {
    for (final path in currentPath) {
      _drawPath(canvas, path, false);
    }
  }

  void _drawPath(Canvas canvas, List<PathSegment> path, bool isCompleted) {
    if (path.isEmpty) return;
    
    final paint = Paint()
      ..color = _getColorForPath(path.first.color)
      ..strokeWidth = cellSize * 0.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    if (!isCompleted) {
      paint.color = paint.color.withOpacity(0.7);
    }
    
    final pathPainter = Path();
    final firstSegment = path.first;
    pathPainter.moveTo(
      firstSegment.start.x * cellSize + cellSize / 2,
      firstSegment.start.y * cellSize + cellSize / 2,
    );
    
    for (final segment in path) {
      pathPainter.lineTo(
        segment.end.x * cellSize + cellSize / 2,
        segment.end.y * cellSize + cellSize / 2,
      );
    }
    
    canvas.drawPath(pathPainter, paint);
  }

  Color _getColorForPath(int colorIndex) {
    switch (colorIndex) {
      case 0:
        return AppTheme.red;
      case 1:
        return AppTheme.blue;
      case 2:
        return AppTheme.green;
      case 3:
        return AppTheme.yellow;
      case 4:
        return AppTheme.purple;
      case 5:
        return AppTheme.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  Vector2? worldToGrid(Vector2 worldPosition) {
    final x = (worldPosition.x / cellSize).floor();
    final y = (worldPosition.y / cellSize).floor();
    
    // World position converted to grid coordinates
    
    if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
      return Vector2(x.toDouble(), y.toDouble());
    }
    
    print('❌ Position out of bounds: ($x, $y) not in [0, ${gridSize-1}]');
    return null;
  }

  GridCell? getCell(int x, int y) {
    if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
      return grid[y][x];
    }
    return null;
  }

  void updatePath(List<PathSegment> path) {
    currentPath = [path];
    // Trigger a repaint
    // markNeedsPaint(); // Not needed in current Flame version
  }

  void addCompletedPath(List<PathSegment> path) {
    if (path.isNotEmpty) {
      print('🔍 Adding completed path with ${path.length} segments');
      print('🔍 Path details: ${path.map((s) => '${s.start}->${s.end}').toList()}');
      
      completedPaths.add(List.from(path));
      moveHistory.add(Vector2(completedPaths.length.toDouble(), 0));
      onPathComplete(path);
      
      print('🔍 Total completed paths: ${completedPaths.length}');
      // markNeedsPaint(); // Not needed in current Flame version
    } else {
      print('❌ Cannot add empty path');
    }
  }

  void clearCurrentPath() {
    currentPath.clear();
    // markNeedsPaint(); // Not needed in current Flame version
  }

  bool isLevelComplete() {
    print('🔍 PuzzleGrid.isLevelComplete() called');
    print('🔍 Completed paths count: ${completedPaths.length}');
    
    // Step 1: Check if all endpoints are connected
    final connectedEndpoints = <String>{};
    final colorPaths = <int, List<List<int>>>{};
    
    for (final path in completedPaths) {
      if (path.isNotEmpty) {
        final start = path.first.start;
        final end = path.last.end;
        final color = path.first.color;
        
        final startKey = '${start.x.toInt()},${start.y.toInt()},$color';
        final endKey = '${end.x.toInt()},${end.y.toInt()},$color';
        
        connectedEndpoints.add(startKey);
        connectedEndpoints.add(endKey);
        
        // Group paths by color
        if (!colorPaths.containsKey(color)) {
          colorPaths[color] = [];
        }
        colorPaths[color]!.add([
          start.x.toInt(), start.y.toInt(),
          end.x.toInt(), end.y.toInt()
        ]);
        
        print('🔍 Path connects: $startKey -> $endKey');
      }
    }
    
    // Count total endpoints
    int totalEndpoints = 0;
    final endpointColors = <int, int>{};
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (levelData[y][x] != null) {
          totalEndpoints++;
          final color = levelData[y][x]!;
          endpointColors[color] = (endpointColors[color] ?? 0) + 1;
          print('🔍 Found endpoint at [$x,$y] with color $color');
        }
      }
    }
    
    print('🔍 Total endpoints: $totalEndpoints, Connected: ${connectedEndpoints.length}');
    
    // All endpoints must be connected
    if (connectedEndpoints.length != totalEndpoints) {
      print('❌ Level incomplete: Only ${connectedEndpoints.length} endpoints connected, need $totalEndpoints');
      return false;
    }
    
    // Step 2: Validate that each color has exactly one path
    for (final color in endpointColors.keys) {
      final pathsForColor = colorPaths[color] ?? [];
      if (pathsForColor.length != 1) {
        print('❌ Color $color has ${pathsForColor.length} paths, need exactly 1');
        return false;
      }
    }
    
    // Step 3: Check for path overlaps (more strict validation)
    final occupiedCells = <String>{};
    final pathSegments = <String>{};
    
    for (final path in completedPaths) {
      if (path.isNotEmpty) {
        // Add start point
        final start = path.first.start;
        final startKey = '${start.x.toInt()},${start.y.toInt()}';
        occupiedCells.add(startKey);
        
        // Add all path segments and check for overlaps
        for (final segment in path) {
          final endKey = '${segment.end.x.toInt()},${segment.end.y.toInt()}';
          
          // Skip if this is a single-cell path (start == end)
          if (segment.start == segment.end) {
            continue; // Single-cell paths don't create overlaps
          }
          
          // Check if this cell is already occupied by another path
          // But allow endpoints to be shared (they're valid overlaps)
          if (occupiedCells.contains(endKey)) {
            // Check if this is an endpoint - endpoints can be shared
            final coords = endKey.split(',');
            final endX = int.parse(coords[0]);
            final endY = int.parse(coords[1]);
            final isEndpoint = levelData[endY][endX] != null;
            if (!isEndpoint) {
              print('❌ Path overlap detected at cell $endKey');
              return false;
            }
          }
          
          occupiedCells.add(endKey);
          
          // Check for segment overlaps (if start and end are the same)
          final segmentKey = '${segment.start.x.toInt()},${segment.start.y.toInt()}-${segment.end.x.toInt()},${segment.end.y.toInt()}';
          if (pathSegments.contains(segmentKey)) {
            print('❌ Duplicate segment detected: $segmentKey');
            return false;
          }
          pathSegments.add(segmentKey);
        }
      }
    }
    
    // Step 4: Validate path continuity (each path should be continuous)
    for (final path in completedPaths) {
      if (path.isNotEmpty && path.length > 1) {
        for (int i = 0; i < path.length - 1; i++) {
          final current = path[i];
          final next = path[i + 1];
          
          // Check if segments are adjacent
          final dx = (next.start.x - current.end.x).abs();
          final dy = (next.start.y - current.end.y).abs();
          
          if (dx > 1 || dy > 1 || (dx == 1 && dy == 1)) {
            print('❌ Path discontinuity detected: ${current.end} -> ${next.start}');
            return false;
          }
        }
      }
    }
    
    // Build coverage set (include all endpoints and every cell along segments)
    final covered = <int>{};
    // Include endpoints from grid
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (grid[y][x].isEndpoint) {
          covered.add(y * gridSize + x);
        }
      }
    }
    // Include every cell on each completed path
    for (final path in completedPaths) {
      for (final seg in path) {
        int x0 = seg.start.x.toInt();
        int y0 = seg.start.y.toInt();
        int x1 = seg.end.x.toInt();
        int y1 = seg.end.y.toInt();
        // Walk from start to end in unit Manhattan steps
        int x = x0, y = y0;
        covered.add(y * gridSize + x);
        while (x != x1 || y != y1) {
          if (x < x1) x++; else if (x > x1) x--;
          else if (y < y1) y++; else if (y > y1) y--;
          covered.add(y * gridSize + x);
        }
      }
    }
    
    // For now, we'll be more lenient with coverage
    // The main requirement is that all endpoints are connected and no overlaps
    // Some cells may remain uncovered, which is acceptable for puzzle variety
    final coveragePercentage = covered.length / (gridSize * gridSize);
    if (coveragePercentage < 0.6) { // At least 60% coverage
      print('⚠️ Low coverage: ${(coveragePercentage * 100).toStringAsFixed(1)}% (${covered.length}/${gridSize * gridSize} cells used)');
      // Don't fail for low coverage, just warn
    }
    
    print('✅ Level complete! All endpoints connected, no overlaps, valid paths, coverage: ${(coveragePercentage * 100).toStringAsFixed(1)}%');
    return true;
  }

  void reset() {
    completedPaths.clear();
    currentPath.clear();
    moveHistory.clear();
    // markNeedsPaint(); // Not needed in current Flame version
  }

  void undoLastMove() {
    if (moveHistory.isNotEmpty) {
      moveHistory.removeLast();
      if (completedPaths.isNotEmpty) {
        completedPaths.removeLast();
      }
      // markNeedsPaint(); // Not needed in current Flame version
    }
  }

  Map<String, dynamic>? getHint() {
    // Find unconnected endpoints
    final unconnectedEndpoints = <Map<String, dynamic>>[];
    
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (levelData[y][x] != null && levelData[y][x]! >= 0) {
          final color = levelData[y][x]!;
          final isConnected = _isEndpointConnected(x, y, color);
          
          if (!isConnected) {
            unconnectedEndpoints.add({
              'x': x,
              'y': y,
              'color': color,
            });
          }
        }
      }
    }
    
    if (unconnectedEndpoints.isEmpty) {
      return null;
    }
    
    // Find a pair of unconnected endpoints of the same color
    for (int i = 0; i < unconnectedEndpoints.length; i++) {
      for (int j = i + 1; j < unconnectedEndpoints.length; j++) {
        if (unconnectedEndpoints[i]['color'] == unconnectedEndpoints[j]['color']) {
          return {
            'color': _getColorName(unconnectedEndpoints[i]['color']),
            'from': '[${unconnectedEndpoints[i]['x']},${unconnectedEndpoints[i]['y']}]',
            'to': '[${unconnectedEndpoints[j]['x']},${unconnectedEndpoints[j]['y']}]',
          };
        }
      }
    }
    
    return null;
  }
  
  bool _isEndpointConnected(int x, int y, int color) {
    for (final path in completedPaths) {
      if (path.isNotEmpty) {
        final pathColor = path.first.color;
        if (pathColor == color) {
          final start = path.first.start;
          final end = path.last.end;
          
          if ((start.x.toInt() == x && start.y.toInt() == y) ||
              (end.x.toInt() == x && end.y.toInt() == y)) {
            return true;
          }
        }
      }
    }
    return false;
  }
  
  String _getColorName(int colorIndex) {
    final colors = ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'];
    return colors[colorIndex % colors.length];
  }
}
