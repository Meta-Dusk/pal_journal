import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/models/quantified_goal.dart';
import 'auth_service.dart';
import 'isar_service.dart';

enum CloudData { pnl, monthly, quantified }

typedef CloudDataMap = Map<CloudData, List<dynamic>>;

class CloudCollection {
  static const String users = "users";
  static const String monthlyGoals = "monthly_goals";
  static const String quantifiedGoals = "quantified_goals";
  static const String ledger = "ledger";
}

class SyncService {
  //* --- BACKUP TO CLOUD ---
  /// Takes the entire Isar database and pushes it to Firestore.
  static Future<String?> backupAllDataToCloud() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return "Login required.";

      final isar = IsarService();
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      final pnlEntries = await isar.getAllEntries();
      final quantifiedGoals = await isar.getAllQuantifiedGoals();
      final monthlyGoals = await isar.getAllGoals();

      for (PnLEntry entry in pnlEntries) {
        final ref = db
            .collection(CloudCollection.users)
            .doc(userId)
            .collection(CloudCollection.ledger)
            .doc(entry.date.toIso8601String());
        batch.set(ref, entry.toMap());
      }

      for (QuantifiedGoal goal in quantifiedGoals) {
        final ref = db
            .collection(CloudCollection.users)
            .doc(userId)
            .collection(CloudCollection.quantifiedGoals)
            .doc(goal.id.toString());
        batch.set(ref, goal.toMap());
      }

      for (MonthlyGoal goal in monthlyGoals) {
        // Use the month's ISO string as the ID to avoid duplicates per month
        final docId = goal.month.toIso8601String();
        final ref = db
            .collection(CloudCollection.users)
            .doc(userId)
            .collection(CloudCollection.monthlyGoals)
            .doc(docId);
        batch.set(ref, goal.toMap());
      }

      await batch.commit(); // Commit in chunks if counts exceed 500
      return null;
    } catch (e) {
      return "Backup failed: $e";
    }
  }

  //* --- PULL FROM CLOUD ---
  /// Downloads all cloud data so IsarService can save it locally.
  static Future<CloudDataMap?> restoreAllDataFromCloud() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return null;

      final db = FirebaseFirestore.instance;
      final userDoc = db.collection(CloudCollection.users).doc(userId);

      // Pull PnL Ledger
      final ledgerSnapshot = await userDoc
          .collection(CloudCollection.ledger)
          .get();
      final pnlEntries = ledgerSnapshot.docs
          .map((doc) => PnLEntry.fromMap(doc.data()))
          .toList();

      // Pull Quantified Goals
      final goalsSnapshot = await userDoc
          .collection(CloudCollection.quantifiedGoals)
          .get();
      final quantifiedGoals = goalsSnapshot.docs
          .map((doc) => QuantifiedGoal.fromMap(doc.data()))
          .toList();

      // Pull Monthly Targets
      final monthlySnapshot = await userDoc
          .collection(CloudCollection.monthlyGoals)
          .get();
      final monthlyGoals = monthlySnapshot.docs
          .map((doc) => MonthlyGoal.fromMap(doc.data()))
          .toList();

      return {
        .pnl: pnlEntries,
        .quantified: quantifiedGoals,
        .monthly: monthlyGoals,
      };
    } catch (e) {
      debugPrint("Restore Error: $e");
      return null;
    }
  }

  //* --- OTHER METHODS ---
  static const String _syncKey = "last_synced_timestamp";

  static Future<void> updateLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_syncKey, DateTime.now().toIso8601String());
  }

  static Future<String> getLastSyncDisplay() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_syncKey);
    if (timestamp == null) return "Never";

    final date = DateTime.parse(timestamp);
    return DateFormat('MMM d, h:mm a').format(date); // e.g., May 6, 10:38 PM
  }
}
