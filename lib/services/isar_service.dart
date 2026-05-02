import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pal_journal/models/pnl_entry.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  late Future<Isar> db;

  factory IsarService() => _instance;

  IsarService._internal() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open([PnLEntrySchema], directory: dir.path);
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

  /// Deletes a PnL entry for a specific date.
  Future<void> deletePnLForDate(DateTime date) async {
    final isar = await db;

    // The exact first microsecond of the selected day
    final startOfDay = DateTime(date.year, date.month, date.day);

    // Go to the NEXT day, and subtract to perfectly capture 23:59:59.999
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day + 1,
    ).subtract(const Duration(microseconds: 1));

    await isar.writeTxn(() async {
      // Find the entry that falls anywhere within this 24-hour window
      final entryToDelete = await isar
          .collection<PnLEntry>()
          .filter()
          .dateBetween(startOfDay, endOfDay)
          .findFirst();

      // If we caught it, delete it by its exact ID
      if (entryToDelete == null) return;
      await isar.collection<PnLEntry>().delete(entryToDelete.id);
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

  /// Wipes local data and replaces it with fresh Cloud data.
  Future<void> replaceAllEntries(List<PnLEntry> cloudEntries) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.pnLEntrys.clear();
      await isar.pnLEntrys.putAll(cloudEntries);
    });
  }

  /// Fetches every entry in the local database for cloud backup.
  Future<List<PnLEntry>> getAllEntries() async {
    final isar = await db;
    return await isar.pnLEntrys.where().findAll();
  }
}
