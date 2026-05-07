import 'package:flutter/material.dart';
import 'package:pal_journal/components/target_goal/goal_progress_card.dart';
import 'package:pal_journal/services/isar_service.dart';

class PinGoalButton extends StatelessWidget {
  const PinGoalButton({
    super.key,
    required this.isPinned,
    required this.goalProgressCard,
  });

  final bool isPinned;
  final GoalProgressCard goalProgressCard;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final widget = goalProgressCard;
    return IconButton(
      icon: Icon(
        isPinned ? Icons.undo : Icons.push_pin,
        size: 16,
        color: colors.tertiary,
      ),
      onPressed: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (_) =>
              _ConfirmationDialog(isPinned: isPinned, widget: widget),
        );
        if (result != true) return;
        widget.goal.isPinned = !widget.goal.isPinned;
        await IsarService().saveQuantifiedGoal(widget.goal);
        widget.onUpdate();
      },
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({required this.isPinned, required this.widget});

  final bool isPinned;
  final GoalProgressCard widget;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Target Goal"),
      content: Text(
        isPinned
            ? "Unpin '${widget.goal.title}' from the Home View?"
            : "Pin '${widget.goal.title}' to the Home View?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Cancel"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Confirm"),
        ),
      ],
    );
  }
}
