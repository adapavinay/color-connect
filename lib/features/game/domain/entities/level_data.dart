import 'package:color_connect/features/game/domain/entities/path_segment.dart';

class LevelData {
  // Sample level data with optimal move counts for 3-star rating
  // Each color has exactly 2 endpoints to connect
  static const List<List<List<int?>>> levels = [
    // Level 1: 3x3, 1 color (red), optimal: 2 moves
    [
      [0, null, 0],
      [null, null, null],
      [null, null, null]
    ],
    
    // Level 2: 3x3, 2 colors, optimal: 4 moves
    [
      [0, null, 0],
      [null, null, null],
      [1, null, 1]
    ],
    
    // Level 3: 3x3, 3 colors, optimal: 6 moves
    [
      [0, null, 0],
      [1, null, 1],
      [2, null, 2]
    ],
    
    // Level 4: 4x4, 2 colors, optimal: 6 moves
    [
      [0, null, null, 0],
      [null, null, null, null],
      [null, null, null, null],
      [1, null, null, 1]
    ],
    
    // Level 5: 4x4, 3 colors, optimal: 8 moves
    [
      [0, null, 0, null],
      [null, 1, null, null],
      [null, null, null, 1],
      [2, null, null, 2]
    ],
    
    // Level 6: 5x5, 2 colors, optimal: 8 moves
    [
      [0, null, null, null, 0],
      [null, null, null, null, null],
      [null, null, null, null, null],
      [null, null, null, null, null],
      [1, null, null, null, 1]
    ],
    
    // Level 7: 5x5, 3 colors, optimal: 10 moves
    [
      [0, null, null, 0, null],
      [null, 1, null, null, null],
      [null, null, null, null, null],
      [null, null, null, null, 1],
      [2, null, null, null, 2]
    ],
    
    // Level 8: 6x6, 2 colors, optimal: 10 moves
    [
      [0, null, null, null, null, 0],
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
      [1, null, null, null, null, 1]
    ],
    
    // Level 9: 6x6, 3 colors, optimal: 12 moves
    [
      [0, null, null, 0, null, null],
      [null, 1, null, null, null, null],
      [null, null, null, null, null, null],
      [null, null, null, null, null, null],
      [null, null, null, null, 1, null],
      [2, null, null, null, null, 2]
    ],
    
    // Level 10: 7x7, 2 colors, optimal: 12 moves
    [
      [0, null, null, null, null, null, 0],
      [null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null],
      [1, null, null, null, null, null, 1]
    ],
  ];

  // Optimal move counts for 3-star rating (realistic values)
  static const List<int> optimalMoves = [2, 4, 6, 6, 8, 8, 10, 10, 12, 12];

  // Get level data by index
  static List<List<int?>> getLevel(int index) {
    if (index >= 0 && index < levels.length) {
      return levels[index];
    }
    throw RangeError('Level index $index is out of range');
  }

  // Get grid size by level index
  static int getGridSize(int index) {
    if (index >= 0 && index < levels.length) {
      return levels[index].length;
    }
    throw RangeError('Level index $index is out of range');
  }

  // Get color count by level index
  static int getColorCount(int index) {
    if (index >= 0 && index < levels.length) {
      final level = levels[index];
      final colors = <int>{};
      for (final row in level) {
        for (final cell in row) {
          if (cell != null) {
            colors.add(cell);
          }
        }
      }
      return colors.length;
    }
    throw RangeError('Level index $index is out of range');
  }

  // Get optimal move count for 3-star rating
  static int getOptimalMoves(int index) {
    if (index >= 0 && index < optimalMoves.length) {
      return optimalMoves[index];
    }
    throw RangeError('Level index $index is out of range');
  }

  // Calculate star rating based on move count
  static int calculateStars(int levelIndex, int actualMoves) {
    final optimal = getOptimalMoves(levelIndex);
    
    if (actualMoves <= optimal) return 3;        // Perfect! 3 stars
    if (actualMoves <= optimal * 1.2) return 2; // Good! 2 stars  
    if (actualMoves <= optimal * 1.5) return 1; // OK! 1 star
    return 0;                                    // Try again! 0 stars
  }
}
