import 'package:flutter/material.dart';
import 'package:pal_journal/services/csv/csv_service.dart';

enum CSVCategory { pnl, quantified, monthly }

class CSVToolCard extends StatefulWidget {
  const CSVToolCard({super.key});

  @override
  State<CSVToolCard> createState() => _CSVToolCardState();
}

class _CSVToolCardState extends State<CSVToolCard> {
  CSVCategory _selectedCategory = .pnl;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      Expanded(
        child: FilledButton.icon(
          onPressed: () => _handleExport(),
          icon: const Icon(Icons.upload_file),
          label: const Text("Export"),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _handleImport(),
          icon: const Icon(Icons.file_download),
          label: const Text("Import"),
        ),
      ),
    ];

    return Column(
      children: [
        segmentedButton(),
        const SizedBox(height: 16),
        Row(children: buttons),
      ],
    );
  }

  SegmentedButton<CSVCategory> segmentedButton() {
    return SegmentedButton<CSVCategory>(
      segments: const [
        ButtonSegment(
          value: .pnl,
          label: Text("PnL"),
          icon: Icon(Icons.leaderboard),
        ),
        ButtonSegment(
          value: .quantified,
          label: Text("Goals"),
          icon: Icon(Icons.track_changes),
        ),
        ButtonSegment(
          value: .monthly,
          label: Text("Targets"),
          icon: Icon(Icons.calendar_view_month),
        ),
      ],
      selected: {_selectedCategory},
      onSelectionChanged: (set) =>
          setState(() => _selectedCategory = set.first),
    );
  }

  Future<void> _handleExport() async {
    switch (_selectedCategory) {
      case .pnl:
        await CsvService.exportAllPnl();
        break;
      case .quantified:
        await CsvService.exportAllTargetGoals();
        break;
      case .monthly:
        await CsvService.exportAllMonthlyGoals();
        break;
    }
    _showStatus("Export complete!");
  }

  Future<void> _handleImport() async {
    bool success = false;
    switch (_selectedCategory) {
      case .pnl:
        success = await CsvService.importAllPnl();
        break;
      case .quantified:
        success = await CsvService.importAllTargetGoals();
        break;
      case .monthly:
        success = await CsvService.importAllTargetGoals();
        break;
    }
    _showStatus(
      success ? "Import successful!" : "Import failed.",
      isError: !success,
    );
  }

  void _showStatus(String msg, {bool isError = false}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? colors.error : null,
        content: Text(
          msg,
          style: TextStyle(color: isError ? colors.onError : null),
        ),
      ),
    );
  }
}
