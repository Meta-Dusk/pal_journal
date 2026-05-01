import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/utils/formatters.dart';

class DetailsSheet extends StatelessWidget {
  final DateTime day;
  final PnLEntry? entry;
  final VoidCallback onEditPressed;

  const DetailsSheet({
    super.key,
    required this.day,
    this.entry,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(day);

    return SingleChildScrollView(
      padding: const .all(24.0),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            entry != null
                ? "₱ ${AppFormatters.toCurrency(entry!.amount)}"
                : "No Data",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: .bold,
              color: Colors.white,
            ),
          ),
          if (entry?.note != null && entry!.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const .all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: .circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sticky_note_2, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry!.note!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (entry?.breakdown != null && entry!.breakdown!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "Breakdown",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...entry!.breakdown!.map(
              (item) => Padding(
                padding: const .symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      item.category ?? "Unknown",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "₱ ${item.amount?.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit),
              label: const Text("Edit Day"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.shade700,
                foregroundColor: Colors.black,
                padding: const .symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
