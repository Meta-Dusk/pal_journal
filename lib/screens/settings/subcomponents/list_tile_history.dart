import 'package:flutter/material.dart';
import 'package:pal_journal/screens/settings/inventory_log_view.dart';

class ListTileHistory extends StatelessWidget {
  const ListTileHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: const Text("Inventory Log"),
      subtitle: const Text("View your completed wealth milestones"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InventoryLogView()),
      ),
    );
  }
}
