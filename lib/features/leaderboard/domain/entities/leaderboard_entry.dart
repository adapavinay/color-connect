class LeaderboardEntry {
  final String playerId;
  final String playerName;
  final int score;
  final int level;
  final int stars;
  final int moves;
  final DateTime date;
  final String? avatarPath;
  final int rank;

  const LeaderboardEntry({
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.level,
    required this.stars,
    required this.moves,
    required this.date,
    this.avatarPath,
    this.rank = 0,
  });

  LeaderboardEntry copyWith({
    String? playerId,
    String? playerName,
    int? score,
    int? level,
    int? stars,
    int? moves,
    DateTime? date,
    String? avatarPath,
    int? rank,
  }) {
    return LeaderboardEntry(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      score: score ?? this.score,
      level: level ?? this.level,
      stars: stars ?? this.stars,
      moves: moves ?? this.moves,
      date: date ?? this.date,
      avatarPath: avatarPath ?? this.avatarPath,
      rank: rank ?? this.rank,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  String get rankText {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  String get scoreText {
    if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}
