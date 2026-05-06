import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import 'package:pal_journal/components/csv_tool_card.dart';
import 'package:pal_journal/core/data_types.dart';
import 'package:pal_journal/main.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/models/quantified_goal.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'row_builders.dart';
import 'csv_parsing.dart';

class CsvService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final String _fileNamePrefix = 'PAL_Journal_';

  /// Exports the currently viewed month to a CSV using a Native Save As Dialog
  static Future<void> exportMonth(DateTime date) async {
    final isar = await isarService.db;

    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

    final entries = await isar
        .collection<PnLEntry>()
        .filter()
        .dateBetween(startOfMonth, endOfMonth)
        .sortByDate()
        .findAll();

    final rows = RowBuilders.pnLRows(entries);
    final String monthName = DateFormat('MMM_yyyy').format(date);
    _saveCsv(rows, "$_fileNamePrefix$monthName");
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
        final month = date.month.toString().padLeft(2, '0');
        await _saveCsv(
          RowBuilders.pnLRows(entries),
          '${_fileNamePrefix}PnL_${month}_${date.year}',
        );
        break;

      case .quantified:
        // Filter goals whose deadlines fall in this month
        final goals = await isar
            .collection<QuantifiedGoal>()
            .filter()
            .deadlineBetween(start, end)
            .findAll();
        final month = date.month.toString().padLeft(2, '0');
        await _saveCsv(
          RowBuilders.targetGoalRows(goals),
          '${_fileNamePrefix}Target_Goals_${month}_${date.year}',
        );
        break;

      case .monthly:
        // Only export the target for this specific month
        final target = await isar
            .collection<MonthlyGoal>()
            .filter()
            .monthEqualTo(start)
            .findFirst();
        if (target == null) break;
        final month = date.month.toString().padLeft(2, '0');
        await _saveCsv(
          RowBuilders.monthlyGoalRows([target]),
          '${_fileNamePrefix}Monthly_Goals_${month}_${date.year}',
        );
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

            final currentList =
                importedEntries[dateKey]!.breakdown?.toList() ?? [];
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
    final rows = RowBuilders.pnLRows(entries);
    final String csvData = CsvParsing.listToCsv(rows);

    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save All Data Backup',
      fileName: '${_fileNamePrefix}Complete_PnL_Backup.csv',
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
            final currentList =
                importedEntries[dateKey]!.breakdown?.toList() ?? [];
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

  // --- QUANTIFIED GOALS ---
  static Future<void> exportAllTargetGoals() async {
    final quantifiedGoals = await IsarService().getAllQuantifiedGoals();
    final rows = RowBuilders.targetGoalRows(quantifiedGoals);
    await _saveCsv(rows, '${_fileNamePrefix}Complete_Target_Goals_Backup');
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
          ..isCompleted = row[6].toString() == "1";

        if (row.length >= 8) {
          goal.valueType =
              GoalValueType.values[int.tryParse(row[7].toString()) ?? 0];
        }

        await isar.collection<QuantifiedGoal>().put(goal);
      }
    });
    return true;
  }

  // --- MONTHLY GOALS ---
  static Future<void> exportAllMonthlyGoals() async {
    final monthlyGoals = await IsarService().getAllGoals();
    final rows = RowBuilders.monthlyGoalRows(monthlyGoals);
    await _saveCsv(rows, '${_fileNamePrefix}Complete_Monthly_Goals');
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

          final rawDate = _dateFormat.parse(row[0].toString());
          final monthDate = DateTime.utc(rawDate.year, rawDate.month, 1);

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
  static Future<void> _saveCsv(Dynamic2DList rows, String fileName) async {
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
      dialogTitle: 'Load CSV Data',
      type: .custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return null;
    final csvString = await File(result.files.single.path!).readAsString();
    return CsvParsing.parseCsv(csvString);
  }
}
