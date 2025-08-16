import 'dart:math';
import 'package:color_connect/features/game/domain/entities/puzzle_generator_fresh.dart';

class LevelData {
  // Level progression system
  static const int totalLevels = 300;
  static const int levelsPerPack = 50;
  static const int packsCount = totalLevels ~/ levelsPerPack;
  
  // Star requirements for unlocking packs
  static const Map<int, int> packUnlockRequirements = {
    1: 0,    // Pack 1: Tutorial (unlocked by default)
    2: 30,   // Pack 2: Need 30 stars
    3: 75,   // Pack 3: Need 75 stars
    4: 135,  // Pack 4: Need 135 stars
    5: 210,  // Pack 5: Need 210 stars
    6: 300,  // Pack 6: Need 300 stars
    7: 405,  // Pack 7: Need 405 stars
    8: 525,  // Pack 8: Need 525 stars
    9: 660,  // Pack 9: Need 660 stars
    10: 810, // Pack 10: Need 810 stars
    11: 975, // Pack 11: Need 975 stars
    12: 1155,// Pack 12: Need 1155 stars
    13: 1350,// Pack 13: Need 1350 stars
    14: 1560,// Pack 14: Need 1560 stars
    15: 1785,// Pack 15: Need 1785 stars
    16: 2025,// Pack 16: Need 2025 stars
  };

  // Get level data by level ID (1-300)
  static List<List<int?>> getLevelData(int levelId) {
    if (levelId < 1 || levelId > totalLevels) {
      throw ArgumentError('Level ID must be between 1 and $totalLevels');
    }

    // Generate level based on ID for consistency
    final random = Random(levelId); // Seed with level ID for deterministic generation
    
    // Determine grid size and complexity based on level
    final packNumber = ((levelId - 1) ~/ levelsPerPack) + 1;
    final levelInPack = ((levelId - 1) % levelsPerPack) + 1;
    
    // Grid size progression: 3x3 to 10x10
    final baseGridSize = 3 + (packNumber - 1) ~/ 2;
    final gridSize = min(baseGridSize + (levelInPack ~/ 10), 10);
    
    // Color count progression: 2 to 6 colors
    final baseColorCount = 2 + (packNumber - 1) ~/ 3;
    final colorCount = min(baseColorCount + (levelInPack ~/ 15), 6);
    
    return _generateSolvableGrid(gridSize, colorCount, random);
  }

  // Get grid size for a level
  static int getGridSize(int levelId) {
    final packNumber = ((levelId - 1) ~/ levelsPerPack) + 1;
    final levelInPack = ((levelId - 1) % levelsPerPack) + 1;
    final baseGridSize = 3 + (packNumber - 1) ~/ 2;
    return min(baseGridSize + (levelInPack ~/ 10), 10);
  }

  // Get color count for a level
  static int getColorCount(int levelId) {
    final packNumber = ((levelId - 1) ~/ levelsPerPack) + 1;
    final levelInPack = ((levelId - 1) % levelsPerPack) + 1;
    final baseColorCount = 2 + (packNumber - 1) ~/ 3;
    return min(baseColorCount + (levelInPack ~/ 15), 6);
  }

  // Calculate optimal moves for a level
  static int getOptimalMoves(int levelId) {
    final gridSize = getGridSize(levelId);
    final colorCount = getColorCount(levelId);
    
    // More accurate optimal moves calculation
    // Each color needs to connect 2 endpoints, so minimum is colorCount
    int baseMoves = colorCount;
    
    // Add complexity based on grid size and color count
    if (gridSize <= 4) {
      baseMoves += colorCount; // Simple grids: add 1 move per color for path finding
    } else if (gridSize <= 6) {
      baseMoves += colorCount + 1; // Medium complexity: add 1-2 extra moves
    } else if (gridSize <= 8) {
      baseMoves += colorCount + 2; // High complexity: add 2-3 extra moves
    } else {
      baseMoves += colorCount + 3; // Expert complexity: add 3-4 extra moves
    }
    
    return baseMoves;
  }

