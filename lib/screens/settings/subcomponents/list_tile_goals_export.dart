import 'package:flutter/material.dart';
import 'package:pal_journal/services/csv/goal_csv_service.dart';

class ListTileGoalsExport extends StatelessWidget {
  const ListTileGoalsExport({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      tileColor: colors.surfaceContainer,
      leading: Icon(Icons.analytics, color: colors.primary),
      title: const Text("Export Monthly Goals (CSV)"),
      subtitle: const Text("Save all goals to a separate file"),
      onTap: () async => GoalCsvService.exportAllGoals(),
    );
  }
}
