import 'package:shared_preferences/shared_preferences.dart';

enum GoalType { budget, profit }

class GoalData {
  final double amount;
  final GoalType type;
  final double syncedOffset;

  GoalData({required this.amount, required this.type, this.syncedOffset = 0.0});
}

class GoalService {
  // Bumped to v3 to handle the new 3-part data structure cleanly
  static String _getKey(DateTime month) =>
      'goal_v3_${month.year}_${month.month}';

  static Future<GoalData?> getGoal(DateTime month) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_getKey(month));

    if (dataStr == null) return null;

    final parts = dataStr.split('|');
    if (parts.length < 2) return null;

    return GoalData(
      type: parts[0] == 'profit' ? .profit : .budget,
      amount: double.tryParse(parts[1]) ?? 0.0,
      // Safely parse the 3rd part if it exists, otherwise default to 0.0
      syncedOffset: parts.length == 3
          ? (double.tryParse(parts[2]) ?? 0.0)
          : 0.0,
    );
  }

  // We add an optional syncedOffset parameter that defaults to 0.0
  static Future<void> setGoal(
    DateTime month,
    double amount,
    GoalType type, {
    double syncedOffset = 0.0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final typeStr = type == .profit ? 'profit' : 'budget';
    await prefs.setString(_getKey(month), '$typeStr|$amount|$syncedOffset');
  }

  static Future<void> clearGoal(DateTime month) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getKey(month));
  }
}
