import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/services/isar_service.dart';

class GoalCsvService {
  static String mapToCsv(List<MonthlyGoal> goals) {
    // Header row
    String csv = "Month,Type,Amount,Offset\n";

    for (var goal in goals) {
      csv +=
          "${goal.month.toIso8601String()},"
          "${goal.type.name},"
          "${goal.amount},"
          "${goal.syncedOffset}\n";
    }
    return csv;
  }

  static List<MonthlyGoal> mapFromCsv(String csvContent) {
    final lines = csvContent.split('\n');
    List<MonthlyGoal> goals = [];

    // Skip header row
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      final parts = lines[i].split(',');

      goals.add(
        MonthlyGoal()
          ..month = DateTime.parse(parts[0])
          ..type = GoalType.values.byName(parts[1])
          ..amount = double.parse(parts[2])
          ..syncedOffset = double.parse(parts[3]),
      );
    }
    return goals;
  }

  static Future<void> exportAllGoals() async {
    final goals = await IsarService().getAllGoals();
    final csvData = GoalCsvService.mapToCsv(goals);

    String? outputFile = await FilePicker.saveFile(
      fileName: 'PAL_Journal_Goals_Backup.csv',
      type: .custom,
      allowedExtensions: ['csv'],
    );

    if (outputFile != null) {
      await File(outputFile).writeAsString(csvData);
    }
  }

  static Future<bool> importAllGoals() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: .custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) return false;

    final csvString = await File(result.files.single.path!).readAsString();
    final goals = GoalCsvService.mapFromCsv(csvString);

    await IsarService().replaceAllGoals(goals);
    return true;
  }
}
