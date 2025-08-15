import 'package:color_connect/features/rewards/domain/entities/reward_item.dart';

class RewardData {
  static List<RewardItem> getAllRewards() {
    return [
      // Theme rewards
      RewardItem(
        id: 'theme_dark',
        name: 'Dark Theme',
        description: 'Elegant dark color scheme',
        type: RewardType.theme,
        rarity: RewardRarity.common,
        requiredLevel: 1,
        requiredStreak: 0,
      ),
      RewardItem(
        id: 'theme_neon',
        name: 'Neon Theme',
        description: 'Bright neon colors',
        type: RewardType.theme,
        rarity: RewardRarity.rare,
        requiredLevel: 5,
        requiredStreak: 3,
      ),
      RewardItem(
        id: 'theme_golden',
        name: 'Golden Theme',
        description: 'Premium golden appearance',
        type: RewardType.theme,
        rarity: RewardRarity.epic,
        requiredLevel: 10,
        requiredStreak: 7,
      ),
      
      // Color rewards
      RewardItem(
        id: 'color_rainbow',
        name: 'Rainbow Colors',
        description: 'Vibrant rainbow color palette',
        type: RewardType.color,
        rarity: RewardRarity.rare,
        requiredLevel: 3,
        requiredStreak: 2,
      ),
      RewardItem(
        id: 'color_pastel',
        name: 'Pastel Colors',
        description: 'Soft pastel color scheme',
        type: RewardType.color,
        rarity: RewardRarity.common,
        requiredLevel: 2,
        requiredStreak: 1,
      ),
      
      // Effect rewards
      RewardItem(
        id: 'effect_particles',
        name: 'Particle Effects',
        description: 'Beautiful particle animations',
        type: RewardType.effect,
        rarity: RewardRarity.epic,
        requiredLevel: 8,
        requiredStreak: 5,
      ),
      RewardItem(
        id: 'effect_glow',
        name: 'Glow Effects',
        description: 'Glowing path effects',
        type: RewardType.effect,
        rarity: RewardRarity.rare,
        requiredLevel: 6,
        requiredStreak: 4,
      ),
      
      // Powerup rewards
      RewardItem(
        id: 'powerup_hint',
        name: 'Extra Hints',
        description: 'Get 3 extra hints per level',
        type: RewardType.powerup,
        rarity: RewardRarity.common,
        requiredLevel: 4,
        requiredStreak: 2,
      ),
      RewardItem(
        id: 'powerup_undo',
        name: 'Unlimited Undo',
        description: 'Unlimited undo moves',
        type: RewardType.powerup,
        rarity: RewardRarity.legendary,
        requiredLevel: 15,
        requiredStreak: 10,
      ),
      
      // Cosmetic rewards
      RewardItem(
        id: 'cosmetic_crown',
        name: 'Golden Crown',
        description: 'Wear a golden crown',
        type: RewardType.cosmetic,
        rarity: RewardRarity.legendary,
        requiredLevel: 20,
        requiredStreak: 15,
      ),
    ];
  }

  static List<RewardItem> getRewardsByType(RewardType type) {
    return getAllRewards().where((reward) => reward.type == type).toList();
  }

  static List<RewardItem> getRewardsByRarity(RewardRarity rarity) {
    return getAllRewards().where((reward) => reward.rarity == rarity).toList();
  }

  static List<RewardItem> getUnlockedRewards(List<RewardItem> rewards) {
    return rewards.where((reward) => reward.isUnlocked).toList();
  }

  static List<RewardItem> getAvailableRewards(int playerLevel, int playerStreak) {
    return getAllRewards().where((reward) => 
      reward.requiredLevel <= playerLevel && reward.requiredStreak <= playerStreak
    ).toList();
  }
}
