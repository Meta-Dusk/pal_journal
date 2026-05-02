import 'package:flutter/material.dart';
import 'package:pal_journal/services/csv_service.dart';

class ListTileGlobalExport extends StatelessWidget {
  const ListTileGlobalExport({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      tileColor: colors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(16)),
      ),
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
