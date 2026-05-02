import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/auth_service.dart';

class SyncService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- BACKUP TO CLOUD ---
  /// Takes the entire Isar database and pushes it to Firestore.
  static Future<String?> backupToCloud(List<PnLEntry> localEntries) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return "Error: Not logged in.";

      // Route: users / {unique_user_id} / ledger
      final ledgerRef = _db
          .collection('users')
          .doc(userId)
          .collection('ledger');

      WriteBatch batch = _db.batch();
      int operationCount = 0;

      for (var entry in localEntries) {
        // We use the exact ISO8601 string as the Document ID.
        // This guarantees uniqueness and makes it natively sortable in the cloud!
        final docId = entry.date.toIso8601String();

        batch.set(ledgerRef.doc(docId), entry.toMap());
        operationCount++;

        // Firestore batches have a hard limit of 500 operations.
        // If we hit 500, we commit the batch, and start a fresh one.
        if (operationCount == 500) {
          await batch.commit();
          batch = _db.batch();
          operationCount = 0;
        }
      }

      // Commit any remaining entries
      if (operationCount > 0) {
        await batch.commit();
      }

      return null; // Success!
    } catch (e) {
      return "Cloud backup failed: $e";
    }
  }

  // --- PULL FROM CLOUD ---
  /// Downloads all cloud data so your IsarService can save it locally
  static Future<List<PnLEntry>?> restoreFromCloud() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return null;

      final snapshot = await _db
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
