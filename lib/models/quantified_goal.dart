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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'deadline': deadline.toIso8601String(), // Store as String for consistency
      'isPinned': isPinned,
      'isCompleted': isCompleted,
      'valueType': valueType.index, // Store the enum index
    };
  }

  static QuantifiedGoal fromMap(Map<String, dynamic> map) {
    return QuantifiedGoal()
      ..id = map['id'] ?? 0
      ..title = map['title'] ?? ''
      ..targetValue = (map['targetValue'] as num).toDouble()
      ..currentValue = (map['currentValue'] as num).toDouble()
      ..unit = map['unit'] ?? ''
      ..deadline = DateTime.parse(map['deadline'])
      ..isPinned = map['isPinned'] ?? false
      ..isCompleted = map['isCompleted'] ?? false
      ..valueType = GoalValueType.values[map['valueType'] ?? 0];
  }
}
