import 'package:flutter/material.dart';

Future<bool?> confirmationDialog(BuildContext context, String monthName) {
  final colors = Theme.of(context).colorScheme;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Are you sure?",
        textAlign: .center,
        style: TextStyle(color: colors.error),
      ),
      content: Text(
        "This will permanently delete all logged data for $monthName.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text("Delete All", style: TextStyle(color: colors.error)),
        ),
      ],
    ),
  );
}
