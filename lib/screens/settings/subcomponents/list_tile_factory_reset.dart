// --- TIER 2: HARD RESET ---
import 'package:flutter/material.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pal_journal/main.dart';

class ListTileFactoryReset extends StatelessWidget {
  const ListTileFactoryReset({super.key});

  void _factoryReset(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    final controller = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Strict lock!
            final isUnlocked = controller.text == "DELETE";

            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: colors.error),
                  const SizedBox(width: 8),
                  Text("Erase All Data", style: TextStyle(color: colors.error)),
                ],
              ),
              content: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  const Text(
                    "This will permanently delete your entire financial ledger "
                    "AND reset all preferences. "
                    "This action CANNOT be undone.\n\n"
                    "Type DELETE to confirm.",
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (value) => setDialogState(
                      () {},
                    ), // Updates the button state instantly
                    decoration: InputDecoration(
                      hintText: "DELETE",
                      filled: true,
                      fillColor: colors.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: .circular(8),
                        borderSide: .none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
                ElevatedButton(
                  onPressed: isUnlocked
                      ? () => Navigator.pop(context, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                    disabledBackgroundColor: colors.surfaceContainerHighest,
                  ),
                  child: const Text(
                    "Erase Everything",
                    style: TextStyle(fontWeight: .bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true && context.mounted) {
      // 1. Purge SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // 2. Purge Isar Database
      final isar = await isarService.db;
      await isar.writeTxn(() async {
        await isar.collection<PnLEntry>().clear();
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "All data has been permanently erased.",
            style: TextStyle(color: colors.onError),
            textAlign: .center,
          ),
          backgroundColor: colors.error,
        ),
      );

      // Pop back to the root (Home Screen) so the calendar completely refreshes
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(bottom: .circular(16)),
      ),
      leading: Icon(Icons.delete_forever, color: colors.error),
      title: Text(
        "Factory Reset",
        style: TextStyle(fontWeight: .bold, color: colors.error),
      ),
      subtitle: const Text(
        "Permanently delete ledger and settings",
        style: TextStyle(fontSize: 12),
      ),
      onTap: () => _factoryReset(context),
    );
  }
}
