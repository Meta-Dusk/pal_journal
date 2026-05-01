import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<bool?> showMonthSettingsDialog(BuildContext context, DateTime month) {
  final monthName = DateFormat('MMMM yyyy').format(month);

  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: .vertical(top: .circular(20)),
    ),
    builder: (context) => Padding(
      padding: const .all(24.0),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            "$monthName Settings",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: .bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Placeholder for future Goal feature
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.tealAccent),
            title: const Text(
              "Set Monthly Goal",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Coming soon...",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            onTap: () {}, // Do nothing for now
          ),

          // Placeholder for future CSV export
          ListTile(
            leading: const Icon(Icons.download, color: Colors.blueAccent),
            title: const Text(
              "Export to CSV",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Coming soon...",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            onTap: () {},
          ),

          const Divider(color: Colors.white24, height: 32),

          // The active Clear Data button
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text(
              "Reset Month Data",
              style: TextStyle(color: Colors.redAccent, fontWeight: .bold),
            ),
            subtitle: const Text(
              "Delete all entries for this month",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            onTap: () async {
              // Show confirmation dialog
              final confirm = await confirmationDialog(context, monthName);

              // If confirmed, close the bottom sheet and return true to the calendar
              if (confirm == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Future<bool?> confirmationDialog(BuildContext context, String monthName) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Are you sure?", style: TextStyle(color: Colors.white)),
      content: Text(
        "This will permanently delete all logged data for $monthName.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            "Delete All",
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}
