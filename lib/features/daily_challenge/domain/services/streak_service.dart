import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StreakService {
  static const String _streakKey = 'daily_challenge_streak';
  static const String _lastPlayedKey = 'daily_challenge_last_played';
  static const String _completedDatesKey = 'daily_challenge_completed_dates';

  // Get current streak
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  // Get last played date
  static Future<DateTime?> getLastPlayedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastPlayedKey);
    if (dateString != null) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Get completed dates
  static Future<List<DateTime>> getCompletedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final datesString = prefs.getString(_completedDatesKey);
    if (datesString != null) {
      try {
        final datesList = jsonDecode(datesString) as List;
        return datesList.map((date) => DateTime.parse(date)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  // Update streak when daily challenge is completed
  static Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get last played date
    final lastPlayed = await getLastPlayedDate();
    final currentStreak = await getCurrentStreak();
    
    if (lastPlayed == null) {
      // First time playing
      await prefs.setInt(_streakKey, 1);
      await prefs.setString(_lastPlayedKey, today.toIso8601String());
    } else {
      final lastPlayedDay = DateTime(lastPlayed.year, lastPlayed.month, lastPlayed.day);
      final difference = today.difference(lastPlayedDay).inDays;
      
      if (difference == 1) {
        // Consecutive day - increment streak
        await prefs.setInt(_streakKey, currentStreak + 1);
        await prefs.setString(_lastPlayedKey, today.toIso8601String());
      } else if (difference == 0) {
        // Same day - no change to streak
        // Do nothing
      } else {
        // Gap in days - reset streak to 1
        await prefs.setInt(_streakKey, 1);
        await prefs.setString(_lastPlayedKey, today.toIso8601String());
      }
    }
    
    // Add today to completed dates
    await _addCompletedDate(today);
  }

  // Add a completed date
  static Future<void> _addCompletedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final completedDates = await getCompletedDates();
    
    // Check if date is already in the list
    final dateString = date.toIso8601String();
    final existingDate = completedDates.any((d) => d.toIso8601String() == dateString);
    
    if (!existingDate) {
      completedDates.add(date);
      final datesString = jsonEncode(completedDates.map((d) => d.toIso8601String()).toList());
      await prefs.setString(_completedDatesKey, datesString);
    }
  }

  // Check if today's challenge is already completed
  static Future<bool> isTodayCompleted() async {
    final completedDates = await getCompletedDates();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return completedDates.any((date) {
      final completedDay = DateTime(date.year, date.month, date.day);
      return completedDay.isAtSameMomentAs(today);
    });
  }

  // Get streak statistics
  static Future<Map<String, dynamic>> getStreakStats() async {
    final currentStreak = await getCurrentStreak();
    final completedDates = await getCompletedDates();
    final todayCompleted = await isTodayCompleted();
    
    // Calculate longest streak
    int longestStreak = 0;
    int currentRun = 0;
    DateTime? previousDate;
    
    // Sort dates and find longest consecutive run
    completedDates.sort();
    for (final date in completedDates) {
      if (previousDate == null) {
        currentRun = 1;
      } else {
        final difference = date.difference(previousDate).inDays;
        if (difference == 1) {
          currentRun++;
        } else {
          currentRun = 1;
        }
      }
      
      if (currentRun > longestStreak) {
        longestStreak = currentRun;
      }
      
      previousDate = date;
    }
    
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalCompleted': completedDates.length,
      'isTodayCompleted': todayCompleted,
    };
  }

  // Reset streak (for testing or user preference)
  static Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_streakKey);
    await prefs.remove(_lastPlayedKey);
    await prefs.remove(_completedDatesKey);
  }
}
