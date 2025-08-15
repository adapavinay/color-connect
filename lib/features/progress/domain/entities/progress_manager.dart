import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:color_connect/features/game/domain/entities/level_data.dart';

class ProgressManager {
  static const String _progressKey = 'player_progress';
  static const String _starsKey = 'total_stars';
  static const String _completedLevelsKey = 'completed_levels';
  static const String _levelScoresKey = 'level_scores';
  
  // Singleton pattern
  static final ProgressManager _instance = ProgressManager._internal();
  factory ProgressManager() => _instance;
  ProgressManager._internal();

  // Player progress data
  int _totalStars = 0;
  Set<int> _completedLevels = {};
  Map<int, int> _levelScores = {}; // levelId -> stars earned

  // Getters
  int get totalStars => _totalStars;
  Set<int> get completedLevels => _completedLevels;
  int get completedLevelsCount => _completedLevels.length;

  // Initialize progress manager
  Future<void> initialize() async {
    await _loadProgress();
  }

  // Load progress from local storage
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _totalStars = prefs.getInt(_starsKey) ?? 0;
      
      final completedLevelsString = prefs.getString(_completedLevelsKey) ?? '[]';
      final completedLevelsList = jsonDecode(completedLevelsString) as List;
      _completedLevels = completedLevelsList.map((e) => e as int).toSet();
      
      final levelScoresString = prefs.getString(_levelScoresKey) ?? '{}';
      final levelScoresMap = jsonDecode(levelScoresString) as Map<String, dynamic>;
      _levelScores = levelScoresMap.map((key, value) => MapEntry(int.parse(key), value as int));
    } catch (e) {
      // Reset progress if there's an error
      _totalStars = 0;
      _completedLevels = {};
      _levelScores = {};
    }
  }

  // Save progress to local storage
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt(_starsKey, _totalStars);
      
      final completedLevelsList = _completedLevels.toList();
      await prefs.setString(_completedLevelsKey, jsonEncode(completedLevelsList));
      
      final levelScoresMap = _levelScores.map((key, value) => MapEntry(key.toString(), value));
      await prefs.setString(_levelScoresKey, jsonEncode(levelScoresMap));
    } catch (e) {
      // Handle save error
      print('Error saving progress: $e');
    }
  }

  // Complete a level and earn stars
  Future<void> completeLevel(int levelId, int starsEarned) async {
    if (starsEarned < 0 || starsEarned > 3) {
      throw ArgumentError('Stars must be between 0 and 3');
    }

    final previousStars = _levelScores[levelId] ?? 0;
    final starsDifference = starsEarned - previousStars;

    if (starsDifference > 0) {
      _totalStars += starsDifference;
    }

    _completedLevels.add(levelId);
    _levelScores[levelId] = starsEarned;

    // Save progress immediately
    await _saveProgress();
    
    // Debug information
    print('🎯 Progress updated: Level $levelId completed with $starsEarned stars');
    print('🎯 Total stars: $_totalStars');
    print('🎯 Completed levels: ${_completedLevels.length}');
  }

  // Get stars earned for a specific level
  int getLevelStars(int levelId) {
    return _levelScores[levelId] ?? 0;
  }

  // Check if a level is completed
  bool isLevelCompleted(int levelId) {
    return _completedLevels.contains(levelId);
  }

  // Get completion percentage
  double getCompletionPercentage() {
    if (LevelData.totalLevels == 0) return 0.0;
    return (_completedLevels.length / LevelData.totalLevels) * 100;
  }

  // Get stars needed for next pack
  int getStarsForNextPack(int currentPack) {
    return LevelData.getStarsForNextPack(currentPack, _totalStars);
  }

  // Check if a pack is unlocked
  bool isPackUnlocked(int packNumber) {
    return LevelData.isPackUnlocked(packNumber, _totalStars);
  }

  // Get current pack based on progress
  int getCurrentPack() {
    for (int pack = LevelData.packsCount; pack >= 1; pack--) {
      if (isPackUnlocked(pack)) {
        return pack;
      }
    }
    return 1;
  }

  // Get next unlockable pack
  int getNextUnlockablePack() {
    final currentPack = getCurrentPack();
    if (currentPack >= LevelData.packsCount) return currentPack;
    
    for (int pack = currentPack + 1; pack <= LevelData.packsCount; pack++) {
      if (!isPackUnlocked(pack)) {
        return pack;
      }
    }
    return currentPack;
  }

  // Get progress summary
  Map<String, dynamic> getProgressSummary() {
    return {
      'totalStars': _totalStars,
      'completedLevels': _completedLevels.length,
      'totalLevels': LevelData.totalLevels,
      'completionPercentage': getCompletionPercentage(),
      'currentPack': getCurrentPack(),
      'nextPack': getNextUnlockablePack(),
      'starsForNextPack': getStarsForNextPack(getCurrentPack()),
    };
  }

  // Reset all progress (for testing or new game)
  Future<void> resetProgress() async {
    _totalStars = 0;
    _completedLevels = {};
    _levelScores = {};
    await _saveProgress();
  }

  // Add bonus stars (from purchases or rewards)
  Future<void> addBonusStars(int stars) async {
    if (stars > 0) {
      _totalStars += stars;
      await _saveProgress();
    }
  }

  // Get pack progress
  Map<String, dynamic> getPackProgress(int packNumber) {
    final levelsInPack = LevelData.getLevelsInPack(packNumber);
    int packStars = 0;
    int completedInPack = 0;
    
    for (final levelId in levelsInPack) {
      if (_completedLevels.contains(levelId)) {
        completedInPack++;
        packStars += _levelScores[levelId] ?? 0;
      }
    }
    
    return {
      'packNumber': packNumber,
      'packName': LevelData.getPackName(packNumber),
      'totalLevels': levelsInPack.length,
      'completedLevels': completedInPack,
      'totalStars': packStars,
      'maxPossibleStars': levelsInPack.length * 3,
      'isUnlocked': isPackUnlocked(packNumber),
      'unlockRequirement': LevelData.packUnlockRequirements[packNumber] ?? 0,
    };
  }

  // Get all packs progress
  List<Map<String, dynamic>> getAllPacksProgress() {
    final List<Map<String, dynamic>> packsProgress = [];
    
    for (int pack = 1; pack <= LevelData.packsCount; pack++) {
      packsProgress.add(getPackProgress(pack));
    }
    
    return packsProgress;
  }

  // Find the next unsolved level after a given levelId; wraps around once.
  int? getNextUnsolvedLevel(int afterLevelId) {
    final total = LevelData.totalLevels;
    int id = afterLevelId % total + 1; // start after
    for (int i = 0; i < total; i++) {
      if (!isLevelCompleted(id)) return id;
      id = id % total + 1;
    }
    return null; // all solved
  }
}
