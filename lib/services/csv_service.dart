import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import 'package:pal_journal/main.dart';
import 'package:pal_journal/models/pnl_entry.dart';

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

    final String csvData = _listToCsv(rows);
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
      final fields = _parseCsv(csvString);

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

  // --- NATIVE CSV LOGIC ---

  /// Converts a List of Lists into a valid CSV String, handling commas inside text.
  static String _listToCsv(List<List<dynamic>> rows) {
    StringBuffer sb = StringBuffer();
    for (var row in rows) {
      List<String> formattedCells = [];
      for (var cell in row) {
        String str = cell.toString();
        // If the user's note contains a comma, newline, or quote, we must wrap it in quotes
        if (str.contains(',') || str.contains('\n') || str.contains('"')) {
          str = '"${str.replaceAll('"', '""')}"';
        }
        formattedCells.add(str);
      }
      sb.writeln(formattedCells.join(','));
    }
    return sb.toString();
  }

  /// Parses a CSV string into a List of Lists, correctly ignoring commas inside quotes.
  static List<List<String>> _parseCsv(String csvString) {
    List<List<String>> rows = [];
    List<String> currentRow = [];
    StringBuffer currentCell = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < csvString.length; i++) {
      String char = csvString[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < csvString.length && csvString[i + 1] == '"') {
            currentCell.write('"'); // Escaped quote inside text
            i++;
          } else {
            inQuotes = false; // End of quoted text
          }
        } else {
          currentCell.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          currentRow.add(currentCell.toString());
          currentCell.clear();
        } else if (char == '\n' || char == '\r') {
          if (char == '\r' &&
              i + 1 < csvString.length &&
              csvString[i + 1] == '\n') {
            i++; // Skip standard Windows \r\n
          }
          currentRow.add(currentCell.toString());
          rows.add(currentRow);
          currentRow = [];
          currentCell.clear();
        } else {
          currentCell.write(char);
        }
      }
    }

    // Add the final cell/row if the file doesn't end with a newline
    if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentCell.toString());
      rows.add(currentRow);
    }

    return rows;
  }
}
