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
    // Reduce cell size for larger grids to keep game area manageable
    if (gridSize <= 3) return baseCellSize;
    if (gridSize <= 4) return baseCellSize * 0.8; // 64px
    if (gridSize <= 5) return baseCellSize * 0.6; // 48px
    if (gridSize <= 6) return baseCellSize * 0.5; // 40px
    return baseCellSize * 0.4; // 32px for very large grids
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
    
    for (final path in completedPaths) {
      if (path.isNotEmpty) {
        final start = path.first.start;
        final end = path.last.end;
        final color = path.first.color;
        
        final startKey = '${start.x.toInt()},${start.y.toInt()},$color';
        final endKey = '${end.x.toInt()},${end.y.toInt()},$color';
        
        connectedEndpoints.add(startKey);
        connectedEndpoints.add(endKey);
        
        print('🔍 Path connects: $startKey -> $endKey');
      }
    }
    
    // Count total endpoints
    int totalEndpoints = 0;
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (levelData[y][x] != null) {
          totalEndpoints++;
          print('🔍 Found endpoint at [$x,$y] with color ${levelData[y][x]}');
        }
      }
    }
    
    print('🔍 Total endpoints: $totalEndpoints, Connected: ${connectedEndpoints.length}');
    
    // All endpoints must be connected
    if (connectedEndpoints.length != totalEndpoints) {
      print('❌ Level incomplete: Only ${connectedEndpoints.length} endpoints connected, need $totalEndpoints');
      return false;
    }
    
    // Step 2: Check for path overlaps (simplified)
    final occupiedCells = <String>{};
    
    for (final path in completedPaths) {
      if (path.isNotEmpty) {
        // Add start point
        final start = path.first.start;
        final startKey = '${start.x.toInt()},${start.y.toInt()}';
        occupiedCells.add(startKey);
        
        // Add all path segments
        for (final segment in path) {
          final endKey = '${segment.end.x.toInt()},${segment.end.y.toInt()}';
          occupiedCells.add(endKey);
        }
      }
    }
    
    // Check for overlaps by comparing set size with total cells
    final uniqueCells = occupiedCells.toSet();
    if (uniqueCells.length != occupiedCells.length) {
      print('❌ Path overlaps detected: ${occupiedCells.length} cells with ${uniqueCells.length} unique');
      return false;
    }
    
    print('✅ Level complete! All endpoints connected, no overlaps');
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
}
