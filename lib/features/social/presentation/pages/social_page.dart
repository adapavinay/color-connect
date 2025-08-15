import 'package:flutter/material.dart';
import 'package:color_connect/features/social/domain/entities/achievement.dart';
import 'package:color_connect/core/theme/app_theme.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  List<Achievement> _achievements = [];
  List<Achievement> _recentUnlocks = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  void _loadAchievements() {
    // Mock achievements data
    _achievements = [
      Achievement(
        id: 'level_master',
        name: 'Level Master',
        description: 'Complete 10 levels',
        type: AchievementType.level,
        tier: AchievementTier.bronze,
        requiredValue: 10,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      Achievement(
        id: 'streak_champion',
        name: 'Streak Champion',
        description: 'Maintain a 7-day streak',
        type: AchievementType.streak,
        tier: AchievementTier.silver,
        requiredValue: 7,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      Achievement(
        id: 'perfect_solver',
        name: 'Perfect Solver',
        description: 'Get 3 stars on 5 levels',
        type: AchievementType.efficiency,
        tier: AchievementTier.gold,
        requiredValue: 5,
        isUnlocked: false,
      ),
      Achievement(
        id: 'speed_demon',
        name: 'Speed Demon',
        description: 'Complete a level in under 30 seconds',
        type: AchievementType.speed,
        tier: AchievementTier.epic,
        requiredValue: 30,
        isUnlocked: false,
      ),
      Achievement(
        id: 'puzzle_legend',
        name: 'Puzzle Legend',
        description: 'Complete all levels with perfect scores',
        type: AchievementType.special,
        tier: AchievementTier.diamond,
        requiredValue: 1,
        isUnlocked: false,
      ),
    ];

    _recentUnlocks = _achievements.where((a) => a.isUnlocked).toList();
    _recentUnlocks.sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏅 Achievements'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProfile,
            tooltip: 'Share Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile summary
            _buildProfileSummary(),
            const SizedBox(height: 24),
            
            // Recent unlocks
            if (_recentUnlocks.isNotEmpty) ...[
              Text(
                '🎉 Recent Unlocks',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecentUnlocks(),
              const SizedBox(height: 24),
            ],
            
            // All achievements
            Text(
              '🏆 All Achievements',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildAchievementsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSummary() {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;
    final completionPercentage = (unlockedCount / totalCount * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievement Progress',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$unlockedCount / $totalCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: unlockedCount / totalCount,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Center(
                      child: Text(
                        '$completionPercentage%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Bronze', _getTierCount(AchievementTier.bronze), Colors.orange),
              _buildStatItem('Silver', _getTierCount(AchievementTier.silver), Colors.grey),
              _buildStatItem('Gold', _getTierCount(AchievementTier.gold), Colors.yellow),
              _buildStatItem('Epic', _getTierCount(AchievementTier.epic), Colors.purple),
              _buildStatItem('Diamond', _getTierCount(AchievementTier.diamond), Colors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String tier, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tier,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  int _getTierCount(AchievementTier tier) {
    return _achievements.where((a) => a.tier == tier && a.isUnlocked).length;
  }

  Widget _buildRecentUnlocks() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentUnlocks.length,
        itemBuilder: (context, index) {
          final achievement = _recentUnlocks[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: achievement.tierColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            achievement.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: achievement.tierColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: achievement.tierColor),
                          ),
                          child: Text(
                            achievement.tierText,
                            style: TextStyle(
                              color: achievement.tierColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${achievement.unlockedAt!.day}/${achievement.unlockedAt!.month}',
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Card(
      elevation: achievement.isUnlocked ? 4 : 1,
      child: InkWell(
        onTap: () => _showAchievementDetails(achievement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Achievement icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked 
                      ? achievement.tierColor 
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: achievement.isUnlocked ? [
                    BoxShadow(
                      color: achievement.tierColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Icon(
                  achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
                  color: achievement.isUnlocked ? Colors.white : Colors.grey[600],
                  size: 30,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Achievement name
              Text(
                achievement.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: achievement.isUnlocked ? Colors.black : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Achievement description
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 12,
                  color: achievement.isUnlocked ? Colors.grey[600] : Colors.grey[400],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Tier badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: achievement.tierColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: achievement.tierColor),
                ),
                child: Text(
                  achievement.tierText,
                  style: TextStyle(
                    color: achievement.tierColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              if (!achievement.isUnlocked) ...[
                const SizedBox(height: 8),
                Text(
                  '${achievement.requiredValue} ${achievement.typeText}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
              color: achievement.tierColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(achievement.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // Progress info
            if (!achievement.isUnlocked) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Text(
                      'Progress Required',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete ${achievement.requiredValue} ${achievement.typeText.toLowerCase()}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎉 Achievement Unlocked!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlocked on ${achievement.unlockedAt!.day}/${achievement.unlockedAt!.month}/${achievement.unlockedAt!.year}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Share message
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
                    'Share Message',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.defaultShareMessage,
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
          if (achievement.isUnlocked)
            ElevatedButton.icon(
              onPressed: () => _shareAchievement(achievement),
              icon: Icon(Icons.share),
              label: Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _shareAchievement(Achievement achievement) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📤 Sharing ${achievement.name} achievement!'),
        backgroundColor: achievement.tierColor,
      ),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📤 Sharing your achievement profile!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
