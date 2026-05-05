import 'package:flutter/material.dart';
import 'package:pal_journal/models/quantified_goal.dart';
import 'package:pal_journal/services/isar_service.dart';

class GoalProgressCard extends StatefulWidget {
  final QuantifiedGoal goal;
  final VoidCallback onUpdate; // For incrementing/decrementing
  final bool showPinnedIcon;

  const GoalProgressCard({
    super.key,
    required this.goal,
    required this.onUpdate,
    this.showPinnedIcon = true,
  });

  @override
  State<GoalProgressCard> createState() => _GoalProgressCardState();
}

class _GoalProgressCardState extends State<GoalProgressCard> {
  Future<void> _adjustValue(double amount) async {
    final newValue = widget.goal.currentValue + amount;
    // Prevent negative progress but allow going over target
    widget.goal.currentValue = newValue < 0 ? 0 : newValue;
    if (widget.goal.currentValue >= widget.goal.targetValue) {
      widget.goal.isCompleted = true;
    }

    await IsarService().saveQuantifiedGoal(widget.goal);
    widget.onUpdate();
  }

  Future<void> _updateGoalValue(double newValue) async {
    widget.goal.currentValue = newValue < 0 ? 0 : newValue;
    if (widget.goal.currentValue >= widget.goal.targetValue) {
      widget.goal.isCompleted = true;
    }

    await IsarService().saveQuantifiedGoal(widget.goal);
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDecimal = widget.goal.valueType == GoalValueType.decimal;

    final buttons = [
      _buildIncrementBtn(
        context,
        isDecimal ? -1.0 : -10.0,
        isDecimal ? "-1" : "-10",
      ),
      _buildIncrementBtn(
        context,
        isDecimal ? -0.1 : -1.0,
        isDecimal ? "-0.1" : "-1",
      ),
      const SizedBox(width: 8),
      _buildIncrementBtn(
        context,
        isDecimal ? 0.1 : 1.0,
        isDecimal ? "+0.1" : "+1",
      ),
      _buildIncrementBtn(
        context,
        isDecimal ? 1.0 : 10.0,
        isDecimal ? "+1" : "+10",
      ),
    ];

    final mainContent = [
      Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(widget.goal.title, style: textTheme.titleMedium),
          if (widget.goal.isPinned && widget.showPinnedIcon)
            Icon(Icons.push_pin, size: 16, color: colors.primary),
          IconButton(
            onPressed: () => _showManualEdit(context),
            icon: const Icon(Icons.edit_note, size: 20),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: widget.goal.progress,
              minHeight: 8,
              borderRadius: .circular(16),
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "${widget.goal.currentValue.toStringAsFixed(isDecimal ? 1 : 0)} / "
            "${widget.goal.targetValue.toStringAsFixed(isDecimal ? 1 : 0)} "
            "${widget.goal.unit}",
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: .bold,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: .spaceEvenly, children: buttons),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      child: Padding(
        padding: const .all(16.0),
        child: Column(crossAxisAlignment: .start, children: mainContent),
      ),
    );
  }

  Widget _buildIncrementBtn(BuildContext context, double amount, String label) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        padding: const .symmetric(horizontal: 12),
        minimumSize: const Size(60, 40),
      ),
      onPressed: () => _adjustValue(amount),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: .bold),
      ),
    );
  }

  void _showManualEdit(BuildContext context) {
    final controller = TextEditingController(
      text: widget.goal.valueType == .decimal
          ? widget.goal.currentValue.toString()
          : widget.goal.currentValue.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${widget.goal.title}"),
        content: TextField(
          controller: controller,
          keyboardType: widget.goal.valueType == .decimal
              ? const .numberWithOptions(decimal: true)
              : .number,
          decoration: InputDecoration(suffixText: widget.goal.unit),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              final val =
                  double.tryParse(controller.text) ?? widget.goal.currentValue;
              _updateGoalValue(val);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
