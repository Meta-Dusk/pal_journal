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
    final colors = Theme.of(context).colorScheme;

    final amountTextField = TextField(
      controller: _amountController,
      keyboardType: const .numberWithOptions(decimal: true, signed: true),
      inputFormatters: [PnLFormatter()],
      style: const TextStyle(fontSize: 24),
      decoration: InputDecoration(
        hintText: "0.00",
        prefixText: "₱ ",
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: .none,
        ),
      ),
    );

    final noteTextField = TextField(
      controller: _noteController,
      decoration: InputDecoration(
        hintText: "Add a note...",
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: .none,
        ),
      ),
    );

    final breakDownHeaderRow = Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(
          "Breakdown",
          style: TextStyle(color: colors.onSurfaceVariant, fontWeight: .bold),
        ),
        TextButton.icon(
          onPressed: () async {
            final newItem = await showAddBreakdownDialog(context);
            if (newItem != null) {
              setState(() => _currentBreakdown.add(newItem));
            }
          },
          icon: Icon(Icons.add, size: 16, color: colors.primary),
          label: Text("Add Item", style: TextStyle(color: colors.primary)),
        ),
      ],
    );

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
            style: const TextStyle(fontSize: 20, fontWeight: .bold),
          ),
          const SizedBox(height: 16),
          amountTextField,
          const SizedBox(height: 12),
          noteTextField,
          const SizedBox(height: 16),
          breakDownHeaderRow,
          const SizedBox(height: 8),
          ...getDismissibles(_currentBreakdown, colors),
          const SizedBox(height: 24),
          getEntryControls(colors),
        ],
      ),
    );
  }

  Row getEntryControls(ColorScheme colors) {
    final resetButton = OutlinedButton(
      onPressed: _clearData,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error),
        padding: const .symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      ),
      child: const Text(
        "Reset",
        style: TextStyle(fontSize: 16, fontWeight: .bold),
      ),
    );

    final saveButton = ElevatedButton(
      onPressed: _saveData,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        padding: const .symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      ),
      child: const Text(
        "Save Entry",
        style: TextStyle(fontSize: 16, fontWeight: .bold),
      ),
    );

    return Row(
      children: [
        if (widget.entry != null && widget.entry!.amount != 0.0) ...[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const .only(right: 12.0),
              child: resetButton,
            ),
          ),
        ],
        Expanded(flex: 2, child: saveButton),
      ],
    );
  }

  Iterable<Dismissible> getDismissibles(
    List<ExpenseItem> breakdownList,
    ColorScheme colors,
  ) {
    return breakdownList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return Dismissible(
        key: UniqueKey(),
        background: Container(
          alignment: .centerLeft,
          padding: const .only(left: 20),
          margin: const .only(bottom: 8),
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: .circular(8),
          ),
          child: Icon(Icons.edit, color: colors.onSecondary),
        ),
        secondaryBackground: Container(
          alignment: .centerRight,
          padding: const .only(right: 20),
          margin: const .only(bottom: 8),
          decoration: BoxDecoration(
            color: colors.error,
            borderRadius: .circular(8),
          ),
          child: Icon(Icons.delete, color: colors.onError),
        ),
        confirmDismiss: (direction) async {
          if (direction == .endToStart) {
            setState(() => _currentBreakdown.removeAt(index));
            return true;
          } else if (direction == .startToEnd) {
            final editedItem = await showEditBreakdownDialog(context, item);
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
            color: colors.surfaceContainerHighest,
            borderRadius: .circular(8),
          ),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                item.category ?? "",
                style: const TextStyle(fontWeight: .bold),
              ),
              Text("₱ ${AppFormatters.toCurrency(item.amount ?? 0.0)}"),
            ],
          ),
        ),
      );
    });
  }
}
