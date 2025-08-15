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

LevelConfig configForLevel(int levelIndex) {
  int grid;
  int colors;
  double t;
  if (levelIndex <= 30)      { grid = 5; colors = (levelIndex <= 15) ? 2 : 3; t = levelIndex / 30.0; }
  else if (levelIndex <= 80) { grid = 6; colors = 3 + ((levelIndex - 31) ~/ 25); t = (levelIndex - 31) / 49.0; }
  else if (levelIndex <= 150){ grid = 7; colors = 4 + ((levelIndex - 81) ~/ 35); t = (levelIndex - 81) / 69.0; }
  else if (levelIndex <= 260){ grid = 8; colors = 5; t = (levelIndex - 151) / 109.0; }
  else if (levelIndex <= 420){ grid = 9; colors = (levelIndex < 340) ? 5 : 6; t = (levelIndex - 261) / 159.0; }
  else if (levelIndex <= 800){ grid = 10; colors = 6; t = (levelIndex - 421) / 379.0; }
  else                       { grid = 10; colors = 6; t = ((levelIndex - 801) % 50) / 50.0; }

  final twist = _lerp(0.10, 0.75, t);
  final minSeg = (levelIndex < 40) ? 2 : 3;
  final seed = levelIndex.hashCode;
  return LevelConfig(_clampInt(grid,5,10), _clampInt(colors,2,6), minSeg, twist, seed);
}
