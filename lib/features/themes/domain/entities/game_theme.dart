import 'package:flutter/material.dart';

enum ThemeCategory {
  classic,
  modern,
  retro,
  fantasy,
  sciFi,
  nature,
  abstract,
  seasonal,
}

class GameTheme {
  final String id;
  final String name;
  final String description;
  final ThemeCategory category;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color pathColor;
  final Color gridColor;
  final String? backgroundImagePath;
  final String? iconPath;
  final bool isUnlocked;
  final bool isPremium;
  final int requiredLevel;
  final double opacity;
  final bool hasParticles;
  final bool hasGlow;

  const GameTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.pathColor,
    required this.gridColor,
    this.backgroundImagePath,
    this.iconPath,
    this.isUnlocked = false,
    this.isPremium = false,
    this.requiredLevel = 1,
    this.opacity = 1.0,
    this.hasParticles = false,
    this.hasGlow = false,
  });

  GameTheme copyWith({
    String? id,
    String? name,
    String? description,
    ThemeCategory? category,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    Color? pathColor,
    Color? gridColor,
    String? backgroundImagePath,
    String? iconPath,
    bool? isUnlocked,
    bool? isPremium,
    int? requiredLevel,
    double? opacity,
    bool? hasParticles,
    bool? hasGlow,
  }) {
    return GameTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      pathColor: pathColor ?? this.pathColor,
      gridColor: gridColor ?? this.gridColor,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      iconPath: iconPath ?? this.iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isPremium: isPremium ?? this.isPremium,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      opacity: opacity ?? this.opacity,
      hasParticles: hasParticles ?? this.hasParticles,
      hasGlow: hasGlow ?? this.hasGlow,
    );
  }

  String get categoryText {
    switch (category) {
      case ThemeCategory.classic:
        return 'Classic';
      case ThemeCategory.modern:
        return 'Modern';
      case ThemeCategory.retro:
        return 'Retro';
      case ThemeCategory.fantasy:
        return 'Fantasy';
      case ThemeCategory.sciFi:
        return 'Sci-Fi';
      case ThemeCategory.nature:
        return 'Nature';
      case ThemeCategory.abstract:
        return 'Abstract';
      case ThemeCategory.seasonal:
        return 'Seasonal';
    }
  }

  ColorScheme get colorScheme {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: textColor,
      secondary: secondaryColor,
      onSecondary: textColor,
      tertiary: accentColor,
      onTertiary: textColor,
      error: Colors.red,
      onError: Colors.white,
      background: backgroundColor,
      onBackground: textColor,
      surface: surfaceColor,
      onSurface: textColor,
      outline: gridColor,
    );
  }

  bool get isDarkTheme {
    return backgroundColor.computeLuminance() < 0.5;
  }

  bool get isColorful {
    return primaryColor != secondaryColor && secondaryColor != accentColor;
  }
}
