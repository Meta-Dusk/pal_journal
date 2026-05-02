import 'package:flutter/material.dart';
import 'package:pal_journal/services/csv_service.dart';

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
