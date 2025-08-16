import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HintsManager {
  static final HintsManager _instance = HintsManager._internal();
  factory HintsManager() => _instance;
  HintsManager._internal();

  static const String _hintsKey = 'hints_balance_v1';
  static const String _totalHintsUsedKey = 'total_hints_used_v1';
  static const String _totalHintsEarnedKey = 'total_hints_earned_v1';
  
  int _currentHints = 0;
  int _totalHintsUsed = 0;
  int _totalHintsEarned = 0;
  bool _initialized = false;
  
  int get currentHints => _currentHints;
  int get totalHintsUsed => _totalHintsUsed;
  int get totalHintsEarned => _totalHintsEarned;
  bool get initialized => _initialized;

  /// Initialize and load hint data from SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      await _loadHintsData();
      _initialized = true;
      debugPrint('HintsManager initialized. Current hints: $_currentHints');
    } catch (e) {
      debugPrint('Error initializing HintsManager: $e');
      // Default to 3 hints on error
      _currentHints = 3;
      _initialized = true;
    }
  }

  /// Load hint data from SharedPreferences
  Future<void> _loadHintsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentHints = prefs.getInt(_hintsKey) ?? 3; // Start with 3 hints
      _totalHintsUsed = prefs.getInt(_totalHintsUsedKey) ?? 0;
      _totalHintsEarned = prefs.getInt(_totalHintsEarnedKey) ?? 0;
    } catch (e) {
      debugPrint('Error loading hints data: $e');
      _currentHints = 3;
      _totalHintsUsed = 0;
      _totalHintsEarned = 0;
    }
  }

  /// Save hint data to SharedPreferences
  Future<void> _saveHintsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_hintsKey, _currentHints);
      await prefs.setInt(_totalHintsUsedKey, _totalHintsUsed);
      await prefs.setInt(_totalHintsEarnedKey, _totalHintsEarned);
    } catch (e) {
      debugPrint('Error saving hints data: $e');
    }
  }

  /// Add hints to the balance
  Future<void> add(int count) async {
    if (count <= 0) return;
    
    _currentHints += count;
    _totalHintsEarned += count;
    await _saveHintsData();
    
    debugPrint('Added $count hints. New balance: $_currentHints');
  }

  /// Use a hint if available
  /// Returns true if hint was used, false if no hints available
  Future<bool> use() async {
    if (_currentHints <= 0) {
      debugPrint('No hints available');
      return false;
    }
    
    _currentHints--;
    _totalHintsUsed++;
    await _saveHintsData();
    
    debugPrint('Used 1 hint. Remaining: $_currentHints');
    return true;
  }

  /// Check if hints are available without consuming
  bool get hasHints => _currentHints > 0;

  /// Get hint count for display
  int get hintCount => _currentHints;

  /// Reset hints to default (useful for testing or new game)
  Future<void> resetToDefault() async {
    _currentHints = 3;
    _totalHintsUsed = 0;
    _totalHintsEarned = 0;
    await _saveHintsData();
    debugPrint('Hints reset to default');
  }

  /// Set hint count to specific value (useful for testing)
  Future<void> setHints(int count) async {
    if (count < 0) count = 0;
    _currentHints = count;
    await _saveHintsData();
    debugPrint('Hints set to: $_currentHints');
  }

  /// Get statistics for analytics
  Map<String, dynamic> getStats() {
    return {
      'current_hints': _currentHints,
      'total_hints_used': _totalHintsUsed,
      'total_hints_earned': _totalHintsEarned,
      'hints_remaining': _currentHints,
    };
  }

  /// Check if user is low on hints (for prompting to buy more)
  bool get isLowOnHints => _currentHints <= 1;

  /// Check if user has no hints (for requiring purchase or ad)
  bool get hasNoHints => _currentHints <= 0;
}
