import 'package:flutter/material.dart';
import 'package:pal_journal/components/target_goal/goal_progress_card/goal_progress_card.dart';

class GoalEditButton extends StatelessWidget {
  final GoalProgressCard gpc;
  final void Function(double) onUpdateValue;

  const GoalEditButton({
    super.key,
    required this.gpc,
    required this.onUpdateValue,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showManualEditDialog(context),
      icon: const Icon(Icons.edit_note, size: 20),
    );
  }

  void _showManualEditDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: gpc.goal.valueType == .decimal
          ? gpc.goal.currentValue.toString()
          : gpc.goal.currentValue.toInt().toString(),
    );
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ManualEditDialog(gpc: gpc, controller: controller),
    );

    if (result != true) return;
    final value = double.tryParse(controller.text) ?? gpc.goal.currentValue;
    onUpdateValue(value);
  }
}

class _ManualEditDialog extends StatefulWidget {
  const _ManualEditDialog({required this.gpc, required this.controller});

  final GoalProgressCard gpc;
  final TextEditingController controller;

  @override
  State<_ManualEditDialog> createState() => _ManualEditDialogState();
}

class _ManualEditDialogState extends State<_ManualEditDialog> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit ${widget.gpc.goal.title}"),
      content: TextField(
        controller: widget.controller,
        keyboardType: widget.gpc.goal.valueType == .decimal
            ? const .numberWithOptions(decimal: true)
            : .number,
        decoration: InputDecoration(suffixText: widget.gpc.goal.unit),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Save"),
        ),
      ],
    );
  }
}
