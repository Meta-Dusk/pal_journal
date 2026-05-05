import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/components/goals/goal_progress_card.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/models/quantified_goal.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/utils/formatters.dart';

class DetailsSheet extends StatelessWidget {
  final DateTime day;
  final PnLEntry? entry;
  final List<QuantifiedGoal>? goals;
  final VoidCallback onEditPressed;
  final VoidCallback onRefresh;

  const DetailsSheet({
    super.key,
    required this.day,
    this.entry,
    this.goals,
    required this.onEditPressed,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final formattedDate = DateFormat('MMMM d, yyyy').format(day);

    final symbol = CurrencyService.symbol;
    final currency1 = AppFormatters.toCurrency(
      CurrencyService.toDisplay(entry?.amount ?? 0.0),
    );

    final noteEntry = [
      const SizedBox(height: 16),
      Container(
        padding: const .all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: .circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.sticky_note_2, color: colors.onSurfaceVariant, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(entry?.note ?? "")),
          ],
        ),
      ),
    ];

    final breakdownEntry = [
      const SizedBox(height: 16),
      Text(
        "Breakdown",
        style: TextStyle(color: colors.onSurfaceVariant, fontWeight: .bold),
      ),
      const SizedBox(height: 8),
      if (entry != null)
        ...entry!.breakdown!.map((item) {
          final currency2 = AppFormatters.toCurrency(
            CurrencyService.toDisplay(item.amount ?? 0.0),
          );
          return Padding(
            padding: const .symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(item.category ?? "Unknown"),
                Text("$symbol $currency2"),
              ],
            ),
          );
        }),
    ];

    final quantifiedGoals = [
      const SizedBox(height: 8),
      const Divider(),
      Padding(
        padding: const .symmetric(vertical: 8.0),
        child: Text(
          "Goals Due Today",
          style: TextStyle(color: colors.onSurfaceVariant, fontWeight: .bold),
        ),
      ),
      if (goals != null)
        ...goals!.map((goal) => _buildDismissibleGoal(goal, context, colors)),
    ];

    final mainContent = [
      Text(
        formattedDate,
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
      ),
      const SizedBox(height: 8),
      Text(
        entry != null ? "$symbol $currency1" : "No Data",
        style: const TextStyle(fontSize: 32, fontWeight: .bold),
      ),
      if (entry?.note != null && entry!.note!.isNotEmpty) ...noteEntry,
      if (entry?.breakdown != null && entry!.breakdown!.isNotEmpty)
        ...breakdownEntry,
      const SizedBox(height: 24),
      EditButton(onEditPressed: onEditPressed),
      if (goals != null && goals!.isNotEmpty) ...quantifiedGoals,
    ];

    return SingleChildScrollView(
      padding: const .all(24.0),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: mainContent,
      ),
    );
  }

  ListTile getListTileGoal(ColorScheme colors, QuantifiedGoal goal) {
    return ListTile(
      leading: Icon(Icons.star, color: colors.tertiary),
      title: Text(goal.title),
      subtitle: Text("${goal.currentValue} / ${goal.targetValue} ${goal.unit}"),
      trailing: Text("${(goal.progress * 100).toInt()}%"),
    );
  }

  Widget _buildDismissibleGoal(
    QuantifiedGoal goal,
    BuildContext context,
    ColorScheme colors,
  ) {
    return Dismissible(
      key: Key('goal_${goal.id}'),
      direction: .startToEnd,
      background: Container(
        alignment: .centerLeft,
        padding: const .only(left: 20),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: .circular(16),
        ),
        child: Icon(Icons.delete_outline, color: colors.onError),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(context, goal),
      onDismissed: (_) => onEditPressed(),
      child: GoalProgressCard(
        goal: goal,
        onUpdate: onRefresh,
        showPinnedIcon: false,
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    QuantifiedGoal goal,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final actions = [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              await IsarService().deleteQuantifiedGoal(goal.id);
              if (!context.mounted) return;
              Navigator.pop(context, true);
              onRefresh();
            },
            child: const Text("Delete"),
          ),
        ];

        return AlertDialog(
          title: const Text("Delete Goal?"),
          content: Text("Are you sure you want to delete '${goal.title}'?"),
          actions: actions,
        );
      },
    );
  }
}

class EditButton extends StatelessWidget {
  final VoidCallback onEditPressed;

  const EditButton({super.key, required this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onEditPressed,
        icon: const Icon(Icons.edit),
        label: const Text("Edit Day"),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          padding: const .symmetric(vertical: 16),
        ),
      ),
    );
  }
}
