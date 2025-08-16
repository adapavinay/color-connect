/// Feature flags for controlling puzzle generation behavior.
/// These can be toggled at runtime or overridden via remote config.
class FeatureFlags {
  /// Whether to use the new V2 generator (Spanning-Tree Pair Routing).
  /// Default: true (recommended for production)
  static const bool useNewGenerator = true;

  /// Whether to require full coverage (all cells filled by solution).
  /// Default: false (relaxed for better success rate)
  static const bool requireFullCoverage = false;

  /// Maximum retries for V2 generator before falling back to legacy.
  /// Default: 200 (increased for better success rate)
  static const int maxRetries = 200;

  /// Minimum Manhattan distance between endpoints of the same color.
  /// Higher values = longer paths = generally harder puzzles.
  /// Default: 4 (good for larger grids, adaptive for small ones)
  static const int minPairDistance = 4;

  /// Whether to emit verbose generation logs.
  /// Default: false (set to true for debugging)
  static const bool verboseLogs = true;
}

class MonetizationFlags {
  static const bool adsEnabled = true;
  static const int interstitialEveryNLevels = 5;
  static const bool rewardedForHints = true;
}

class ProductIds {
  static const String removeAds = 'remove_ads';
  static const String hints5 = 'hints_5';
  static const String hints10 = 'hints_10';
  static const String hints20 = 'hints_20';
}
