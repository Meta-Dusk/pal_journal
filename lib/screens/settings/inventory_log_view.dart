import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/components/goals/goal_creation_sheet.dart';
import 'package:pal_journal/models/quantified_goal.dart';
import 'package:pal_journal/services/isar_service.dart';

class InventoryLogView extends StatelessWidget {
  const InventoryLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory Log")),
      body: FutureBuilder<List<QuantifiedGoal>>(
        future: IsarService().getCompletedGoals(),
        builder: futureBuilder,
      ),
    );
  }

  Widget futureBuilder(
    BuildContext _,
    AsyncSnapshot<List<QuantifiedGoal>> snapshot,
  ) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final completed = snapshot.data!;

    if (completed.isEmpty) {
      return const Center(child: Text("No completed items in history."));
    }

    return ListView.builder(
      padding: const .all(16),
      itemCount: completed.length,
      itemBuilder: (context, index) {
        final goal = completed[index];
        return DismissibleLogEntry(goal: goal);
      },
    );
  }
}

class DismissibleLogEntry extends StatelessWidget {
  const DismissibleLogEntry({super.key, required this.goal});

  final QuantifiedGoal goal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key('archive_${goal.id}'),
      direction: .horizontal,

      // Background (Swipe Right -> Edit)
      background: Container(
        alignment: .centerLeft,
        padding: const .only(left: 20),
        margin: const .only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: .horizontal(left: .circular(16)),
        ),
        child: Icon(Icons.edit, color: colors.onPrimaryContainer),
      ),

      // Secondary Background (Swipe Left -> Delete)
      secondaryBackground: Container(
        alignment: .centerRight,
        padding: const .only(right: 20),
        margin: const .only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: .horizontal(right: .circular(16)),
        ),
        child: Icon(Icons.delete, color: colors.onError),
      ),

      confirmDismiss: (direction) async {
        if (direction == .startToEnd) {
          _showEditGoalDialog(context, goal);
          return false;
        } else {
          return await showDialog<bool>(
            context: context,
            builder: (_) => ConfirmationDialog(goal: goal),
          );
        }
      },
      onDismissed: (_) async {
        await IsarService().deleteQuantifiedGoal(goal.id);
      },
      child: Card(
        margin: const .only(bottom: 12),
        child: ListTileItemLog(goal: goal),
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, QuantifiedGoal goal) async {
    final bool? didChange = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: .circular(24)),
        ),
        child: GoalCreationSheet(existingGoal: goal),
      ),
    );

    // Trigger a rebuild of the Inventory Log to show updated data
    if (didChange == true) (context as Element).markNeedsBuild();
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({super.key, required this.goal});

  final QuantifiedGoal goal;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Delete History Log?"),
      content: Text("Are you sure you want to delete '${goal.title}'?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete Permanently"),
        ),
      ],
    );
  }
}

class ListTileItemLog extends StatelessWidget {
  const ListTileItemLog({super.key, required this.goal});

  final QuantifiedGoal goal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final value = goal.valueType == .integer
        ? goal.targetValue.toInt()
        : goal.targetValue;

    return ListTile(
      leading: Icon(Icons.inventory_2, color: colors.tertiary),
      title: Text(goal.title, style: const TextStyle(fontWeight: .bold)),
      subtitle: Text("Total: $value ${goal.unit}"),
      trailing: Text(
        DateFormat('yMMMd').format(goal.deadline),
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
      ),
    );
  }
}
