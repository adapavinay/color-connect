import 'package:flutter/material.dart';
import 'package:color_connect/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:color_connect/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:color_connect/core/theme/app_theme.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<LeaderboardEntry> _globalLeaderboard = [];
  List<LeaderboardEntry> _weeklyLeaderboard = [];
  List<LeaderboardEntry> _monthlyLeaderboard = [];
  LeaderboardEntry? _playerRank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboards();
  }

  void _loadLeaderboards() {
    _globalLeaderboard = LeaderboardData.getMockLeaderboard();
    _weeklyLeaderboard = LeaderboardData.getWeeklyLeaderboard();
    _monthlyLeaderboard = LeaderboardData.getMonthlyLeaderboard();
    
    // Mock player rank (you would get this from actual player data)
    _playerRank = LeaderboardData.getPlayerRank('player_001');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Leaderboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global', icon: Icon(Icons.public)),
            Tab(text: 'Weekly', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Monthly', icon: Icon(Icons.calendar_month)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Player's current rank
          if (_playerRank != null) _buildPlayerRankCard(),
          
          // Leaderboard tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardList(_globalLeaderboard),
                _buildLeaderboardList(_weeklyLeaderboard),
                _buildLeaderboardList(_monthlyLeaderboard),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRankCard() {
    final player = _playerRank!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                player.rankText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rank',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  player.playerName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Score: ${player.scoreText} • Level ${player.level} • ${player.stars} ⭐',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '#${player.rank}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Global',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> leaderboard) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        final isTopThree = entry.rank <= 3;
        final isPlayer = _playerRank?.playerId == entry.playerId;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isTopThree ? 6 : 2,
          color: isPlayer ? AppTheme.primaryColor.withOpacity(0.1) : null,
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getRankColor(entry.rank),
                borderRadius: BorderRadius.circular(25),
                boxShadow: isTopThree ? [
                  BoxShadow(
                    color: _getRankColor(entry.rank).withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Center(
                child: Text(
                  entry.rankText,
                  style: TextStyle(
                    fontSize: isTopThree ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.playerName,
                    style: TextStyle(
                      fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
                      color: isPlayer ? AppTheme.primaryColor : null,
                    ),
                  ),
                ),
                if (isPlayer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'YOU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.orange),
                    Text(' ${entry.stars} stars'),
                    const SizedBox(width: 16),
                    Icon(Icons.games, size: 16, color: Colors.blue),
                    Text(' Level ${entry.level}'),
                    const SizedBox(width: 16),
                    Icon(Icons.touch_app, size: 16, color: Colors.green),
                    Text(' ${entry.moves} moves'),
                  ],
                ),
                Text(
                  entry.formattedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.scoreText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getRankColor(entry.rank),
                  ),
                ),
                Text(
                  'Score',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            onTap: () => _showPlayerDetails(entry),
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.primaryColor;
    }
  }

  void _showPlayerDetails(LeaderboardEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(entry.playerName),
            const SizedBox(width: 8),
            Text(entry.rankText, style: TextStyle(fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Rank', '#${entry.rank}'),
            _buildDetailRow('Score', entry.scoreText),
            _buildDetailRow('Level', '${entry.level}'),
            _buildDetailRow('Stars', '${entry.stars} ⭐'),
            _buildDetailRow('Moves', '${entry.moves}'),
            _buildDetailRow('Date', entry.formattedDate),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Performance Analysis',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This player achieved a high score through efficient puzzle solving and strategic thinking!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement challenge player functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎯 Challenge sent to ${entry.playerName}!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Challenge'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
