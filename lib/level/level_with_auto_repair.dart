import 'levels.dart';
import 'level_auto_repair.dart';

/// Use this accessor wherever the game fetches a level to guarantee it is solvable.
/// It returns a deep copy and, if needed, relocates ONE endpoint minimally.
List<List<String?>> levelWithAutoRepair(int index) {
  final grid = List.generate(levels[index].length,
      (r) => List<String?>.from(levels[index][r]));
  return LevelAutoRepair.autoRepairIfUnsolvable(grid);
}
