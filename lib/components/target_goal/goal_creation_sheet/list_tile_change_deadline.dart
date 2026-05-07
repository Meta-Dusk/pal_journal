import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListTileChangeDeadline extends StatelessWidget {
  const ListTileChangeDeadline({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  final DateTime selectedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: .zero,
      leading: const Icon(Icons.calendar_today),
      title: Text("Deadline: ${DateFormat('yMMMd').format(selectedDate)}"),
      trailing: Text("Change", style: TextStyle(color: colors.primary)),
      onTap: onTap,
    );
  }
}
