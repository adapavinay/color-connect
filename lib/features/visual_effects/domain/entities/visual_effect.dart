import 'package:flutter/material.dart';

enum EffectType {
  particle,
  glow,
  ripple,
  sparkle,
  trail,
  explosion,
  fade,
  slide,
  bounce,
  pulse,
}

enum EffectTrigger {
  onPathStart,
  onPathComplete,
  onLevelComplete,
  onStarEarned,
  onAchievement,
  onReward,
  onError,
  onSuccess,
}

class VisualEffect {
  final String id;
  final String name;
  final EffectType type;
  final EffectTrigger trigger;
  final Duration duration;
  final Curve curve;
  final Map<String, dynamic> properties;
  final bool isEnabled;
  final int priority;

  const VisualEffect({
    required this.id,
    required this.name,
    required this.type,
    required this.trigger,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.properties = const {},
    this.isEnabled = true,
    this.priority = 1,
  });

  VisualEffect copyWith({
    String? id,
    String? name,
    EffectType? type,
    EffectTrigger? trigger,
    Duration? duration,
    Curve? curve,
    Map<String, dynamic>? properties,
    bool? isEnabled,
    int? priority,
  }) {
    return VisualEffect(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      trigger: trigger ?? this.trigger,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      properties: properties ?? this.properties,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
    );
  }

  String get typeText {
    switch (type) {
      case EffectType.particle:
        return 'Particle';
      case EffectType.glow:
        return 'Glow';
      case EffectType.ripple:
        return 'Ripple';
      case EffectType.sparkle:
        return 'Sparkle';
      case EffectType.trail:
        return 'Trail';
      case EffectType.explosion:
        return 'Explosion';
      case EffectType.fade:
        return 'Fade';
      case EffectType.slide:
        return 'Slide';
      case EffectType.bounce:
        return 'Bounce';
      case EffectType.pulse:
        return 'Pulse';
    }
  }

  String get triggerText {
    switch (trigger) {
      case EffectTrigger.onPathStart:
        return 'Path Start';
      case EffectTrigger.onPathComplete:
        return 'Path Complete';
      case EffectTrigger.onLevelComplete:
        return 'Level Complete';
      case EffectTrigger.onStarEarned:
        return 'Star Earned';
      case EffectTrigger.onAchievement:
        return 'Achievement';
      case EffectTrigger.onReward:
        return 'Reward';
      case EffectTrigger.onError:
        return 'Error';
      case EffectTrigger.onSuccess:
        return 'Success';
    }
  }

  bool get isParticleEffect => type == EffectType.particle;
  bool get isGlowEffect => type == EffectType.glow;
  bool get isAnimationEffect => type == EffectType.fade || type == EffectType.slide || type == EffectType.bounce || type == EffectType.pulse;
}
