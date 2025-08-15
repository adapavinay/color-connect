import 'package:flutter/material.dart';

enum RewardType {
  theme,
  color,
  effect,
  powerup,
  cosmetic,
}

enum RewardRarity {
  common,
  rare,
  epic,
  legendary,
}

class RewardItem {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final RewardRarity rarity;
  final String? iconPath;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int requiredLevel;
  final int requiredStreak;

  const RewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    this.iconPath,
    this.isUnlocked = false,
    this.unlockedAt,
    this.requiredLevel = 1,
    this.requiredStreak = 0,
  });

  RewardItem copyWith({
    String? id,
    String? name,
    String? description,
    RewardType? type,
    RewardRarity? rarity,
    String? iconPath,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? requiredLevel,
    int? requiredStreak,
  }) {
    return RewardItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      iconPath: iconPath ?? this.iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      requiredStreak: requiredStreak ?? this.requiredStreak,
    );
  }

  String get rarityText {
    switch (rarity) {
      case RewardRarity.common:
        return 'Common';
      case RewardRarity.rare:
        return 'Rare';
      case RewardRarity.epic:
        return 'Epic';
      case RewardRarity.legendary:
        return 'Legendary';
    }
  }

  Color get rarityColor {
    switch (rarity) {
      case RewardRarity.common:
        return Colors.grey;
      case RewardRarity.rare:
        return Colors.blue;
      case RewardRarity.epic:
        return Colors.purple;
      case RewardRarity.legendary:
        return Colors.orange;
    }
  }

  String get typeText {
    switch (type) {
      case RewardType.theme:
        return 'Theme';
      case RewardType.color:
        return 'Color';
      case RewardType.effect:
        return 'Effect';
      case RewardType.powerup:
        return 'Powerup';
      case RewardType.cosmetic:
        return 'Cosmetic';
    }
  }
}
