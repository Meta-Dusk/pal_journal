import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/csv_service.dart';
import 'package:pal_journal/main.dart';
import 'package:pal_journal/services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Global Settings"),
        iconTheme: const IconThemeData(),
        elevation: 0,
      ),
      body: ListView(
        padding: const .all(16.0),
        children: [
          const Text(
            "Appearance",
            style: TextStyle(fontWeight: .bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const ListTileThemeColor(),
          const SizedBox(height: 32),
          const Text(
            "Data Management",
            style: TextStyle(fontWeight: .bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ListTileGlobalExport(),
          const SizedBox(height: 12),
          ListTileGlobalImport(),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            "Danger Zone",
            style: TextStyle(
              fontWeight: .bold,
              fontSize: 14,
              color: colors.error,
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
    final colors = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "WIPE ALL DATA?",
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
                "DELETE EVERYTHING",
                style: TextStyle(fontWeight: .bold, color: colors.error),
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
        SnackBar(
          content: Text(
            "All data has been permanently deleted.",
            style: TextStyle(color: colors.onError),
            textAlign: .center,
          ),
          backgroundColor: colors.error,
        ),
      );

      // Pop back to the home screen so the user sees the empty calendar
      if (!Navigator.canPop(context)) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      leading: Icon(Icons.delete_forever, color: colors.error),
      title: Text(
        "Wipe All Data",
        style: TextStyle(fontWeight: .bold, color: colors.error),
      ),
      subtitle: const Text(
        "Permanently erase your entire journal",
        style: TextStyle(fontSize: 12),
      ),
      onTap: () async => _clearData(context),
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

class ListTileGlobalImport extends StatelessWidget {
  const ListTileGlobalImport({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
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

class ListTileGlobalExport extends StatelessWidget {
  const ListTileGlobalExport({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: colors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      leading: Icon(Icons.backup, color: colors.primary),
      title: const Text("Backup All Data (CSV)"),
      subtitle: const Text(
        "Export your entire journal history",
        style: TextStyle(fontSize: 12),
      ),
      onTap: () async {
        await CsvService.exportAll();
      },
    );
  }
}

class ListTileThemeColor extends StatelessWidget {
  const ListTileThemeColor({super.key});

  void _showDialog(BuildContext context, Color currentColor) {
    // Temporary variable to hold the color while they drag the wheel
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a theme color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (Color color) {
              pickerColor = color;
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false, // Only solid colors for theme seed
            displayThumbColor: true,
            paletteType: .hsvWithHue,
            labelTypes: const [], // Hides hex codes for cleaner UI
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Apply'),
            onPressed: () {
              ThemeService.updateSeedColor(pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.seedColorNotifier,
      builder: (context, currentColor, child) {
        return ListTile(
          tileColor: colors.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: .circular(12)),
          leading: Icon(Icons.palette, color: colors.primary),
          title: Text("App Theme Color"),
          subtitle: Text(
            "Choose your custom accent color",
            style: TextStyle(fontSize: 12),
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: currentColor,
              shape: .circle,
              border: .all(width: 1),
            ),
          ),
          onTap: () => _showDialog(context, currentColor),
        );
      },
    );
  }
}
