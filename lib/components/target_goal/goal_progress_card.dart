import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:pal_journal/models/quantified_goal.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'subcomponents/goal_buttons.dart';

class GoalProgressCard extends StatefulWidget {
  final QuantifiedGoal goal;
  final VoidCallback onUpdate;

  const GoalProgressCard({
    super.key,
    required this.goal,
    required this.onUpdate,
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
    final currentValue = widget.goal.currentValue;
    final targetValue = widget.goal.targetValue;

    if (currentValue >= targetValue && !widget.goal.isCompleted) {
      widget.goal.isCompleted = true;
      _triggerConfetti();
    } else if (currentValue < targetValue) {
      widget.goal.isCompleted = false;
    }

    await IsarService().saveQuantifiedGoal(widget.goal);
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isPinned = widget.goal.isPinned;
    final isArchived = widget.goal.isCompleted && !isPinned;

    final cardContent = [
      GoalHeader(onUpdateValue: _adjustValue, gpc: widget),
      const SizedBox(height: 12),
      GoalProgress(gpc: widget),
      const SizedBox(height: 16),
      if (!isArchived) IncrementButtons(gpc: widget, onIncrement: _adjustValue),
      if (isArchived) ArchivedStatus(),
    ];

    final mainContent = [
      _GoalProgressCardContent(
        isArchived: isArchived,
        cardContent: cardContent,
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
    ];

    return Opacity(
      opacity: isArchived ? 0.8 : 1.0,
      child: Stack(alignment: .center, children: mainContent),
    );
  }
}

class _GoalProgressCardContent extends StatelessWidget {
  const _GoalProgressCardContent({
    required this.isArchived,
    required this.cardContent,
  });

  final bool isArchived;
  final List<Widget> cardContent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: isArchived ? colors.surfaceContainerHighest : null,
      shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      child: Padding(
        padding: const .all(16.0),
        child: Column(crossAxisAlignment: .start, children: cardContent),
      ),
    );
  }
}
