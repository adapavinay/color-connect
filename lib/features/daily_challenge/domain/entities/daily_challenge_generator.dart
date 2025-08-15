import 'dart:math';
import 'package:color_connect/features/daily_challenge/domain/entities/daily_challenge.dart';

class DailyChallengeGenerator {
  static const int _maxGridSize = 7;
  static const int _minGridSize = 3;
  static const int _maxColors = 4;
  static const int _minColors = 2;

  // Generate today's challenge based on the current date
  static DailyChallenge generateTodayChallenge() {
    final now = DateTime.now();
    final seed = _generateSeed(now);
    final random = Random(seed);
    
    // Generate grid size (3x3 to 7x7)
    final gridSize = _minGridSize + (seed % (_maxGridSize - _minGridSize + 1));
    
    // Generate color count (2 to 4 colors)
    final colorCount = _minColors + (seed % (_maxColors - _minColors + 1));
    
    // Generate solvable grid data
    final gridData = _generateSolvableGridData(gridSize, colorCount, random);
    
    // Calculate optimal moves based on grid size and colors
    final optimalMoves = _calculateOptimalMoves(gridSize, colorCount);
    
    return DailyChallenge(
      date: now,
      levelIndex: -1, // Special index for daily challenges
      gridData: gridData,
      gridSize: gridSize,
      colorCount: colorCount,
      optimalMoves: optimalMoves,
    );
  }

  // Generate a seed based on the date (same date = same puzzle)
  static int _generateSeed(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }

  // Generate solvable grid data with endpoints for each color
  static List<List<int?>> _generateSolvableGridData(int gridSize, int colorCount, Random random) {
    // Create simple, solvable patterns based on grid size
    if (gridSize == 3) {
      return _generate3x3Solvable(colorCount, random);
    } else if (gridSize == 4) {
      return _generate4x4Solvable(colorCount, random);
    } else if (gridSize == 5) {
      return _generate5x5Solvable(colorCount, random);
    } else {
      return _generate6x6PlusSolvable(gridSize, colorCount, random);
    }
  }

  // Generate 3x3 solvable puzzle
  static List<List<int?>> _generate3x3Solvable(int colorCount, Random random) {
    final grid = List.generate(3, (_) => List<int?>.filled(3, null));
    
    if (colorCount == 2) {
      // Simple 2-color pattern - red at top corners, blue at bottom corners
      grid[0][0] = 0; grid[0][2] = 0; // Red dots
      grid[2][0] = 1; grid[2][2] = 1; // Blue dots
    } else if (colorCount == 3) {
      // 3-color pattern
      grid[0][0] = 0; grid[0][2] = 0; // Red dots
      grid[1][0] = 1; grid[1][2] = 1; // Blue dots  
      grid[2][0] = 2; grid[2][2] = 2; // Green dots
    } else if (colorCount == 4) {
      // 4-color pattern - place colors at corners and edges
      grid[0][0] = 0; grid[0][2] = 0; // Red dots
      grid[1][0] = 1; grid[1][2] = 1; // Blue dots
      grid[2][0] = 2; grid[2][2] = 2; // Green dots
      grid[0][1] = 3; grid[2][1] = 3; // Yellow dots (middle edges)
    }
    
    return grid;
  }

  // Generate 4x4 solvable puzzle
  static List<List<int?>> _generate4x4Solvable(int colorCount, Random random) {
    final grid = List.generate(4, (_) => List<int?>.filled(4, null));
    
    if (colorCount == 2) {
      grid[0][0] = 0; grid[0][3] = 0; // Red dots
      grid[3][0] = 1; grid[3][3] = 1; // Blue dots
    } else if (colorCount == 3) {
      grid[0][0] = 0; grid[0][3] = 0; // Red dots
      grid[1][0] = 1; grid[1][3] = 1; // Blue dots
      grid[2][0] = 2; grid[2][3] = 2; // Green dots
    } else if (colorCount == 4) {
      grid[0][0] = 0; grid[0][3] = 0; // Red dots
      grid[1][0] = 1; grid[1][3] = 1; // Blue dots
      grid[2][0] = 2; grid[2][3] = 2; // Green dots
      grid[3][0] = 3; grid[3][3] = 3; // Yellow dots
    }
    
    return grid;
  }

