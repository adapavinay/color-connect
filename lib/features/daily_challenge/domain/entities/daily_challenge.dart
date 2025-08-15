

class DailyChallenge {
  final DateTime date;
  final int levelIndex;
  final List<List<int?>> gridData;
  final int gridSize;
  final int colorCount;
  final int optimalMoves;
  final bool isCompleted;
  final int? stars;
  final int? bestMoves;
  final int streak;

  const DailyChallenge({
    required this.date,
    required this.levelIndex,
    required this.gridData,
    required this.gridSize,
    required this.colorCount,
    required this.optimalMoves,
    this.isCompleted = false,
    this.stars,
    this.bestMoves,
    this.streak = 0,
  });

  // Create a copy with updated values
  DailyChallenge copyWith({
    DateTime? date,
    int? levelIndex,
    List<List<int?>>? gridData,
    int? gridSize,
    int? colorCount,
    int? optimalMoves,
    bool? isCompleted,
    int? stars,
    int? bestMoves,
    int? streak,
  }) {
    return DailyChallenge(
      date: date ?? this.date,
      levelIndex: levelIndex ?? this.levelIndex,
      gridData: gridData ?? this.gridData,
      gridSize: gridSize ?? this.gridSize,
      colorCount: colorCount ?? this.colorCount,
      optimalMoves: optimalMoves ?? this.optimalMoves,
      isCompleted: isCompleted ?? this.isCompleted,
      stars: stars ?? this.stars,
      bestMoves: bestMoves ?? this.bestMoves,
      streak: streak ?? this.streak,
    );
  }

  // Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Check if this is today's challenge
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Get streak emoji based on streak count
  String get streakEmoji {
    if (streak >= 7) return '🔥';
    if (streak >= 3) return '⚡';
    if (streak >= 1) return '✨';
    return '💫';
  }

  // Get streak text
  String get streakText {
    if (streak == 0) return 'Start your streak!';
    if (streak == 1) return '1 day streak!';
    if (streak < 7) return '$streak day streak!';
    if (streak < 30) return '$streak day streak! 🔥';
    if (streak < 100) return '$streak day streak! 🔥⚡';
    return '$streak day streak! 🔥⚡💎';
  }
}
