import 'package:shared_preferences/shared_preferences.dart';

enum GoalType { budget, profit }

class GoalData {
  final double amount;
  final GoalType type;
  GoalData({required this.amount, required this.type});
}

class GoalService {
  // We use a new key format to avoid crashing if it finds the old basic double
  static String _getKey(DateTime month) =>
      'goal_v2_${month.year}_${month.month}';

  static Future<GoalData?> getGoal(DateTime month) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_getKey(month));

    if (dataStr == null) return null;

    final parts = dataStr.split('|');
    if (parts.length != 2) return null;

    return GoalData(
      amount: double.tryParse(parts[1]) ?? 0.0,
      type: parts[0] == 'profit' ? .profit : .budget,
    );
  }

  static Future<void> setGoal(
    DateTime month,
    double amount,
    GoalType type,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final typeStr = type == .profit ? 'profit' : 'budget';
    await prefs.setString(_getKey(month), '$typeStr|$amount');
  }

  static Future<void> clearGoal(DateTime month) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getKey(month));
  }
}
