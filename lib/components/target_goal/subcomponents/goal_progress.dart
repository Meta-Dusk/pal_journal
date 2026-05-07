import 'package:flutter/material.dart';
import 'package:pal_journal/components/target_goal/goal_progress_card.dart';

class GoalProgress extends StatelessWidget {
  const GoalProgress({super.key, required this.gpc});

  final GoalProgressCard gpc;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDecimal = gpc.goal.valueType == .decimal;

    final mainContent = [
      Expanded(
        child: LinearProgressIndicator(
          value: gpc.goal.progress,
          minHeight: 8,
          borderRadius: .circular(16),
          backgroundColor: colors.surfaceContainerHighest,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        "${gpc.goal.currentValue.toStringAsFixed(isDecimal ? 1 : 0)} / "
        "${gpc.goal.targetValue.toStringAsFixed(isDecimal ? 1 : 0)} "
        "${gpc.goal.unit}",
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 12,
          fontWeight: .bold,
        ),
      ),
    ];
    return Row(children: mainContent);
  }
}
