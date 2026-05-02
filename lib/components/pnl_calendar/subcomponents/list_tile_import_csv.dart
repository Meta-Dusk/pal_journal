import 'package:flutter/material.dart';
import 'package:pal_journal/services/csv_service.dart';

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
