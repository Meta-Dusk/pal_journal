import 'package:isar/isar.dart';

part 'monthly_goal.g.dart';

// run the build with:
// `dart run build_runner build -d`

enum GoalType { budget, profit }

@collection
class MonthlyGoal {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late DateTime month; // Normalized to the 1st of the month

  @enumerated
  late GoalType type;

  late double amount;

  double syncedOffset = 0.0;

  // --- SERIALIZATION FOR CLOUD & CSV ---
  Map<String, dynamic> toMap() {
    return {
      'month': month.toIso8601String(),
      'type': type.name,
      'amount': amount,
      'syncedOffset': syncedOffset,
    };
  }

  static MonthlyGoal fromMap(Map<String, dynamic> map) {
    return MonthlyGoal()
      ..month = DateTime.parse(map['month'] as String)
      ..type = GoalType.values.byName(map['type'] as String)
      ..amount = (map['amount'] as num).toDouble()
      ..syncedOffset = (map['syncedOffset'] as num).toDouble();
  }
}
