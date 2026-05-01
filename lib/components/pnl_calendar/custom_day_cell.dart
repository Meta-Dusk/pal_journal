import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/models/pnl_entry.dart';

class CustomDayCell extends StatelessWidget {
  final DateTime day;
  final PnLEntry? entry;
  final bool isToday;
  final bool isSelected;

  const CustomDayCell({
    super.key,
    required this.day,
    this.entry,
    this.isToday = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final pnl = entry?.amount ?? 0.0;
    final isPositive = pnl >= 0;
    final hasDetails =
        (entry?.note != null && entry!.note!.isNotEmpty) ||
        (entry?.breakdown != null && entry!.breakdown!.isNotEmpty);

    String pnlString;
    if (pnl == 0.0) {
      pnlString = "0";
    } else {
      final compactFormat = NumberFormat.compact();
      // Outputs +15K, -1.5M, etc.
      pnlString = "${isPositive ? '+' : ''}${compactFormat.format(pnl.abs())}";
    }
    final pnlColor = pnl == 0.0
        ? Colors.tealAccent.shade700
        : (isPositive ? Colors.greenAccent : Colors.redAccent);

    return Container(
      margin: const .all(4.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade800 : null,
        borderRadius: .circular(8.0),
        border: isToday && !isSelected
            ? Border.all(color: Colors.grey.shade600, width: 1)
            : null,
      ),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Text(
            '${day.day}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: .bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const .symmetric(horizontal: 2.0),
            child: Row(
              mainAxisAlignment: .center,
              mainAxisSize: .min,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: .scaleDown,
                    child: Text(
                      pnlString,
                      style: TextStyle(
                        color: pnlColor,
                        fontSize: 12,
                        fontWeight: .w500,
                      ),
                    ),
                  ),
                ),
                if (hasDetails) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.circle, size: 4, color: Colors.grey),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
