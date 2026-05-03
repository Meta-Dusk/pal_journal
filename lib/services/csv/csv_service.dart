import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import 'package:pal_journal/main.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import './csv_parsing.dart';

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
  static Future<void> exportAll() async {
    final isar = await isarService.db;

    // Fetch absolutely everything, sorted by date
    final entries = await isar
        .collection<PnLEntry>()
        .where()
        .sortByDate()
        .findAll();

    List<List<dynamic>> rows = [
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
  static Future<bool> importAll() async {
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
}
