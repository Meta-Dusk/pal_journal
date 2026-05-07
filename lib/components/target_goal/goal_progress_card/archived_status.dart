import 'package:flutter/material.dart';

class ArchivedStatus extends StatelessWidget {
  const ArchivedStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const .symmetric(vertical: 8),
        child: Text(
          "Archived in Inventory Log",
          style: TextStyle(
            color: colors.primary,
            fontSize: 12,
            fontWeight: .bold,
          ),
        ),
      ),
    );
  }
}
