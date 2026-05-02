import 'package:flutter/material.dart';
import 'package:pal_journal/services/auth_service.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/services/sync_service.dart';

class CloudSyncCard extends StatefulWidget {
  const CloudSyncCard({super.key});

  @override
  State<CloudSyncCard> createState() => _CloudSyncCardState();
}

class _CloudSyncCardState extends State<CloudSyncCard> {
  bool _isLoading = false;

  // --- BACKUP LOGIC ---
  Future<void> _handleBackup() async {
    setState(() => _isLoading = true);

    try {
      final entries = await IsarService().getAllEntries();

      if (entries.isEmpty) {
        _showMessage("Nothing to backup. Your local ledger is empty.");
        return;
      }

      // Push to Firestore
      final error = await SyncService.backupToCloud(entries);

      if (!mounted) return;

      if (error == null) {
        _showMessage(
          "Successfully backed up ${entries.length} entries to the cloud!",
          isError: false,
        );
      } else {
        _showMessage(error, isError: true);
      }
    } catch (e) {
      if (mounted) _showMessage("Backup failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- RESTORE LOGIC ---
  Future<void> _handleRestore() async {
    final confirmed = await _confirmRestore();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final cloudEntries = await SyncService.restoreFromCloud();

      if (!mounted) return;

      if (cloudEntries == null || cloudEntries.isEmpty) {
        _showMessage("No cloud data found to restore.");
        return;
      }

      await IsarService().replaceAllEntries(cloudEntries);

      if (mounted) {
        _showMessage(
          "Successfully restored ${cloudEntries.length} entries from the cloud!",
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) _showMessage("Restore failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : colors.primary,
        behavior: .floating,
      ),
    );
  }

  Future<bool> _confirmRestore() async {
    final showConfirmDialog = showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(),
    );
    return await showConfirmDialog ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder(
      valueListenable: AuthService.currentUserNotifier,
      builder: (context, user, _) {
        if (user == null) return const SizedBox.shrink();

        final actionButtons = [
          FilledButton.icon(
            onPressed: _handleBackup,
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text(
              "Backup to Cloud",
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _handleRestore,
            icon: const Icon(Icons.cloud_download_rounded),
            label: const Text(
              "Restore from Cloud",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ];

        final mainContent = [
          contentLabel(colors),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ...actionButtons,
        ];

        return Padding(
          padding: const .all(16.0),
          child: Column(crossAxisAlignment: .stretch, children: mainContent),
        );
      },
    );
  }

  Row contentLabel(ColorScheme colors) {
    return Row(
      children: [
        Icon(Icons.cloud_sync, color: colors.primary),
        const SizedBox(width: 12),
        Text(
          "Data Synchronization",
          style: TextStyle(
            fontSize: 18,
            fontWeight: .bold,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final dialogActions = [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text("Cancel"),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        style: FilledButton.styleFrom(
          backgroundColor: colors.error,
          foregroundColor: colors.onError,
        ),
        child: const Text("Restore"),
      ),
    ];

    return AlertDialog(
      title: const Text("Restore from Cloud?"),
      content: const Text(
        "This will delete all current entries on this device and replace them "
        "with your cloud backup. This action cannot be undone.",
      ),
      actions: dialogActions,
    );
  }
}