  // Get pack number for a level
  static int getPackNumber(int levelId) {
    return ((levelId - 1) ~/ levelsPerPack) + 1;
  }

  // Get pack name
  static String getPackName(int packNumber) {
    switch (packNumber) {
      case 1: return 'Tutorial';
      case 2: return 'Beginner';
      case 3: return 'Easy';
      case 4: return 'Easy+';
      case 5: return 'Medium';
      case 6: return 'Medium+';
      case 7: return 'Hard';
      case 8: return 'Hard+';
      case 9: return 'Expert';
      case 10: return 'Expert+';
      case 11: return 'Master';
      case 12: return 'Master+';
      case 13: return 'Grandmaster';
      case 14: return 'Grandmaster+';
      case 15: return 'Legend';
      case 16: return 'Legend+';
      default: return 'Pack $packNumber';
    }
  }

  // Get pack color based on difficulty
  static int getPackColor(int packNumber) {
    if (packNumber <= 2) return 0xFF4CAF50; // Green - Easy
    if (packNumber <= 4) return 0xFF8BC34A; // Light Green - Easy+
    if (packNumber <= 6) return 0xFFFF9800; // Orange - Medium
    if (packNumber <= 8) return 0xFFFF5722; // Deep Orange - Hard
    if (packNumber <= 10) return 0xFFF44336; // Red - Expert
    if (packNumber <= 12) return 0xFF9C27B0; // Purple - Master
    if (packNumber <= 14) return 0xFF3F51B5; // Indigo - Grandmaster
    return 0xFF000000; // Black - Legend
  }

  // Check if a pack is unlocked based on total stars
  static bool isPackUnlocked(int packNumber, int totalStars) {
    final requiredStars = packUnlockRequirements[packNumber] ?? 0;
    return totalStars >= requiredStars;
  }

  // Get total stars needed for next pack
  static int getStarsForNextPack(int currentPack, int totalStars) {
    final nextPack = currentPack + 1;
    if (nextPack > packsCount) return 0; // All packs unlocked
    
    final requiredStars = packUnlockRequirements[nextPack] ?? 0;
    return max(0, requiredStars - totalStars);
  }

  // Generate a solvable grid using the fresh Hamiltonian snake path generator
  static List<List<int?>> _generateSolvableGrid(int gridSize, int colorCount, Random random) {
    // Use the fresh generator - guaranteed solvable with full coverage
    return PuzzleGeneratorFresh.generate(
      gridSize: gridSize,
      colorCount: colorCount,
      seed: random.nextInt(1000000),
      minSegmentLen: 2,
    );
  }

  // Get level difficulty description
  static String getLevelDifficulty(int levelId) {
    final packNumber = getPackNumber(levelId);
    final packName = getPackName(packNumber);
    final gridSize = getGridSize(levelId);
    final colorCount = getColorCount(levelId);
    
    return '$packName • ${gridSize}x$gridSize • $colorCount colors';
  }

  // Get all levels in a pack
  static List<int> getLevelsInPack(int packNumber) {
    final startLevel = (packNumber - 1) * levelsPerPack + 1;
    final endLevel = min(packNumber * levelsPerPack, totalLevels);
    return List.generate(endLevel - startLevel + 1, (i) => startLevel + i);
  }

  // Get total levels in a pack
  static int getPackLevelCount(int packNumber) {
    if (packNumber == packsCount) {
      return totalLevels - (packNumber - 1) * levelsPerPack;
    }
    return levelsPerPack;
  }

  // Static method for generating levels
  static List<List<int?>> generateLevel({
    required int gridSize,
    required int colorCount,
    required int seed,
    int minSegmentLen = 2,
  }) {
    // Use the fresh generator - guaranteed solvable with full coverage
    return PuzzleGeneratorFresh.generate(
      gridSize: gridSize,
      colorCount: colorCount,
      seed: seed,
      minSegmentLen: minSegmentLen,
    );
  }

  // Hash seed method for deterministic level generation
  static int hashSeed(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash + input.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash;
  }
}
