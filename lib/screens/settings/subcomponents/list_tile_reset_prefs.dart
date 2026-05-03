import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListTileResetPreferences extends StatelessWidget {
  const ListTileResetPreferences({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(16)),
      ),
      leading: Icon(Icons.restore, color: colors.error),
      title: const Text("Reset Preferences"),
      subtitle: const Text(
        "Restore default tags and settings",
        style: TextStyle(fontSize: 12),
      ),
      onTap: () => _resetPrefs(context),
    );
  }

  void _resetPrefs(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return confirmationDialog(colors, context);
      },
    );

    if (confirm == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preferences reset to default.")),
      );
    }
  }

  AlertDialog confirmationDialog(ColorScheme colors, BuildContext context) {
    return AlertDialog(
      title: Text("Reset Preferences?", style: TextStyle(color: colors.error)),
      content: const Text(
        "This will reset your custom tags, monthly goals, "
        "and UI settings back to default.\n\n"
        "Your financial ledger will NOT be deleted.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            "Reset",
            style: TextStyle(color: colors.error, fontWeight: .bold),
          ),
        ),
      ],
    );
  }
}
