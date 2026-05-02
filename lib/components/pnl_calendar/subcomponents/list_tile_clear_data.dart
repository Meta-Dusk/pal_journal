import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pal_journal/components/pnl_calendar/subcomponents/confirmation_dialog.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/main.dart';

class ListTileClearData extends StatelessWidget {
  final DateTime month;
  final String monthName;

  const ListTileClearData({
    super.key,
    required this.month,
    required this.monthName,
  });

  void _clearData(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;

    final confirm = await confirmationDialog(context, monthName);
    if (confirm == true) {
      await _deleteMonthData(month);
      if (!context.mounted) return;
      // Return true so the calendar knows to refresh the UI
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$monthName data cleared.",
            style: TextStyle(color: colors.onError),
          ),
          backgroundColor: colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(Icons.delete_forever, color: colors.error),
      title: Text(
        "Reset Month Data",
        style: TextStyle(color: colors.error, fontWeight: .bold),
      ),
      subtitle: const Text(
        "Delete all entries for this month",
        style: TextStyle(fontSize: 12),
      ),
      onTap: () async => _clearData(context),
    );
  }

  /// Bulletproof Isar deletion targeting the exact month boundaries
  Future<void> _deleteMonthData(DateTime targetMonth) async {
    final isar = await isarService.db;

    // Start: The exact first microsecond of the 1st day of the month
    final startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);

    // End: We go to the 1st day of the NEXT month, and subtract 1 microsecond.
    // This perfectly captures the absolute end of the target month (e.g., 23:59:59.999)
    final endOfMonth = DateTime(
      targetMonth.year,
      targetMonth.month + 1,
      1,
    ).subtract(const Duration(microseconds: 1));

    await isar.writeTxn(() async {
      // Find all entries that fall within these boundaries
      final entriesToDelete = await isar
          .collection<PnLEntry>()
          .filter()
          .dateBetween(startOfMonth, endOfMonth)
          .findAll();

      // Extract their IDs and delete them all in one batch
      final idsToDelete = entriesToDelete.map((e) => e.id).toList();

      // We use where().anyId() with deleteAll to ensure strict safety
      await isar.collection<PnLEntry>().deleteAll(idsToDelete);
    });
  }
}
