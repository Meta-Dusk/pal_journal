import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/csv_service.dart';
import 'package:pal_journal/main.dart';

Future<bool?> showMonthSettingsDialog(BuildContext context, DateTime month) {
  final monthName = DateFormat('MMMM yyyy').format(month);

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: .vertical(top: .circular(20)),
    ),
    builder: (context) {
      final labelText = Text(
        "$monthName Settings",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: .bold,
          color: Colors.white,
        ),
      );

      final mainContent = [
        labelText,
        const SizedBox(height: 24),
        ListTileSetGoal(), // Placeholder
        ListTileExportCSV(month: month),
        ListTileImportCSV(month: month),
        const Divider(color: Colors.white24, height: 32),
        ListTileClearData(month: month, monthName: monthName),
        const SizedBox(height: 16),
      ];

      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const .all(24.0),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: mainContent,
            ),
          ),
        ),
      );
    },
  );
}

class ListTileSetGoal extends StatelessWidget {
  const ListTileSetGoal({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(Icons.flag, color: colors.secondary),
      title: const Text("Set Monthly Goal"),
      subtitle: const Text("Coming soon...", style: TextStyle(fontSize: 12)),
      onTap: () {}, // Do nothing for now
    );
  }
}

class ListTileExportCSV extends StatelessWidget {
  final DateTime month;

  const ListTileExportCSV({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(Icons.file_download, color: colors.secondary),
      title: const Text("Export to CSV"),
      subtitle: const Text(
        "Save this month's data as a spreadsheet",
        style: TextStyle(fontSize: 12),
      ),
      onTap: () async {
        Navigator.pop(context); // Close the bottom sheet
        await CsvService.exportMonth(month);
      },
    );
  }
}

class ListTileImportCSV extends StatelessWidget {
  final DateTime month;

  const ListTileImportCSV({super.key, required this.month});

  static const String warningText =
      "This will merge the CSV data into the current month."
      "If a date in the CSV matches an existing entry, "
      "the existing entry will be OVERWRITTEN.\n\nDo you want to continue?";

  void _importCsvData(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Import Data?", textAlign: .center),
          content: const Text(warningText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Import", style: TextStyle(color: colors.tertiary)),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    final success = await CsvService.importMonth(month);

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context, true); // Close bottom sheet & refresh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data imported successfully!"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(Icons.download, color: colors.tertiary),
      title: const Text("Import from CSV"),
      subtitle: const Text(
        "Merge spreadsheet data into this month",
        style: TextStyle(fontSize: 12),
      ),
      onTap: () async => _importCsvData(context),
    );
  }
}

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

Future<bool?> confirmationDialog(BuildContext context, String monthName) {
  final colors = Theme.of(context).colorScheme;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Are you sure?",
        textAlign: .center,
        style: TextStyle(color: colors.error),
      ),
      content: Text(
        "This will permanently delete all logged data for $monthName.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Delete All", style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
}
