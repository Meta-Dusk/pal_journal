import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:pal_journal/components/csv_tool_card.dart';

import 'package:pal_journal/main.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/models/quantified_goal.dart';
import 'package:pal_journal/services/isar_service.dart';
import './csv_parsing.dart';

typedef Dynamic2DList = List<List<dynamic>>;

class CsvService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// Exports the currently viewed month to a CSV using a Native Save As Dialog
  static Future<void> exportMonth(DateTime targetDate) async {
    final isar = await isarService.db;

    final startOfMonth = DateTime(targetDate.year, targetDate.month, 1);
    final endOfMonth = DateTime(
      targetDate.year,
      targetDate.month + 1,
      0,
      23,
      59,
      59,
    );

    final entries = await isar
        .collection<PnLEntry>()
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
        .sortByDate()
        .findAll();

    List<List<dynamic>> rows = [
      ['Date', 'Daily Total', 'Note', 'Breakdown Category', 'Breakdown Amount'],
    ];

    for (PnLEntry entry in entries) {
      final dateStr = _dateFormat.format(entry.date);

      if (entry.breakdown == null || entry.breakdown!.isEmpty) {
        rows.add([dateStr, entry.amount, entry.note ?? '', '', '']);
      } else {
        for (ExpenseItem item in entry.breakdown!) {
          rows.add([
            dateStr,
            entry.amount,
            entry.note ?? '',
            item.category ?? '',
            item.amount ?? 0.0,
          ]);
        }
      }
    }

    final String csvData = CsvParsing.listToCsv(rows);
    final String monthName = DateFormat('MMM_yyyy').format(targetDate);

    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save CSV Data',
      fileName: 'PAL_Journal_$monthName.csv',
      type: .custom,
      allowedExtensions: ['csv'],
    );

    // If the user didn't cancel the dialog, save the file!
    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(csvData);
    }
  }

  static Future<void> exportMonthCategory(
    DateTime date,
    CSVCategory category,
  ) async {
    final isar = await isarService.db;
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    switch (category) {
      case .pnl:
        // Filter entries by this month range
        final entries = await isar
            .collection<PnLEntry>()
            .filter()
            .dateBetween(start, end)
            .findAll();
        await _saveCsv(
          _buildPnLRows(entries),
          'PAL_PnL_${date.month}_${date.year}',
        );
        break;

      case .quantified:
        // Filter goals whose deadlines fall in this month
        final goals = await isar
            .collection<QuantifiedGoal>()
            .filter()
            .deadlineBetween(start, end)
            .findAll();
        await _saveCsv(
          _buildTargetGoalRows(goals),
          'PAL_Goals_${date.month}_${date.year}',
        );
        break;

      case .monthly:
        // Only export the target for this specific month
        final target = await isar
            .collection<MonthlyGoal>()
            .filter()
            .monthEqualTo(start)
            .findFirst();
        if (target != null) {
          await _saveCsv(
            _buildMonthlyGoalRows([target]),
            'PAL_Target_${date.month}_${date.year}',
          );
        }
        break;
    }
  }

  /// Opens file picker, reads CSV, and merges data into the targeted month
  static Future<bool> importMonth(DateTime targetMonth) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: .custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      final fields = CsvParsing.parseCsv(csvString);

      if (fields.length <= 1) return false;

      Map<DateTime, PnLEntry> importedEntries = {};

      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length < 5) continue;

        try {
          final parsedDate = _dateFormat.parse(row[0].toString());

          if (parsedDate.year != targetMonth.year ||
              parsedDate.month != targetMonth.month) {
            continue;
          }

          final dateKey = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
          );
          final totalAmount = double.tryParse(row[1].toString()) ?? 0.0;
          final note = row[2].toString();
          final category = row[3].toString();
          final breakdownAmount = double.tryParse(row[4].toString()) ?? 0.0;

          if (!importedEntries.containsKey(dateKey)) {
            importedEntries[dateKey] = PnLEntry()
              ..date = dateKey
              ..amount = totalAmount
              ..note = note
              ..breakdown = [];
          }

          if (category.isNotEmpty && breakdownAmount != 0.0) {
            final item = ExpenseItem()
              ..category = category
              ..amount = breakdownAmount;

            final currentList = importedEntries[dateKey]!.breakdown!.toList();
            currentList.add(item);
            importedEntries[dateKey]!.breakdown = currentList;
          }
        } catch (e) {
          continue;
        }
      }

      final isar = await isarService.db;
      await isar.writeTxn(() async {
        for (var entry in importedEntries.values) {
          final existing = await isar
              .collection<PnLEntry>()
              .filter()
              .dateEqualTo(entry.date)
              .findFirst();

          if (existing != null) {
            entry.id = existing.id;
          }
          await isar.collection<PnLEntry>().put(entry);
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Exports the ENTIRE database to a CSV using a Native Save As Dialog
  static Future<void> exportAllPnl() async {
    final entries = await IsarService().getAllEntries();

    Dynamic2DList rows = [
      ['Date', 'Daily Total', 'Note', 'Breakdown Category', 'Breakdown Amount'],
    ];

    for (PnLEntry entry in entries) {
      final dateStr = _dateFormat.format(entry.date);

      if (entry.breakdown == null || entry.breakdown!.isEmpty) {
        rows.add([dateStr, entry.amount, entry.note ?? '', '', '']);
      } else {
        for (ExpenseItem item in entry.breakdown!) {
          rows.add([
            dateStr,
            entry.amount,
            entry.note ?? '',
            item.category ?? '',
            item.amount ?? 0.0,
          ]);
        }
      }
    }

    final String csvData = CsvParsing.listToCsv(rows);

    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save All Data Backup',
      fileName: 'PAL_Journal_Complete_Backup.csv',
      type: .custom,
      allowedExtensions: ['csv'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(csvData);
    }
  }

  /// Opens file picker, reads CSV, and merges data across ALL months
  static Future<bool> importAllPnl() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: .custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      final fields = CsvParsing.parseCsv(csvString);

      if (fields.length <= 1) return false;

      Map<DateTime, PnLEntry> importedEntries = {};

      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length < 5) continue;

        try {
          final parsedDate = _dateFormat.parse(row[0].toString());

          // NO MONTH RESTRICTION HERE! We accept all dates.
          final dateKey = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
          );

          final totalAmount = double.tryParse(row[1].toString()) ?? 0.0;
          final note = row[2].toString();
          final category = row[3].toString();
          final breakdownAmount = double.tryParse(row[4].toString()) ?? 0.0;

          if (!importedEntries.containsKey(dateKey)) {
            importedEntries[dateKey] = PnLEntry()
              ..date = dateKey
              ..amount = totalAmount
              ..note = note
              ..breakdown = [];
          }

          if (category.isNotEmpty && breakdownAmount != 0.0) {
            final item = ExpenseItem()
              ..category = category
              ..amount = breakdownAmount;
            final currentList = importedEntries[dateKey]!.breakdown!.toList();
            currentList.add(item);
            importedEntries[dateKey]!.breakdown = currentList;
          }
        } catch (e) {
          continue;
        }
      }

      final isar = await isarService.db;
      await isar.writeTxn(() async {
        for (var entry in importedEntries.values) {
          final existing = await isar
              .collection<PnLEntry>()
              .filter()
              .dateEqualTo(entry.date)
              .findFirst();

          if (existing != null) entry.id = existing.id;
          await isar.collection<PnLEntry>().put(entry);
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> exportGoalsToCSV(List<MonthlyGoal> goals) async {
    String csv = "Month,Type,Amount,Offset\n";
    for (var goal in goals) {
      csv +=
          "${goal.month.year}-"
          "${goal.month.month},"
          "${goal.type.name},"
          "${goal.amount},"
          "${goal.syncedOffset}\n";
    }
    return csv;
  }

  // --- QUANTIFIED GOALS ---
  static Future<void> exportAllTargetGoals() async {
    final quantifiedGoals = await IsarService().getAllQuantifiedGoals();

    List<List<dynamic>> rows = [
      [
        'Title',
        'Target',
        'Current',
        'Unit',
        'Deadline',
        'Pinned',
        'Completed',
        'Type',
      ],
    ];

    for (QuantifiedGoal goal in quantifiedGoals) {
      rows.add([
        goal.title,
        goal.targetValue,
        goal.currentValue,
        goal.unit,
        _dateFormat.format(goal.deadline),
        goal.isPinned ? 1 : 0,
        goal.isCompleted ? 1 : 0,
        goal.valueType.index,
      ]);
    }

    await _saveCsv(rows, 'PAL_Goals_Backup');
  }

  static Future<bool> importAllTargetGoals() async {
    final fields = await _pickAndParseCsv();
    if (fields == null || fields.length <= 1) return false;

    final isar = await isarService.db;
    await isar.writeTxn(() async {
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        final goal = QuantifiedGoal()
          ..title = row[0].toString()
          ..targetValue = double.tryParse(row[1].toString()) ?? 0.0
          ..currentValue = double.tryParse(row[2].toString()) ?? 0.0
          ..unit = row[3].toString()
          ..deadline = _dateFormat.parse(row[4].toString())
          ..isPinned = row[5].toString() == "1"
          ..isCompleted = row[6].toString() == "1"
          ..valueType =
              GoalValueType.values[int.tryParse(row[7].toString()) ?? 0];

        await isar.collection<QuantifiedGoal>().put(goal);
      }
    });
    return true;
  }

  // --- MONTHLY GOALS ---
  static Future<void> exportAllMonthlyGoals() async {
    final monthlyGoals = await IsarService().getAllGoals();

    List<List<dynamic>> rows = [
      ['Month', 'Type', 'Amount', 'Offset'],
    ];

    for (MonthlyGoal goal in monthlyGoals) {
      rows.add([
        _dateFormat.format(goal.month),
        goal.type.index,
        goal.amount,
        goal.syncedOffset,
      ]);
    }
    await _saveCsv(rows, 'PAL_Monthly_Targets');
  }

  static Future<bool> importAllMonthlyGoals() async {
    try {
      final fields = await _pickAndParseCsv();
      if (fields == null || fields.length <= 1) return false;

      final isar = await isarService.db;
      await isar.writeTxn(() async {
        for (int i = 1; i < fields.length; i++) {
          final row = fields[i];
          if (row.length < 3) continue;

          final monthDate = _dateFormat.parse(row[0].toString());

          // Check if a goal already exists for this specific month
          final existing = await isar
              .collection<MonthlyGoal>()
              .filter()
              .monthEqualTo(monthDate)
              .findFirst();

          final goal = existing ?? MonthlyGoal();
          goal
            ..month = monthDate
            ..type = GoalType.values[int.tryParse(row[1].toString()) ?? 0]
            ..amount = double.tryParse(row[2].toString()) ?? 0.0
            ..syncedOffset = double.tryParse(row[3].toString()) ?? 0.0;

          await isar.collection<MonthlyGoal>().put(goal);
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- PRIVATE HELPERS ---
  static Future<void> _saveCsv(
    List<List<dynamic>> rows,
    String fileName,
  ) async {
    final csvData = CsvParsing.listToCsv(rows);
    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save CSV Data',
      fileName: '$fileName.csv',
      type: .custom,
      allowedExtensions: ['csv'],
    );
    if (outputFile != null) await File(outputFile).writeAsString(csvData);
  }

  static Future<Dynamic2DList?> _pickAndParseCsv() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: .custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return null;
    final csvString = await File(result.files.single.path!).readAsString();
    return CsvParsing.parseCsv(csvString);
  }

  // --- ROW BUILDERS ---

  static Dynamic2DList _buildPnLRows(List<PnLEntry> entries) {
    Dynamic2DList rows = [
      ['Date', 'Daily Total', 'Note', 'Breakdown Category', 'Breakdown Amount'],
    ];

    for (var entry in entries) {
      final dateStr = _dateFormat.format(entry.date);
      if (entry.breakdown == null || entry.breakdown!.isEmpty) {
        rows.add([dateStr, entry.amount, entry.note ?? '', '', '']);
      } else {
        for (var item in entry.breakdown!) {
          rows.add([
            dateStr,
            entry.amount,
            entry.note ?? '',
            item.category ?? '',
            item.amount ?? 0.0,
          ]);
        }
      }
    }
    return rows;
  }

  static Dynamic2DList _buildTargetGoalRows(List<QuantifiedGoal> goals) {
    Dynamic2DList rows = [
      [
        'Title',
        'Target',
        'Current',
        'Unit',
        'Deadline',
        'Pinned',
        'Completed',
        'Type',
      ],
    ];

    for (var goal in goals) {
      rows.add([
        goal.title,
        goal.targetValue,
        goal.currentValue,
        goal.unit,
        _dateFormat.format(goal.deadline),
        goal.isPinned ? 1 : 0,
        goal.isCompleted ? 1 : 0,
        goal.valueType.index, // Save enum as index for easier parsing
      ]);
    }
    return rows;
  }

  static Dynamic2DList _buildMonthlyGoalRows(List<MonthlyGoal> targets) {
    Dynamic2DList rows = [
      ['Month', 'Type', 'Amount', 'Offset'],
    ];

    for (var target in targets) {
      rows.add([
        _dateFormat.format(target.month),
        target.type.index, // Logic for Profit Target vs Budget
        target.amount,
        target.syncedOffset,
      ]);
    }
    return rows;
  }
}
