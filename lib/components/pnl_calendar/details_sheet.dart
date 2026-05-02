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
    final colors = Theme.of(context).colorScheme;
    final formattedDate = DateFormat('MMMM d, yyyy').format(day);

    return SingleChildScrollView(
      padding: const .all(24.0),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            formattedDate,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            entry != null
                ? "₱ ${AppFormatters.toCurrency(entry!.amount)}"
                : "No Data",
            style: const TextStyle(fontSize: 32, fontWeight: .bold),
          ),
          if (entry?.note != null && entry!.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const .all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: .circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sticky_note_2,
                    color: colors.onSurfaceVariant,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry!.note!)),
                ],
              ),
            ),
          ],
          if (entry?.breakdown != null && entry!.breakdown!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              "Breakdown",
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: .bold,
              ),
            ),
            const SizedBox(height: 8),
            ...entry!.breakdown!.map(
              (item) => Padding(
                padding: const .symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(item.category ?? "Unknown"),
                    Text("₱ ${item.amount?.toStringAsFixed(2) ?? '0.00'}"),
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
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
                padding: const .symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
