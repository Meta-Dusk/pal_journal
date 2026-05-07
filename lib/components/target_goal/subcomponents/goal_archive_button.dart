import 'package:flutter/material.dart';
import 'package:pal_journal/components/target_goal/goal_progress_card.dart';
import 'package:pal_journal/services/isar_service.dart';

class GoalArchiveButton extends StatelessWidget {
  const GoalArchiveButton({super.key, required this.widget});

  final GoalProgressCard widget;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: () => _showArchiveConfirmation(context),
      icon: Icon(Icons.archive_outlined, color: colors.tertiary),
      tooltip: "Archive Goal",
    );
  }

  void _showArchiveConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(widget: widget),
    );

    if (result != true || !context.mounted) return;
    widget.goal.isPinned = false;
    await IsarService().saveQuantifiedGoal(widget.goal);
    widget.onUpdate();
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.widget});

  final GoalProgressCard widget;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Archive Goal?"),
      content: Text(
        "This will move '${widget.goal.title}' to your Inventory Log.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Archive"),
        ),
      ],
    );
  }
}
