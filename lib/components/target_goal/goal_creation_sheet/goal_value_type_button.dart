import 'package:flutter/material.dart';
import 'package:pal_journal/models/quantified_goal.dart';

class GoalValueTypeButton extends StatelessWidget {
  const GoalValueTypeButton({
    super.key,
    required this.onSelected,
    required this.onSelectionChanged,
  });

  final Set<GoalValueType> onSelected;
  final void Function(Set<GoalValueType>) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<GoalValueType>(
        segments: const [
          ButtonSegment(
            value: .integer,
            label: Text("Integer (1, 2, 3)"),
            icon: Icon(Icons.pin_outlined),
          ),
          ButtonSegment(
            value: .decimal,
            label: Text("Decimal (1.5, 2.0)"),
            icon: Icon(Icons.precision_manufacturing_outlined),
          ),
        ],
        selected: onSelected,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}