  // Generate 5x5 solvable puzzle
  static List<List<int?>> _generate5x5Solvable(int colorCount, Random random) {
    final grid = List.generate(5, (_) => List<int?>.filled(5, null));
    
    if (colorCount == 2) {
      grid[0][0] = 0; grid[0][4] = 0; // Red dots
      grid[4][0] = 1; grid[4][4] = 1; // Blue dots
    } else if (colorCount == 3) {
      grid[0][0] = 0; grid[0][4] = 0; // Red dots
      grid[2][0] = 1; grid[2][4] = 1; // Blue dots
      grid[4][0] = 2; grid[4][4] = 2; // Green dots
    } else if (colorCount == 4) {
      grid[0][0] = 0; grid[0][4] = 0; // Red dots
      grid[1][0] = 1; grid[1][4] = 1; // Blue dots
      grid[3][0] = 2; grid[3][4] = 2; // Green dots
      grid[4][0] = 3; grid[4][4] = 3; // Yellow dots
    }
    
    return grid;
  }

  // Generate 6x6+ solvable puzzle
  static List<List<int?>> _generate6x6PlusSolvable(int gridSize, int colorCount, Random random) {
    final grid = List.generate(gridSize, (_) => List<int?>.filled(gridSize, null));
    
    if (colorCount == 2) {
      grid[0][0] = 0; grid[0][gridSize-1] = 0; // Red dots
      grid[gridSize-1][0] = 1; grid[gridSize-1][gridSize-1] = 1; // Blue dots
    } else if (colorCount == 3) {
      grid[0][0] = 0; grid[0][gridSize-1] = 0; // Red dots
      grid[gridSize~/2][0] = 1; grid[gridSize~/2][gridSize-1] = 1; // Blue dots
      grid[gridSize-1][0] = 2; grid[gridSize-1][gridSize-1] = 2; // Green dots
    } else if (colorCount == 4) {
      grid[0][0] = 0; grid[0][gridSize-1] = 0; // Red dots
      grid[1][0] = 1; grid[1][gridSize-1] = 1; // Blue dots
      grid[gridSize-2][0] = 2; grid[gridSize-2][gridSize-1] = 2; // Green dots
      grid[gridSize-1][0] = 3; grid[gridSize-1][gridSize-1] = 3; // Yellow dots
    }
    
    return grid;
  }

  // Calculate optimal moves for the puzzle
  static int _calculateOptimalMoves(int gridSize, int colorCount) {
    // Base calculation: each color needs at least 2 moves to connect endpoints
    int baseMoves = colorCount * 2;
    
    // Add complexity based on grid size
    if (gridSize >= 5) baseMoves += 2;
    if (gridSize >= 6) baseMoves += 2;
    if (gridSize >= 7) baseMoves += 2;
    
    // Add complexity based on color count
    if (colorCount >= 3) baseMoves += 1;
    if (colorCount >= 4) baseMoves += 1;
    
    return baseMoves;
  }

  // Generate a challenge for a specific date (for testing or past challenges)
  static DailyChallenge generateChallengeForDate(DateTime date) {
    final seed = _generateSeed(date);
    final random = Random(seed);
    
    final gridSize = _minGridSize + (seed % (_maxGridSize - _minGridSize + 1));
    final colorCount = _minColors + (seed % (_maxColors - _minColors + 1));
    
    final gridData = _generateSolvableGridData(gridSize, colorCount, random);
    final optimalMoves = _calculateOptimalMoves(gridSize, colorCount);
    
    return DailyChallenge(
      date: date,
      levelIndex: -1,
      gridData: gridData,
      gridSize: gridSize,
      colorCount: colorCount,
      optimalMoves: optimalMoves,
    );
  }

  // Generate next few days of challenges (for preview)
  static List<DailyChallenge> generateUpcomingChallenges(int days) {
    final challenges = <DailyChallenge>[];
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final futureDate = DateTime(now.year, now.month, now.day + i);
      challenges.add(generateChallengeForDate(futureDate));
    }
    
    return challenges;
  }
}
