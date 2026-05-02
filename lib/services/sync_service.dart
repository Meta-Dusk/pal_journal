import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/auth_service.dart';

class SyncService {
  // --- BACKUP TO CLOUD ---
  /// Takes the entire Isar database and pushes it to Firestore.
  static Future<String?> backupToCloud(List<PnLEntry> localEntries) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return "Error: Not logged in.";

      final db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();
      int operationCount = 0;

      for (var entry in localEntries) {
        final docId = entry.date.toIso8601String();
        final ledgerRef = db
            .collection('users')
            .doc(userId)
            .collection('ledger')
            .doc(docId);

        // Convert entry to map and ensure NO nested objects are missed
        batch.set(ledgerRef, entry.toMap());
        operationCount++;

        if (operationCount == 100) {
          // Smaller chunks for Windows stability
          await batch.commit();
          batch = db.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) await batch.commit();
      return null;
    } catch (e) {
      debugPrint("Native Sync Error: $e");
      return "Cloud backup failed: $e";
    }
  }

  // --- PULL FROM CLOUD ---
  /// Downloads all cloud data so your IsarService can save it locally
  static Future<List<PnLEntry>?> restoreFromCloud() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return null;

      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection('users')
          .doc(userId)
          .collection('ledger')
          .get();

      List<PnLEntry> cloudEntries = [];

      for (var doc in snapshot.docs) {
        cloudEntries.add(PnLEntry.fromMap(doc.data()));
      }

      return cloudEntries;
    } catch (e) {
      // Log this error soon
      return null;
    }
  }
}
