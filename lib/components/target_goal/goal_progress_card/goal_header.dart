import 'package:flutter/material.dart';
import 'package:pal_journal/components/target_goal/goal_progress_card/goal_progress_card.dart';
import 'goal_edit_button.dart';
import 'goal_archive_button.dart';
import 'pin_goal_button.dart';

class GoalHeader extends StatelessWidget {
  final void Function(double) onUpdateValue;
  final GoalProgressCard gpc;

  const GoalHeader({super.key, required this.onUpdateValue, required this.gpc});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPinned = gpc.goal.isPinned;
    final isArchived = gpc.goal.isCompleted && !isPinned;
    final isFinishedButPinned = gpc.goal.isCompleted && isPinned;

    final mainContent = [
      Row(
        spacing: 8,
        children: [
          Text(gpc.goal.title, style: textTheme.titleMedium),
          if (gpc.goal.isCompleted)
            Icon(Icons.check_circle, color: colors.primary, size: 16),
        ],
      ),
      if (!gpc.goal.isCompleted)
        PinGoalButton(isPinned: isPinned, goalProgressCard: gpc),
      if (!isArchived && isFinishedButPinned) GoalArchiveButton(widget: gpc),
      if (!isArchived) GoalEditButton(gpc: gpc, onUpdateValue: onUpdateValue),
    ];

    return Row(mainAxisAlignment: .spaceBetween, children: mainContent);
  }
}
