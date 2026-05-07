import 'dart:io' show Platform;
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
  String _lastSyncDate = "";

  @override
  void initState() {
    super.initState();
    _loadInitialSyncDate();
  }

  Future<void> _loadInitialSyncDate() async {
    final date = await SyncService.getLastSyncDisplay();
    if (mounted) setState(() => _lastSyncDate = date);
  }

  /// Make sure to cancel all FireBase operations on Windows.
  bool _windowsWarningCheck() {
    if (Platform.isWindows) {
      _showMessage(
        "Data syncing is temporarily disabled on Windows due to an SDK bug."
        "Use the tools for CSV instead.",
        isError: true,
      );
      return true;
    }
    return false;
  }

  // --- BACKUP LOGIC ---
  Future<void> _handleBackup() async {
    if (_windowsWarningCheck()) return;

    setState(() => _isLoading = true);

    try {
      final isar = IsarService();

      // Fetch for all categories
      final pnlEntries = await isar.getAllEntries();
      final quantifiedGoals = await isar.getAllQuantifiedGoals();
      final monthlyGoals = await isar.getAllGoals();

      if (pnlEntries.isEmpty &&
          quantifiedGoals.isEmpty &&
          monthlyGoals.isEmpty) {
        _showMessage("Nothing to backup. All local categories are empty.");
        return;
      }

      final totalItems =
          pnlEntries.length + quantifiedGoals.length + monthlyGoals.length;

      // Push to Firestore
      final error = await SyncService.backupAllDataToCloud();
      await SyncService.updateLastSyncTimestamp();
      final newDate = await SyncService.getLastSyncDisplay();

      if (!mounted) return;

      if (error == null) {
        setState(() => _lastSyncDate = newDate);
        _showMessage(
          "Successfully backed up $totalItems entries to the cloud!",
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
    if (_windowsWarningCheck()) return;

    final confirmed = await _confirmRestore();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final cloudData = await SyncService.restoreAllDataFromCloud();

      if (cloudData == null || cloudData.isEmpty) {
        _showMessage("No cloud data found to restore.");
        return;
      }

      final totalItems =
          (cloudData[CloudData.pnl]?.length ?? 0) +
          (cloudData[CloudData.quantified]?.length ?? 0) +
          (cloudData[CloudData.monthly]?.length ?? 0);

      await IsarService().performFullRestore(cloudData);

      if (!mounted) return;
      _showMessage(
        "Successfully restored $totalItems entries from the cloud!",
        isError: false,
      );
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
      builder: (_, user, _) {
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
          _contentLabel(colors),
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

  Row _contentLabel(ColorScheme colors) {
    final leadingContent = [
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
    ];

    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Row(children: leadingContent),
        const SizedBox(width: 12),
        Text(
          _lastSyncDate,
          style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
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
