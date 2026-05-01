import 'package:flutter/material.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/csv_service.dart';
import 'package:pal_journal/main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Global Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const .all(16.0),
        children: [
          const Text(
            "Data Management",
            style: TextStyle(
              color: Colors.tealAccent,
              fontWeight: .bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ListTileGlobalExport(),
          const SizedBox(height: 12),
          ListTileGlobalImport(),
          const SizedBox(height: 32),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // --- THE DANGER ZONE ---
          const Text(
            "Danger Zone",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: .bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ListTileGlobalClear(),
        ],
      ),
    );
  }
}

class ListTileGlobalClear extends StatelessWidget {
  const ListTileGlobalClear({super.key});

  static const String warningText =
      "This action CANNOT be undone.\n\n"
      "Every single entry, breakdown, and note in your entire journal "
      "will be permanently deleted.\n\nAre you absolutely sure?";

  void _clearData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "WIPE ALL DATA?",
            style: TextStyle(color: Colors.redAccent, fontWeight: .bold),
          ),
          content: const Text(
            warningText,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "DELETE EVERYTHING",
                style: TextStyle(color: Colors.redAccent, fontWeight: .bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && context.mounted) {
      final isar = await isarService.db;

      // Clear the entire collection in one massive swipe
      await isar.writeTxn(() async {
        await isar.collection<PnLEntry>().clear();
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All data has been permanently deleted."),
          backgroundColor: Colors.redAccent,
        ),
      );

      // Pop back to the home screen so the user sees the empty calendar
      if (!Navigator.canPop(context)) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
      title: const Text(
        "Wipe All Data",
        style: TextStyle(color: Colors.redAccent, fontWeight: .bold),
      ),
      subtitle: const Text(
        "Permanently erase your entire journal",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () async => _clearData(context),
    );
  }
}

void _globalImportCsv(BuildContext context) async {
  const warningText =
      "You are about to import data across ALL months.\n\n"
      "Any existing entries on the dates contained in the CSV will "
      "be permanently OVERWRITTEN.\n\n"
      "Are you absolutely sure you want to proceed?";

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "GLOBAL IMPORT WARNING",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          warningText,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "I Understand, Import",
              style: TextStyle(color: Colors.redAccent),
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
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: success ? Colors.teal : Colors.redAccent,
    ),
  );
}

class ListTileGlobalImport extends StatelessWidget {
  const ListTileGlobalImport({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      leading: const Icon(Icons.restore, color: Colors.purpleAccent),
      title: const Text(
        "Restore Data (CSV)",
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        "Import a complete backup file",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () async => _globalImportCsv(context),
    );
  }
}

class ListTileGlobalExport extends StatelessWidget {
  const ListTileGlobalExport({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      leading: const Icon(Icons.backup, color: Colors.blueAccent),
      title: const Text(
        "Backup All Data (CSV)",
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        "Export your entire journal history",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () async {
        await CsvService.exportAll();
      },
    );
  }
}
