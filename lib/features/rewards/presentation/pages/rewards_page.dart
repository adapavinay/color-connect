import 'package:flutter/material.dart';
import 'package:color_connect/features/rewards/domain/entities/reward_item.dart';
import 'package:color_connect/features/rewards/domain/entities/reward_data.dart';
import 'package:color_connect/core/theme/app_theme.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<RewardItem> _allRewards = [];
  int _playerLevel = 5; // Mock player level
  int _playerStreak = 3; // Mock player streak

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadRewards();
  }

  void _loadRewards() {
    _allRewards = RewardData.getAllRewards();
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
        title: const Text('🎁 Rewards'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.all_inclusive)),
            Tab(text: 'Themes', icon: Icon(Icons.palette)),
            Tab(text: 'Colors', icon: Icon(Icons.color_lens)),
            Tab(text: 'Effects', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'Powerups', icon: Icon(Icons.flash_on)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRewardsList(_allRewards),
          _buildRewardsList(RewardData.getRewardsByType(RewardType.theme)),
          _buildRewardsList(RewardData.getRewardsByType(RewardType.color)),
          _buildRewardsList(RewardData.getRewardsByType(RewardType.effect)),
          _buildRewardsList(RewardData.getRewardsByType(RewardType.powerup)),
        ],
      ),
    );
  }

  Widget _buildRewardsList(List<RewardItem> rewards) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final isAvailable = _playerLevel >= reward.requiredLevel && 
                           _playerStreak >= reward.requiredStreak;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isAvailable ? 4 : 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: reward.rarityColor,
              child: Icon(
                _getRewardIcon(reward.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Expanded(child: Text(reward.name)),
                if (reward.isUnlocked)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: reward.rarityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: reward.rarityColor),
                      ),
                      child: Text(
                        reward.rarityText,
                        style: TextStyle(
                          color: reward.rarityColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryColor),
                      ),
                      child: Text(
                        reward.typeText,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.orange),
                    Text(' Level ${reward.requiredLevel}'),
                    const SizedBox(width: 16),
                    Icon(Icons.local_fire_department, size: 16, color: Colors.red),
                    Text(' Streak ${reward.requiredStreak}'),
                  ],
                ),
              ],
            ),
            trailing: isAvailable
                ? ElevatedButton(
                    onPressed: reward.isUnlocked ? null : () => _unlockReward(reward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: reward.isUnlocked ? Colors.grey : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(reward.isUnlocked ? 'Unlocked' : 'Unlock'),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.grey),
                      Text(
                        'Locked',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
            onTap: isAvailable && !reward.isUnlocked ? () => _unlockReward(reward) : null,
          ),
        );
      },
    );
  }

  IconData _getRewardIcon(RewardType type) {
    switch (type) {
      case RewardType.theme:
        return Icons.palette;
      case RewardType.color:
        return Icons.color_lens;
      case RewardType.effect:
        return Icons.auto_awesome;
      case RewardType.powerup:
        return Icons.flash_on;
      case RewardType.cosmetic:
        return Icons.face;
    }
    return Icons.star; // Default fallback
  }

  void _unlockReward(RewardItem reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 Unlock ${reward.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to unlock this reward?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: reward.rarityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: reward.rarityColor),
              ),
              child: Column(
                children: [
                  Icon(_getRewardIcon(reward.type), size: 48, color: reward.rarityColor),
                  const SizedBox(height: 8),
                  Text(
                    reward.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: reward.rarityColor,
                    ),
                  ),
                  Text(
                    reward.description,
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
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement actual unlocking logic
              setState(() {
                // For now, just mark as unlocked locally
                final index = _allRewards.indexWhere((r) => r.id == reward.id);
                if (index != -1) {
                  _allRewards[index] = reward.copyWith(
                    isUnlocked: true,
                    unlockedAt: DateTime.now(),
                  );
                }
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 ${reward.name} unlocked!'),
                  backgroundColor: reward.rarityColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: reward.rarityColor,
              foregroundColor: Colors.white,
            ),
            child: Text('Unlock'),
          ),
        ],
      ),
    );
  }
}
