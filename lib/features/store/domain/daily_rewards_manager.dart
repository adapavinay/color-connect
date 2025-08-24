import 'package:shared_preferences/shared_preferences.dart';

/// Tracks how many rewarded-star grants happened today.
class DailyRewardsManager {
  static const _kCountKey = 'daily_star_reward_count';
  static const _kDateKey = 'daily_star_reward_date';

  /// Returns remaining grants for today.
  static Future<int> remainingToday(int dailyCap) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastDate = prefs.getString(_kDateKey);
    int count = prefs.getInt(_kCountKey) ?? 0;
    if (lastDate != todayStr) {
      // New day → reset
      await prefs.setString(_kDateKey, todayStr);
      await prefs.setInt(_kCountKey, 0);
      return dailyCap;
    }
    return (dailyCap - count).clamp(0, dailyCap);
  }

  static Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final lastDate = prefs.getString(_kDateKey);
    int count = prefs.getInt(_kCountKey) ?? 0;
    if (lastDate != todayStr) {
      await prefs.setString(_kDateKey, todayStr);
      count = 0;
    }
    await prefs.setInt(_kCountKey, count + 1);
  }
}
