import 'package:confetti/confetti.dart';
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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerConfetti() => _confettiController.play();

  Future<void> _adjustValue(double amount) async {
    // Consolidate logic to use the same check as manual edit
    final newValue = widget.goal.currentValue + amount;
    await _updateGoalValue(newValue);
  }

  Future<void> _updateGoalValue(double newValue) async {
    widget.goal.currentValue = newValue < 0 ? 0 : newValue;

    if (widget.goal.currentValue >= widget.goal.targetValue &&
        !widget.goal.isCompleted) {
      widget.goal.isCompleted = true;
      _triggerConfetti();
    } else if (widget.goal.currentValue < widget.goal.targetValue) {
      widget.goal.isCompleted = false;
    }

    await IsarService().saveQuantifiedGoal(widget.goal);
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDecimal = widget.goal.valueType == .decimal;
    final isArchived = widget.goal.isCompleted && !widget.goal.isPinned;
    final isFinishedButPinned = widget.goal.isCompleted && widget.goal.isPinned;

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

    final subContent = [
      if (isFinishedButPinned)
        IconButton(
          onPressed: () => _showArchiveConfirmation(context),
          icon: Icon(Icons.archive_outlined, color: colors.tertiary),
          tooltip: "Archive Goal",
        ),
      IconButton(
        onPressed: () => _showManualEdit(context),
        icon: const Icon(Icons.edit_note, size: 20),
      ),
    ];

    final mainHeader = Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Row(
          spacing: 8,
          children: [
            Text(widget.goal.title, style: textTheme.titleMedium),
            if (widget.goal.isCompleted)
              Icon(Icons.check_circle, color: colors.primary, size: 16),
          ],
        ),
        if (widget.goal.isPinned && widget.showPinnedIcon)
          Icon(Icons.push_pin, size: 16, color: colors.primary),
        if (!isArchived) Row(spacing: 5, children: subContent),
      ],
    );

    final mainContent = [
      mainHeader,
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
      if (!isArchived) Row(mainAxisAlignment: .spaceEvenly, children: buttons),
      if (isArchived)
        Center(
          child: Padding(
            padding: const .symmetric(vertical: 8),
            child: Text(
              "Archived in Inventory Log",
              style: TextStyle(
                color: colors.primary,
                fontSize: 12,
                fontWeight: .bold,
              ),
            ),
          ),
        ),
    ];

    return Opacity(
      opacity: isArchived ? 0.8 : 1.0,
      child: Stack(
        alignment: .center,
        children: [
          Card(
            color: isArchived ? colors.surfaceContainerHighest : null,
            shape: RoundedRectangleBorder(borderRadius: .circular(16)),
            child: Padding(
              padding: const .all(16.0),
              child: Column(crossAxisAlignment: .start, children: mainContent),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: .explosive,
            colors: [
              colors.primary,
              colors.tertiary,
              colors.secondary,
              colors.inversePrimary,
              colors.onPrimary,
              colors.onTertiary,
              colors.onSecondary,
              colors.onPrimaryFixed,
            ],
            numberOfParticles: 20,
          ),
        ],
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
      builder: (context) => manualEditDialog(controller, context),
    );
  }

  AlertDialog manualEditDialog(
    TextEditingController controller,
    BuildContext context,
  ) {
    final actions = [
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
    ];

    return AlertDialog(
      title: Text("Edit ${widget.goal.title}"),
      content: TextField(
        controller: controller,
        keyboardType: widget.goal.valueType == .decimal
            ? const .numberWithOptions(decimal: true)
            : .number,
        decoration: InputDecoration(suffixText: widget.goal.unit),
      ),
      actions: actions,
    );
  }

  void _showArchiveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Archive Goal?"),
        content: Text(
          "This will move '${widget.goal.title}' to your Inventory Log.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              widget.goal.isPinned = false;
              await IsarService().saveQuantifiedGoal(widget.goal);

              if (!context.mounted) return;
              Navigator.pop(context);
              widget.onUpdate();
            },
            child: const Text("Archive"),
          ),
        ],
      ),
    );
  }
}
