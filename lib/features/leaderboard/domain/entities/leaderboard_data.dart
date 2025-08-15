import 'package:color_connect/features/leaderboard/domain/entities/leaderboard_entry.dart';

class LeaderboardData {
  static List<LeaderboardEntry> getMockLeaderboard() {
    final now = DateTime.now();
    return [
      LeaderboardEntry(
        playerId: 'player_001',
        playerName: 'PuzzleMaster',
        score: 2850,
        level: 10,
        stars: 30,
        moves: 45,
        date: now.subtract(const Duration(hours: 2)),
        rank: 1,
      ),
      LeaderboardEntry(
        playerId: 'player_002',
        playerName: 'ColorWizard',
        score: 2720,
        level: 9,
        stars: 27,
        moves: 52,
        date: now.subtract(const Duration(hours: 4)),
        rank: 2,
      ),
      LeaderboardEntry(
        playerId: 'player_003',
        playerName: 'BrainTeaser',
        score: 2580,
        level: 8,
        stars: 24,
        moves: 48,
        date: now.subtract(const Duration(hours: 6)),
        rank: 3,
      ),
      LeaderboardEntry(
        playerId: 'player_004',
        playerName: 'LogicKing',
        score: 2450,
        level: 8,
        stars: 24,
        moves: 55,
        date: now.subtract(const Duration(hours: 8)),
        rank: 4,
      ),
      LeaderboardEntry(
        playerId: 'player_005',
        playerName: 'MindBender',
        score: 2320,
        level: 7,
        stars: 21,
        moves: 58,
        date: now.subtract(const Duration(hours: 10)),
        rank: 5,
      ),
      LeaderboardEntry(
        playerId: 'player_006',
        playerName: 'StrategyPro',
        score: 2180,
        level: 7,
        stars: 21,
        moves: 62,
        date: now.subtract(const Duration(hours: 12)),
        rank: 6,
      ),
      LeaderboardEntry(
        playerId: 'player_007',
        playerName: 'QuickThinker',
        score: 2050,
        level: 6,
        stars: 18,
        moves: 65,
        date: now.subtract(const Duration(hours: 14)),
        rank: 7,
      ),
      LeaderboardEntry(
        playerId: 'player_008',
        playerName: 'PatternSeeker',
        score: 1920,
        level: 6,
        stars: 18,
        moves: 68,
        date: now.subtract(const Duration(hours: 16)),
        rank: 8,
      ),
      LeaderboardEntry(
        playerId: 'player_009',
        playerName: 'GridMaster',
        score: 1780,
        level: 5,
        stars: 15,
        moves: 72,
        date: now.subtract(const Duration(hours: 18)),
        rank: 9,
      ),
      LeaderboardEntry(
        playerId: 'player_010',
        playerName: 'ConnectPro',
        score: 1650,
        level: 5,
        stars: 15,
        moves: 75,
        date: now.subtract(const Duration(hours: 20)),
        rank: 10,
      ),
    ];
  }

  static List<LeaderboardEntry> getWeeklyLeaderboard() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return getMockLeaderboard().where((entry) => 
      entry.date.isAfter(weekAgo)
    ).toList();
  }

  static List<LeaderboardEntry> getMonthlyLeaderboard() {
    final now = DateTime.now();
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    
    return getMockLeaderboard().where((entry) => 
      entry.date.isAfter(monthAgo)
    ).toList();
  }

  static LeaderboardEntry? getPlayerRank(String playerId) {
    try {
      return getMockLeaderboard().firstWhere((entry) => entry.playerId == playerId);
    } catch (e) {
      return null;
    }
  }

  static int calculateScore(int level, int stars, int moves, int optimalMoves) {
    // Base score: level * 100
    int baseScore = level * 100;
    
    // Star bonus: stars * 50
    int starBonus = stars * 50;
    
    // Move efficiency bonus: (optimalMoves / moves) * 200
    double moveEfficiency = optimalMoves / moves;
    int efficiencyBonus = (moveEfficiency * 200).round();
    
    // Time bonus: based on completion speed (simplified)
    int timeBonus = 100;
    
    return baseScore + starBonus + efficiencyBonus + timeBonus;
  }
}
