import 'package:isar/isar.dart';

part 'quantified_goal.g.dart';

// run the build with:
// `dart run build_runner build -d`

enum GoalValueType { integer, decimal }

@collection
class QuantifiedGoal {
  Id id = Isar.autoIncrement;

  late String title;
  late String unit; // e.g., "grams", "items", "oz"

  late double targetValue;
  double currentValue = 0;

  late DateTime deadline;
  bool isPinned = false;
  bool isCompleted = false;

  // Helper to get progress percentage
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  @enumerated
  late GoalValueType valueType;
}
