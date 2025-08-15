import 'dart:math';
import 'package:flutter/material.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';

class PuzzleCreator {
  static const int _maxGridSize = 10;
  static const int _minGridSize = 3;
  static const int _maxColors = 6;
  static const int _minColors = 2;

  // Create a custom puzzle with specified parameters
  static List<List<int?>> createCustomPuzzle({
    required int gridSize,
    required int colorCount,
    required PuzzleDifficulty difficulty,
    int? seed,
  }) {
    if (gridSize < _minGridSize || gridSize > _maxGridSize) {
      throw ArgumentError('Grid size must be between $_minGridSize and $_maxGridSize');
    }
    if (colorCount < _minColors || colorCount > _maxColors) {
      throw ArgumentError('Color count must be between $_minColors and $_maxColors');
    }

    final random = seed != null ? Random(seed) : Random();
    
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return _createEasyPuzzle(gridSize, colorCount, random);
      case PuzzleDifficulty.medium:
        return _createMediumPuzzle(gridSize, colorCount, random);
      case PuzzleDifficulty.hard:
        return _createHardPuzzle(gridSize, colorCount, random);
      case PuzzleDifficulty.expert:
        return _createExpertPuzzle(gridSize, colorCount, random);
    }
  }

  // Create an easy puzzle (simple patterns, few obstacles)
  static List<List<int?>> _createEasyPuzzle(int gridSize, int colorCount, Random random) {
    final grid = List.generate(gridSize, (_) => List<int?>.filled(gridSize, null));
    
    // Place endpoints in simple patterns
    for (int color = 0; color < colorCount; color++) {
      final endpoints = _getEasyEndpoints(gridSize, color, random);
      grid[endpoints[0][0]][endpoints[0][1]] = color;
      grid[endpoints[1][0]][endpoints[1][1]] = color;
    }
    
    return grid;
  }

  // Create a medium puzzle (some obstacles, moderate complexity)
  static List<List<int?>> _createMediumPuzzle(int gridSize, int colorCount, Random random) {
    final grid = _createEasyPuzzle(gridSize, colorCount, random);
    
    // Add some obstacles (blocked cells)
    final obstacleCount = (gridSize * gridSize * 0.1).round(); // 10% obstacles
    for (int i = 0; i < obstacleCount; i++) {
      int x, y;
      do {
        x = random.nextInt(gridSize);
        y = random.nextInt(gridSize);
      } while (grid[x][y] != null); // Don't block endpoints
      
      grid[x][y] = -1; // -1 represents blocked cell
    }
    
    return grid;
  }

  // Create a hard puzzle (many obstacles, complex patterns)
  static List<List<int?>> _createHardPuzzle(int gridSize, int colorCount, Random random) {
    final grid = _createEasyPuzzle(gridSize, colorCount, random);
    
    // Add more obstacles (20% of grid)
    final obstacleCount = (gridSize * gridSize * 0.2).round();
    for (int i = 0; i < obstacleCount; i++) {
      int x, y;
      do {
        x = random.nextInt(gridSize);
        y = random.nextInt(gridSize);
      } while (grid[x][y] != null);
      
      grid[x][y] = -1;
    }
    
    // Add some teleporter cells (special mechanics)
    final teleporterCount = (colorCount * 0.5).round();
    for (int i = 0; i < teleporterCount; i++) {
      int x, y;
      do {
        x = random.nextInt(gridSize);
        y = random.nextInt(gridSize);
      } while (grid[x][y] != null);
      
      grid[x][y] = -2; // -2 represents teleporter
    }
    
    return grid;
  }

  // Create an expert puzzle (maximum complexity)
  static List<List<int?>> _createExpertPuzzle(int gridSize, int colorCount, Random random) {
    final grid = _createHardPuzzle(gridSize, colorCount, random);
    
    // Add color changer cells
    final changerCount = (colorCount * 0.3).round();
    for (int i = 0; i < changerCount; i++) {
      int x, y;
      do {
        x = random.nextInt(gridSize);
        y = random.nextInt(gridSize);
      } while (grid[x][y] != null);
      
      grid[x][y] = -3; // -3 represents color changer
    }
    
    // Add multiplier cells
    final multiplierCount = (colorCount * 0.2).round();
    for (int i = 0; i < multiplierCount; i++) {
      int x, y;
      do {
        x = random.nextInt(gridSize);
        y = random.nextInt(gridSize);
      } while (grid[x][y] != null);
      
      grid[x][y] = -4; // -4 represents multiplier
    }
    
    return grid;
  }

  // Get easy endpoint positions (simple patterns)
  static List<List<int>> _getEasyEndpoints(int gridSize, int color, Random random) {
    final endpoints = <List<int>>[];
    
    switch (color % 4) {
      case 0: // Top to bottom
        endpoints.add([0, random.nextInt(gridSize)]);
        endpoints.add([gridSize - 1, random.nextInt(gridSize)]);
        break;
      case 1: // Left to right
        endpoints.add([random.nextInt(gridSize), 0]);
        endpoints.add([random.nextInt(gridSize), gridSize - 1]);
        break;
      case 2: // Corner to corner
        endpoints.add([0, 0]);
        endpoints.add([gridSize - 1, gridSize - 1]);
        break;
      case 3: // Opposite corners
        endpoints.add([0, gridSize - 1]);
        endpoints.add([gridSize - 1, 0]);
        break;
    }
    
    return endpoints;
  }

  // Validate if a puzzle is solvable
  static bool isSolvable(List<List<int?>> grid) {
    // Basic validation: check if endpoints can be connected
    final endpoints = <List<int>>[];
    final colors = <int>{};
    
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        final cell = grid[i][j];
        if (cell != null && cell >= 0) {
          endpoints.add([i, j]);
          colors.add(cell);
        }
      }
    }
    
    // Each color should have exactly 2 endpoints
    for (final color in colors) {
      final colorEndpoints = endpoints.where((e) => grid[e[0]][e[1]] == color).toList();
      if (colorEndpoints.length != 2) {
        return false;
      }
    }
    
    return true;
  }

  // Calculate optimal moves for a puzzle
  static int calculateOptimalMoves(List<List<int?>> grid) {
    final colors = <int>{};
    int totalDistance = 0;
    
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        final cell = grid[i][j];
        if (cell != null && cell >= 0) {
          colors.add(cell);
        }
      }
    }
    
    // Calculate minimum distance for each color pair
    for (final color in colors) {
      final colorEndpoints = <List<int>>[];
      for (int i = 0; i < grid.length; i++) {
        for (int j = 0; j < grid[i].length; j++) {
          if (grid[i][j] == color) {
            colorEndpoints.add([i, j]);
          }
        }
      }
      
      if (colorEndpoints.length == 2) {
        final distance = _manhattanDistance(colorEndpoints[0], colorEndpoints[1]);
        totalDistance += distance;
      }
    }
    
    return totalDistance;
  }

  // Calculate Manhattan distance between two points
  static int _manhattanDistance(List<int> point1, List<int> point2) {
    return (point1[0] - point2[0]).abs() + (point1[1] - point2[1]).abs();
  }

  // Generate a random puzzle with random difficulty
  static List<List<int?>> generateRandomPuzzle({
    int? minGridSize,
    int? maxGridSize,
    int? minColors,
    int? maxColors,
  }) {
    final random = Random();
    final gridSize = (minGridSize ?? _minGridSize) + 
                     random.nextInt((maxGridSize ?? _maxGridSize) - (minGridSize ?? _minGridSize) + 1);
    final colorCount = (minColors ?? _minColors) + 
                       random.nextInt((maxColors ?? _maxColors) - (minColors ?? _minColors) + 1);
    final difficulty = PuzzleDifficulty.values[random.nextInt(PuzzleDifficulty.values.length)];
    
    return createCustomPuzzle(
      gridSize: gridSize,
      colorCount: colorCount,
      difficulty: difficulty,
    );
  }
}

enum PuzzleDifficulty {
  easy,
  medium,
  hard,
  expert,
}

extension PuzzleDifficultyExtension on PuzzleDifficulty {
  String get displayName {
    switch (this) {
      case PuzzleDifficulty.easy:
        return 'Easy';
      case PuzzleDifficulty.medium:
        return 'Medium';
      case PuzzleDifficulty.hard:
        return 'Hard';
      case PuzzleDifficulty.expert:
        return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case PuzzleDifficulty.easy:
        return 'Simple patterns, few obstacles';
      case PuzzleDifficulty.medium:
        return 'Some obstacles, moderate complexity';
      case PuzzleDifficulty.hard:
        return 'Many obstacles, complex patterns';
      case PuzzleDifficulty.expert:
        return 'Maximum complexity with special cells';
    }
  }

  Color get color {
    switch (this) {
      case PuzzleDifficulty.easy:
        return const Color(0xFF4CAF50); // Green
      case PuzzleDifficulty.medium:
        return const Color(0xFFFF9800); // Orange
      case PuzzleDifficulty.hard:
        return const Color(0xFFF44336); // Red
      case PuzzleDifficulty.expert:
        return const Color(0xFF9C27B0); // Purple
    }
  }
}
