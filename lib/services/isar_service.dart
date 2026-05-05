import 'package:isar/isar.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/models/quantified_goal.dart';
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
      return await Isar.open([
        PnLEntrySchema,
        MonthlyGoalSchema,
        QuantifiedGoalSchema,
      ], directory: dir.path);
    }
    return Future.value(Isar.getInstance());
  }

  // --- PNL ENTRIES ---

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
      await isar.collection<PnLEntry>().clear();
      await isar.collection<PnLEntry>().putAll(cloudEntries);
    });
  }

  /// Fetches every entry in the local database for cloud backup.
  Future<List<PnLEntry>> getAllEntries() async {
    final isar = await db;
    return await isar.collection<PnLEntry>().where().findAll();
  }

  // --- MONTHLY GOALS ---

  /// Saves or updates a goal for a specific month.
  Future<void> saveGoal(MonthlyGoal goal) async {
    final isar = await db;
    // Ensure the date is always the 1st of the month at UTC for consistency
    goal.month = DateTime.utc(goal.month.year, goal.month.month, 1);

    await isar.writeTxn(() async {
      await isar.collection<MonthlyGoal>().put(goal);
    });
  }

  /// Retrieves the goal for a specific month.
  Future<MonthlyGoal?> getGoal(DateTime month) async {
    final isar = await db;
    final normalized = DateTime.utc(month.year, month.month, 1);
    return await isar
        .collection<MonthlyGoal>()
        .filter()
        .monthEqualTo(normalized)
        .findFirst();
  }

  /// Clears the goal for a specific month.
  Future<void> clearGoal(DateTime month) async {
    final isar = await db;
    // Always normalize to the 1st of the month at UTC to match the index
    final normalized = DateTime.utc(month.year, month.month, 1);

    await isar.writeTxn(() async {
      await isar
          .collection<MonthlyGoal>()
          .filter()
          .monthEqualTo(normalized)
          .deleteFirst(); // Removes the single entry matching that month
    });
  }

  /// Fetches all goals for global CSV export or Cloud Sync.
  Future<List<MonthlyGoal>> getAllGoals() async {
    final isar = await db;
    return await isar.collection<MonthlyGoal>().where().findAll();
  }

  /// Bulk import goals from CSV/Cloud.
  Future<void> replaceAllGoals(List<MonthlyGoal> goals) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.collection<MonthlyGoal>().clear();
      await isar.collection<MonthlyGoal>().putAll(goals);
    });
  }

  // --- QUANTIFIED GOALS ---

  /// Saves or updates a quantized goal.
  Future<void> saveQuantifiedGoal(QuantifiedGoal goal) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.quantifiedGoals.put(goal);
    });
  }

  /// Retrieves all pinned quantized goals.
  Future<List<QuantifiedGoal>> getPinnedGoals() async {
    final isar = await db;
    return await isar.quantifiedGoals.filter().isPinnedEqualTo(true).findAll();
  }

  Future<void> replaceAllQuantifiedGoals(List<QuantifiedGoal> goals) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.collection<QuantifiedGoal>().clear();
      await isar.collection<QuantifiedGoal>().putAll(goals);
    });
  }

  Future<List<QuantifiedGoal>> getAllQuantifiedGoals() async {
    final isar = await db;
    return await isar.collection<QuantifiedGoal>().where().findAll();
  }

  Future<void> deleteQuantifiedGoal(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.quantifiedGoals.delete(id);
    });
  }
}
