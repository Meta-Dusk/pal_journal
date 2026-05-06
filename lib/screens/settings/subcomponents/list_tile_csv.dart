import 'package:flutter/material.dart';
import 'package:pal_journal/components/csv_tool_card.dart';
import 'package:pal_journal/services/csv/csv_service.dart';

class ListTileCSV extends StatefulWidget {
  const ListTileCSV({super.key});

  @override
  State<ListTileCSV> createState() => _ListTileCSVState();
}

class _ListTileCSVState extends State<ListTileCSV> {
  CSVCategory _selectedCategory = .pnl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      shape: const RoundedRectangleBorder(borderRadius: .all(.circular(16))),
      tileColor: colors.surfaceContainer,
      leading: Icon(Icons.file_present, color: colors.primary),
      title: const Text("CSV Data Tools"),
      subtitle: const Text(
        "Import or Export your data multitude",
        style: TextStyle(fontSize: 12),
      ),
      trailing: Text(
        _selectedCategory.name.toUpperCase(),
        style: TextStyle(color: colors.primary, fontWeight: .bold),
      ),
      onTap: () => _showCSVActionDialog(context),
    );
  }

  void _showCSVActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CSVActionDialog(
        initialCategory: _selectedCategory,
        onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
      ),
    );
  }
}

class CSVActionDialog extends StatefulWidget {
  final CSVCategory initialCategory;
  final Function(CSVCategory) onCategoryChanged;

  const CSVActionDialog({
    super.key,
    required this.initialCategory,
    required this.onCategoryChanged,
  });

  @override
  State<CSVActionDialog> createState() => _CSVActionDialogState();
}

class _CSVActionDialogState extends State<CSVActionDialog> {
  late CSVCategory _tempCategory;

  @override
  void initState() {
    super.initState();
    _tempCategory = widget.initialCategory;
  }

  String _getCategoryName(CSVCategory category) {
    switch (category) {
      case .pnl:
        return "PnL";
      case .monthly:
        return "Monthly Goals";
      case .quantified:
        return "Monthly Targets";
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      const Text("Select category to process:"),
      const SizedBox(height: 12),
      RadioGroup<CSVCategory>(
        groupValue: _tempCategory,
        onChanged: (value) {
          if (value != null) {
            setState(() => _tempCategory = value);
            widget.onCategoryChanged(value);
          }
        },
        child: Column(
          children: CSVCategory.values.map((category) {
            return RadioListTile<CSVCategory>(
              title: Text(_getCategoryName(category)),
              value: category,
            );
          }).toList(),
        ),
      ),
    ];

    return AlertDialog(
      title: const Text("CSV Category & Action"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(mainAxisSize: .min, children: mainContent),
      ),
      actions: [
        TextButton(
          onPressed: () => _handleCSVAction(isExport: false),
          child: const Text("Import"),
        ),
        FilledButton(
          onPressed: () => _handleCSVAction(isExport: true),
          child: const Text("Export"),
        ),
      ],
    );
  }

  Future<void> _handleCSVAction({required bool isExport}) async {
    Navigator.pop(context);

    if (isExport) {
      if (_tempCategory == .pnl) {
        await CsvService.exportAllPnl();
      }
      if (_tempCategory == .quantified) {
        await CsvService.exportAllTargetGoals();
      }
      if (_tempCategory == .monthly) {
        await CsvService.exportAllMonthlyGoals();
      }
    } else {
      _globalImportCsv(context, _tempCategory);
    }
  }
}

void _globalImportCsv(BuildContext context, CSVCategory category) async {
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

  if (confirm != true) return;

  late bool success;
  switch (category) {
    case .pnl:
      success = await CsvService.importAllPnl();
      break;
    case .quantified:
      success = await CsvService.importAllTargetGoals();
      break;
    case .monthly:
      success = await CsvService.importAllMonthlyGoals();
      break;
  }

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success ? "Global restore complete!" : "Import failed or canceled.",
        style: TextStyle(color: success ? null : colors.onError),
      ),
      backgroundColor: success ? null : colors.error,
    ),
  );
}
