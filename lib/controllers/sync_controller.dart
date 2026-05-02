import 'package:flutter/material.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/services/sync_service.dart';

class SyncController {
  static Future<void> runBackup(BuildContext context) async {
    // 1. Show a loading indicator if needed
    // 2. Fetch from Isar[cite: 2]
    final entries = await IsarService().getAllEntries();

    // 3. Push to Cloud[cite: 7]
    final error = await SyncService.backupToCloud(entries);

    // 4. Handle UI feedback
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? "Sync Successful")));
  }
}
