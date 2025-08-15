import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:color_connect/features/game/domain/entities/puzzle_grid.dart';
import 'package:color_connect/features/game/domain/entities/path_segment.dart';

class ColorConnectGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFFF7F8FC);
  
  late PuzzleGrid puzzleGrid;
  List<PathSegment> currentPath = [];
  int? currentColor;
  
  final int gridSize;
  final List<List<int?>> levelData;
  final Function(bool) onLevelComplete;
  final Function(int) onMoveCount;

  ColorConnectGame({
    required this.gridSize,
    required this.levelData,
    required this.onLevelComplete,
    required this.onMoveCount,
  }) {
    print('🎯 ColorConnectGame created with gridSize: $gridSize, levelData: $levelData');
  }

  @override
  Future<void> onLoad() async {
    print('🚀 ColorConnectGame.onLoad() called');
    await super.onLoad();
    
    // Create and add the puzzle grid
    puzzleGrid = PuzzleGrid(
      gridSize: gridSize,
      levelData: levelData,
      onPathComplete: _onPathComplete,
    );
    
    add(puzzleGrid);
  }

  // Public methods called from GamePage
  void startPath(Vector2 position, int color) {
    print('🎯 Starting new path at position $position with color $color');
    
    // Reset current path
    currentPath.clear();
    currentColor = color;
    
    // Add first segment (start point)
    currentPath.add(PathSegment(
      start: position,
      end: position,
      color: color,
    ));
    
    // Update the grid display
    puzzleGrid.updatePath(currentPath);
    
    print('✅ Path started! Current color: $currentColor, Path length: ${currentPath.length}');
  }

  void updatePath(Vector2 position) {
    if (currentPath.isEmpty || currentColor == null) {
      print('❌ Cannot update path: no active path or color');
      return;
    }
    
    final lastSegment = currentPath.last;
    if (lastSegment.end == position) {
      // Same position, no update needed
      return;
    }
    
    print('🔄 Attempting to update path to: $position');
    
    // Check if the move is valid
    if (_isValidMove(lastSegment.end, position)) {
      print('✅ Valid move, adding path segment');
      
      // Add new segment
      currentPath.add(PathSegment(
        start: lastSegment.end,
        end: position,
        color: currentColor!,
      ));
      
      // Update the grid display
      puzzleGrid.updatePath(currentPath);
      print('🔄 Path updated: ${currentPath.length} segments');
    } else {
      print('❌ Invalid move: not adjacent or cell occupied');
    }
  }

  void endPath(Vector2 position) {
    if (currentPath.isEmpty || currentColor == null) {
      print('❌ Cannot end path: no active path or color');
      return;
    }
    
    // Final position update if needed
    final lastSegment = currentPath.last;
    if (lastSegment.end != position) {
      print('🔄 Final path update to: $position');
      updatePath(position);
    }
    
    // Check if path connects to a valid endpoint
    final endCell = puzzleGrid.getCell(position.x.toInt(), position.y.toInt());
    print('🏁 Path ended at position $position');
    print('🔍 End cell: ${endCell?.isEndpoint}, color: ${endCell?.color}');
    print('🎨 Current path color: $currentColor');
    
    if (endCell != null && endCell.isEndpoint && endCell.color == currentColor) {
      print('✅ Path connects to matching endpoint!');
      _completePath();
    } else {
      print('❌ Path does not connect to matching endpoint');
      print('💡 Tip: Path must end at an endpoint of the same color');
      _cancelPath();
    }
  }

  bool _isValidMove(Vector2 from, Vector2 to) {
    // Check if move is to an adjacent cell
    final dx = (to.x - from.x).abs();
    final dy = (to.y - from.y).abs();
    
    if (!((dx == 1 && dy == 0) || (dx == 0 && dy == 1))) {
      print('❌ Move not adjacent: from $from to $to');
      return false;
    }
    
    // Check if the target cell is already occupied by a completed path
    if (_isCellOccupiedByCompletedPath(to)) {
      print('❌ Cell occupied by completed path: $to');
      return false;
    }
    
    // Check if the target cell is already part of current path (except start)
    if (_isCellInCurrentPath(to)) {
      print('❌ Cell already in current path: $to');
      return false;
    }
    
    return true;
  }
  
  bool _isCellOccupiedByCompletedPath(Vector2 position) {
    for (final path in puzzleGrid.completedPathsList) {
      if (path.isNotEmpty) {
        // Check start point
        if (path.first.start == position) {
          return true;
        }
        
        // Check all path segments
        for (final segment in path) {
          if (segment.end == position) {
            return true;
          }
        }
      }
    }
    return false;
  }
  
  bool _isCellInCurrentPath(Vector2 position) {
    if (currentPath.isEmpty) return false;
    
    // Allow returning to start point for path completion
    final startPoint = currentPath.first.start;
    if (position == startPoint) {
      return false; // Allow returning to start
    }
    
    // Check if position is already in current path
    for (final segment in currentPath) {
      if (segment.end == position) {
        return true;
      }
    }
    
    return false;
  }

  void _completePath() {
    print('🔍 Completing path with ${currentPath.length} segments');
    
    // Store path length before clearing
    final pathLength = currentPath.length;
    
    // Clean up the path - remove any redundant single-cell segments
    final cleanedPath = <PathSegment>[];
    for (final segment in currentPath) {
      // Only add segments that actually represent movement
      if (segment.start != segment.end) {
        cleanedPath.add(segment);
      }
    }
    
    // If we have a single-cell path (start == end), create a minimal path
    if (cleanedPath.isEmpty && currentPath.isNotEmpty) {
      final firstSegment = currentPath.first;
      cleanedPath.add(PathSegment(
        start: firstSegment.start,
        end: firstSegment.start, // Same point for single-cell paths
        color: firstSegment.color,
      ));
    }
    
    // Add the cleaned completed path to the grid
    puzzleGrid.addCompletedPath(cleanedPath.isNotEmpty ? cleanedPath : currentPath);
    
    // Reset current path
    currentPath.clear();
    currentColor = null;
    
    // Check if level is complete
    print('🔍 Checking if level is complete...');
    final isComplete = puzzleGrid.isLevelComplete();
    print('🔍 Level complete check result: $isComplete');
    
    if (isComplete) {
      print('🎉 Level is complete! Calling onLevelComplete callback');
      onLevelComplete(true);
    } else {
      print('❌ Level is not complete yet');
    }
    
    // Increment move counter by the number of actual moves (segments minus the starting position)
    // The first segment [start, start] doesn't count as a move
    final actualMoves = pathLength > 0 ? pathLength - 1 : 0;
    print('🎯 Move counting: $pathLength segments = $actualMoves actual moves');
    onMoveCount(actualMoves);
    
    print('✅ Path completed! Current color reset to: $currentColor');
  }

  void _cancelPath() {
    print('❌ Cancelling incomplete path');
    
    // Clear the current path from display
    puzzleGrid.clearCurrentPath();
    
    // Reset current path
    currentPath.clear();
    currentColor = null;
    
    print('❌ Path cancelled! Current color reset to: $currentColor');
  }

  void _onPathComplete(List<PathSegment> path) {
    // This will be called when a path is completed
    print('🎯 Path completed callback: ${path.length} segments');
  }

  void resetLevel() {
    print('🔄 Resetting level');
    puzzleGrid.reset();
    currentPath.clear();
    currentColor = null;
  }

  void undoLastMove() {
    print('↩️ Undoing last move');
    puzzleGrid.undoLastMove();
  }
}
