import 'package:flutter/material.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/services/sync_service.dart';

class SyncController {
  static Future<void> runBackup(BuildContext context) async {
    final entries = await IsarService().getAllEntries();
    final error = await SyncService.backupToCloud(entries);

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? "Sync Successful")));
  }
}
