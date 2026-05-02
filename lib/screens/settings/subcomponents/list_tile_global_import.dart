import 'package:flutter/material.dart';
import 'package:pal_journal/services/csv_service.dart';

class ListTileGlobalImport extends StatelessWidget {
  const ListTileGlobalImport({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: colors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(bottom: .circular(16)),
      ),
      leading: Icon(Icons.restore, color: colors.primary),
      title: const Text("Restore Data (CSV)"),
      subtitle: const Text(
        "Import a complete backup file",
        style: TextStyle(fontSize: 12),
      ),
      onTap: () async => _globalImportCsv(context),
    );
  }
}

void _globalImportCsv(BuildContext context) async {
  final colors = Theme.of(context).colorScheme;
  const warningText =
      "You are about to import data across ALL months.\n\n"
      "Any existing entries on the dates contained in the CSV will "
      "be permanently OVERWRITTEN.\n\n"
      "Are you absolutely sure you want to proceed?";

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "GLOBAL IMPORT WARNING",
          style: TextStyle(fontWeight: .bold, color: colors.error),
          textAlign: .center,
        ),
        content: const Text(warningText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "I Understand, Import",
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      );
    },
  );

  if (confirm != true || !context.mounted) return;

  final success = await CsvService.importAll();

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success ? "Global restore complete!" : "Import failed or canceled.",
      ),
    ),
  );
}
