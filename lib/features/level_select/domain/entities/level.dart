class Level {
  final int id;
  final String name;
  final int gridSize;
  final int colors;
  final bool isCompleted;
  final bool isUnlocked;
  final int stars;
  final int? optimalMoves;
  final int? bestMoves;

  const Level({
    required this.id,
    required this.name,
    required this.gridSize,
    required this.colors,
    required this.isCompleted,
    required this.isUnlocked,
    required this.stars,
    this.optimalMoves,
    this.bestMoves,
  });

  // Create a copy with updated values
  Level copyWith({
    int? id,
    String? name,
    int? gridSize,
    int? colors,
    bool? isCompleted,
    bool? isUnlocked,
    int? stars,
    int? optimalMoves,
    int? bestMoves,
  }) {
    return Level(
      id: id ?? this.id,
      name: name ?? this.name,
      gridSize: gridSize ?? this.gridSize,
      colors: colors ?? this.colors,
      isCompleted: isCompleted ?? this.isCompleted,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      stars: stars ?? this.stars,
      optimalMoves: optimalMoves ?? this.optimalMoves,
      bestMoves: bestMoves ?? this.bestMoves,
    );
  }

  // Get star display text
  String get starText {
    if (stars == 0) return 'No stars';
    if (stars == 1) return '1 star';
    if (stars == 2) return '2 stars';
    return '3 stars';
  }

  // Get completion status text
  String get statusText {
    if (!isUnlocked) return 'Locked';
    if (isCompleted) {
      if (stars == 3) return 'Perfect!';
      if (stars == 2) return 'Great!';
      if (stars == 1) return 'Good!';
      return 'Completed';
    }
    return 'Not started';
  }
}
