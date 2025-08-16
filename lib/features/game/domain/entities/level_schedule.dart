import 'dart:math';
import 'package:color_connect/features/game/domain/entities/level_data.dart';

class LevelConfig {
  final int grid;
  final int colors;
  final int minSegmentLen;
  final double twistiness;
  final int seed;
  const LevelConfig(this.grid, this.colors, this.minSegmentLen, this.twistiness, this.seed);
}

int _clampInt(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);
double _lerp(double a, double b, double t) => a + (b - a) * t;

LevelConfig configForLevel(int i) {
  // Levels 1-3: 3x3 grids (simple tutorial)
  if (i <= 3) return LevelConfig(3, 3, 2, 0.1, LevelData.hashSeed('S1:$i'));
  
  // Levels 4-20: 4x4 grids
  if (i <= 20) return LevelConfig(4, 3, 2, 0.15, LevelData.hashSeed('S1:$i'));
  
  // Levels 21-60: 5x5 grids
  if (i <= 60) return LevelConfig(5, 4, 2, 0.2, LevelData.hashSeed('S1:$i'));
  
  // Levels 61-100: 6x6 grids
  if (i <= 100) return LevelConfig(6, 4, 2, 0.25, LevelData.hashSeed('S1:$i'));
  
  // Levels 101-160: 7x7 grids
  if (i <= 160) return LevelConfig(7, 5, 2, 0.3, LevelData.hashSeed('S1:$i'));
  
  // Levels 161-220: 8x8 grids
  if (i <= 220) return LevelConfig(8, 5, 2, 0.35, LevelData.hashSeed('S1:$i'));
  
  // Levels 221-300: 9x9 grids
  return LevelConfig(9, 6, 2, 0.4, LevelData.hashSeed('S1:$i'));
}

// Star gating function - progressive unlocking based on grid size bands
int starsRequiredForLevel(int levelIndex) {
  if (levelIndex <= 3) return 0;      // 3x3 tutorial levels
  if (levelIndex <= 20) return 0;     // 4x4 beginner levels
  if (levelIndex <= 60) return 30;    // 5x5 easy levels
  if (levelIndex <= 100) return 75;   // 6x6 medium levels
  if (levelIndex <= 160) return 135;  // 7x7 hard levels
  if (levelIndex <= 220) return 210;  // 8x8 expert levels
  if (levelIndex <= 300) return 300;  // 9x9 master levels
  return 405; // Beyond 300 levels
}
