import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pal_journal/models/pnl_entry.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    // Check if an instance is already open to avoid errors
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [PnLEntrySchema], // This comes from your generated file
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  /// Saves a new daily PnL entry.
  Future<void> savePnL(
    DateTime date,
    double amount, {
    String? note,
    List<ExpenseItem>? breakdown,
  }) async {
    final isar = await db;
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);

    await isar.writeTxn(() async {
      // Find if an entry already exists for this day
      final existingEntry = await isar
          .collection<PnLEntry>()
          .filter()
          .dateEqualTo(normalizedDate)
          .findFirst();

      // Update the existing entry, or create a new one if it's null
      final entryToSave = existingEntry ?? PnLEntry()
        ..date = normalizedDate;

      entryToSave.amount = amount;
      entryToSave.note = note;
      entryToSave.breakdown = breakdown;

      await isar.collection<PnLEntry>().put(entryToSave);
    });
  }

  /// Method to reset/delete data for a specific day
  Future<void> deletePnLForDate(DateTime date) async {
    final isar = await db;
    final normalizedDate = DateTime.utc(date.year, date.month, date.day);

    await isar.writeTxn(() async {
      await isar
          .collection<PnLEntry>()
          .filter()
          .dateEqualTo(normalizedDate)
          .deleteAll();
    });
  }

  /// Bulk delete an entire month
  Future<void> deletePnLForMonth(DateTime month) async {
    final isar = await db;

    // Find the exact start and end moments of the given month
    final startOfMonth = DateTime.utc(month.year, month.month, 1);
    // Setting day to 0 of the NEXT month gives you the last day of THIS month
    final endOfMonth = DateTime.utc(month.year, month.month + 1, 0);

    await isar.writeTxn(() async {
      await isar
          .collection<PnLEntry>()
          .filter()
          .dateBetween(startOfMonth, endOfMonth)
          .deleteAll();
    });
  }

  /// Get total lifetime PnL
  Future<double> getLifetimePnL() async {
    final isar = await db;
    final entries = await isar.collection<PnLEntry>().where().findAll();
    // Fold is a quick way to sum up a list of objects in Dart
    return entries.fold(0.0, (sum, item) async => await sum + item.amount);
  }
}
