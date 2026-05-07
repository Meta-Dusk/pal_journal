import 'package:flutter/material.dart';
import '../goal_progress_card.dart';
import '../subcomponents/increment_button.dart';

class IncrementButtons extends StatelessWidget {
  const IncrementButtons({
    super.key,
    required this.gpc,
    required this.onIncrement,
  });

  final GoalProgressCard gpc;
  final void Function(double) onIncrement;

  @override
  Widget build(BuildContext context) {
    final isDecimal = gpc.goal.valueType == .decimal;

    return Row(
      mainAxisAlignment: .spaceEvenly,
      children: [
        _buildIncrementBtn(isDecimal ? -1.0 : -10.0, isDecimal ? "-1" : "-10"),
        _buildIncrementBtn(isDecimal ? -0.1 : -1.0, isDecimal ? "-0.1" : "-1"),
        const SizedBox(width: 8),
        _buildIncrementBtn(isDecimal ? 0.1 : 1.0, isDecimal ? "+0.1" : "+1"),
        _buildIncrementBtn(isDecimal ? 1.0 : 10.0, isDecimal ? "+1" : "+10"),
      ],
    );
  }

  Widget _buildIncrementBtn(double amount, String label) =>
      IncrementButton(amount: amount, label: label, onIncrement: onIncrement);
}
