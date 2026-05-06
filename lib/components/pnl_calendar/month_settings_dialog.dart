import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../csv_tool_card.dart';
import 'subcomponents/list_tiles.dart';

Future<bool?> showMonthSettingsDialog(BuildContext context, DateTime month) {
  final colors = Theme.of(context).colorScheme;
  final monthName = DateFormat('MMMM yyyy').format(month);

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: .vertical(top: .circular(20)),
    ),
    builder: (context) {
      final labelText = Text(
        "$monthName Settings",
        style: TextStyle(
          fontSize: 20,
          fontWeight: .bold,
          color: colors.onSurface,
        ),
      );

      final mainContent = [
        labelText,
        const SizedBox(height: 24),
        ListTileSetGoal(month: month),
        Divider(color: colors.onSurface, height: 32),
        Align(
          alignment: .center,
          child: Text(
            "CSV Data Tools",
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurfaceVariant,
              fontWeight: .bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const CSVToolCard(),
        Divider(color: colors.onSurface, height: 32),
        ListTileClearData(month: month, monthName: monthName),
        const SizedBox(height: 16),
      ];

      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const .all(24.0),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: mainContent,
            ),
          ),
        ),
      );
    },
  );
}
