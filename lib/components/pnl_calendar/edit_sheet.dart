import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/main.dart';
import 'breakdown_dialogs.dart';
import 'package:pal_journal/utils/formatters.dart';

class EditSheet extends StatefulWidget {
  final DateTime day;
  final PnLEntry? entry;

  const EditSheet({super.key, required this.day, this.entry});

  @override
  State<EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<EditSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late List<ExpenseItem> _currentBreakdown;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.entry != null && widget.entry!.amount != 0.0
          ? AppFormatters.toCurrency(widget.entry!.amount)
          : '',
    );
    _noteController = TextEditingController(text: widget.entry?.note ?? '');
    _currentBreakdown =
        widget.entry?.breakdown
            ?.map(
              (e) => ExpenseItem()
                ..category = e.category
                ..amount = e.amount,
            )
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveData() async {
    final amount = AppFormatters.parseCurrency(_amountController.text);
    await isarService.savePnL(
      widget.day,
      amount,
      note: _noteController.text,
      breakdown: _currentBreakdown.toList(),
    );
    //? Send 'true' back meaning data was saved
    if (mounted) Navigator.pop(context, true);
  }

  void _clearData() async {
    await isarService.deletePnLForDate(widget.day);
    //? Send 'true' back meaning data was deleted
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: .only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Text(
            "Edit ${DateFormat('MMMM d').format(widget.day)}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: .bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const .numberWithOptions(decimal: true, signed: true),
            inputFormatters: [PnLFormatter()],
            style: const TextStyle(fontSize: 24, color: Colors.white),
            decoration: InputDecoration(
              hintText: "0.00",
              prefixText: "₱ ",
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: .circular(12),
                borderSide: .none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Add a note...",
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: .circular(12),
                borderSide: .none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              const Text(
                "Breakdown",
                style: TextStyle(color: Colors.grey, fontWeight: .bold),
              ),
              TextButton.icon(
                onPressed: () async {
                  final newItem = await showAddBreakdownDialog(context);
                  if (newItem != null) {
                    setState(() => _currentBreakdown.add(newItem));
                  }
                },
                icon: const Icon(Icons.add, size: 16, color: Colors.tealAccent),
                label: const Text(
                  "Add Item",
                  style: TextStyle(color: Colors.tealAccent),
                ),
              ),
            ],
          ),
          ..._currentBreakdown.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Dismissible(
              key: UniqueKey(),
              background: Container(
                alignment: .centerLeft,
                padding: const .only(left: 20),
                margin: const .only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.8),
                  borderRadius: .circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              secondaryBackground: Container(
                alignment: .centerRight,
                padding: const .only(right: 20),
                margin: const .only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.8),
                  borderRadius: .circular(8),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == .endToStart) {
                  setState(() => _currentBreakdown.removeAt(index));
                  return true;
                } else if (direction == .startToEnd) {
                  final editedItem = await showEditBreakdownDialog(
                    context,
                    item,
                  );
                  if (editedItem != null) {
                    setState(() => _currentBreakdown[index] = editedItem);
                  }
                  return false;
                }
                return false;
              },
              child: Container(
                margin: const .only(bottom: 8),
                padding: const .all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: .circular(8),
                ),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      item.category ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: .bold,
                      ),
                    ),
                    Text(
                      "₱ ${AppFormatters.toCurrency(item.amount ?? 0.0)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              if (widget.entry != null && widget.entry!.amount != 0.0) ...[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const .only(right: 12.0),
                    child: OutlinedButton(
                      onPressed: _clearData,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const .symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: .circular(12),
                        ),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(fontSize: 16, fontWeight: .bold),
                      ),
                    ),
                  ),
                ),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.shade700,
                    foregroundColor: Colors.black,
                    padding: const .symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: .circular(12)),
                  ),
                  child: const Text(
                    "Save Entry",
                    style: TextStyle(fontSize: 16, fontWeight: .bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
