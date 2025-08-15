import 'package:flutter/material.dart';

enum AchievementType {
  level,
  streak,
  score,
  efficiency,
  speed,
  special,
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  epic,
  platinum,
  diamond,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final AchievementTier tier;
  final String? iconPath;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int requiredValue;
  final String? shareMessage;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tier,
    this.iconPath,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.requiredValue,
    this.shareMessage,
  });

  Color get tierColor {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.epic:
        return const Color(0xFF9932CC);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFF808080);
    }
    return const Color(0xFF808080); // Default fallback
  }

  static Color _getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.epic:
        return const Color(0xFF9932CC);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
    return const Color(0xFF808080); // Default fallback
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    AchievementType? type,
    AchievementTier? tier,
    String? iconPath,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? requiredValue,
    String? shareMessage,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      tier: tier ?? this.tier,
      iconPath: iconPath ?? this.iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      requiredValue: requiredValue ?? this.requiredValue,
      shareMessage: shareMessage ?? this.shareMessage,
    );
  }

  String get tierText {
    switch (tier) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.epic:
        return 'Epic';
      case AchievementTier.platinum:
        return 'Platinum';
      case AchievementTier.diamond:
        return 'Diamond';
    }
    return 'Unknown'; // Default fallback
  }

  String get typeText {
    switch (type) {
      case AchievementType.level:
        return 'Level';
      case AchievementType.streak:
        return 'Streak';
      case AchievementType.score:
        return 'Score';
      case AchievementType.efficiency:
        return 'Efficiency';
      case AchievementType.speed:
        return 'Speed';
      case AchievementType.special:
        return 'Special';
    }
    return 'Unknown'; // Default fallback
  }

  String get defaultShareMessage {
    return shareMessage ?? 'I just unlocked the $tierText $name achievement in Color Connect! 🎉';
  }

  bool checkUnlock(int currentValue) {
    if (isUnlocked) return false;
    return currentValue >= requiredValue;
  }
}
