import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/services/csv_service.dart';

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
        ListTileClearData(monthName: monthName),
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
    return ListTile(
      leading: const Icon(Icons.flag, color: Colors.tealAccent),
      title: const Text(
        "Set Monthly Goal",
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        "Coming soon...",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () {}, // Do nothing for now
    );
  }
}

class ListTileExportCSV extends StatelessWidget {
  final DateTime month;

  const ListTileExportCSV({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.file_download, color: Colors.blueAccent),
      title: const Text("Export to CSV", style: TextStyle(color: Colors.white)),
      subtitle: const Text(
        "Save this month's data as a spreadsheet",
        style: TextStyle(color: Colors.grey, fontSize: 12),
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

  /// Opens the file picker and runs the import logic
  void _importCsvAction(BuildContext context) async {
    final success = await CsvService.importMonth(month);

    if (!context.mounted) return;

    // Just close the sheet, or it means the user canceled the file picker
    if (!success) Navigator.pop(context, false);

    // Tell the calendar to refresh its data
    Navigator.pop(context, true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data imported successfully!"),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.file_download, color: Colors.purpleAccent),
      title: const Text(
        "Import from CSV",
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        "Merge spreadsheet data into this month",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () async => _importCsvAction(context),
    );
  }
}

class ListTileClearData extends StatelessWidget {
  final String monthName;

  const ListTileClearData({super.key, required this.monthName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
      title: const Text(
        "Reset Month Data",
        style: TextStyle(color: Colors.redAccent, fontWeight: .bold),
      ),
      subtitle: const Text(
        "Delete all entries for this month",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () async {
        // Show confirmation dialog
        final confirm = await confirmationDialog(context, monthName);

        // If confirmed, close the bottom sheet and return true to the calendar
        if (confirm == true && context.mounted) {
          Navigator.pop(context, true);
        }
      },
    );
  }
}

Future<bool?> confirmationDialog(BuildContext context, String monthName) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Are you sure?", style: TextStyle(color: Colors.white)),
      content: Text(
        "This will permanently delete all logged data for $monthName.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            "Delete All",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}
