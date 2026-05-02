import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'subcomponents/list_tiles.dart';

Future<bool?> showMonthSettingsDialog(BuildContext context, DateTime month) {
  final monthName = DateFormat('MMMM yyyy').format(month);

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: .vertical(top: .circular(20)),
    ),
    builder: (context) {
      final labelText = Text(
        "$monthName Settings",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: .bold,
          color: Colors.white,
        ),
      );

      final mainContent = [
        labelText,
        const SizedBox(height: 24),
        ListTileSetGoal(month: month),
        ListTileExportCSV(month: month),
        ListTileImportCSV(month: month),
        const Divider(color: Colors.white24, height: 32),
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
