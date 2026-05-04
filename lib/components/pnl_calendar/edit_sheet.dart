import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/main.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
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

  // --- THE ALGEBRAIC MATH ENGINE ---
  double get _currentTotal =>
      AppFormatters.parseCurrency(_amountController.text);

  double get _allocatedAmount =>
      _currentBreakdown.fold(0.0, (sum, item) => sum + (item.amount ?? 0.0));

  double get _difference => _currentTotal - _allocatedAmount;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.entry != null && widget.entry!.amount != 0.0
          ? _getCurrency(widget.entry!.amount)
          : '',
    );
    _noteController = TextEditingController(text: widget.entry?.note ?? '');
    _currentBreakdown =
        widget.entry?.breakdown
            ?.map(
              (e) => ExpenseItem()
                ..category = e.category
                ..amount = CurrencyService.toDisplay(e.amount ?? 0.0),
            )
            .toList() ??
        [];

    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {}); // Triggers rebuild to update the visual tracker
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveData() async {
    // --- SMART AUTO-SYNC ---
    // If they have breakdowns, the breakdown sum is the ultimate source of truth.
    // If they forgot to tap the sync button, we do it for them!
    double finalDisplayAmount = _currentTotal;
    if (_currentBreakdown.isNotEmpty && _difference != 0) {
      finalDisplayAmount = _allocatedAmount;
    }

    final finalBaseAmount = CurrencyService.toBase(finalDisplayAmount);
    final baseBreakdown = _currentBreakdown.map((item) {
      return ExpenseItem()
        ..category = item.category
        ..amount = CurrencyService.toBase(item.amount ?? 0.0);
    }).toList();

    await isarService.savePnL(
      widget.day,
      finalBaseAmount,
      note: _noteController.text,
      breakdown: baseBreakdown,
    );
    if (mounted) Navigator.pop(context, true);
  }

  void _clearData() async {
    await isarService.deletePnLForDate(widget.day);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final symbol = CurrencyService.symbol;

    final amountTextField = TextField(
      controller: _amountController,
      keyboardType: const .numberWithOptions(decimal: true, signed: true),
      inputFormatters: [PnLFormatter()],
      style: const TextStyle(fontSize: 24),
      decoration: InputDecoration(
        hintText: "0.00",
        prefixText: "$symbol ",
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

    // --- THE SMART TRACKER UI ---
    final trackerColor = _difference == 0 ? colors.primary : colors.tertiary;
    final currency = _getCurrency(_difference.abs());
    final trackerText = _difference == 0
        ? "Balanced"
        : "Tap to Sync (Diff: $symbol$currency)";

    final breakDownHeaderRow = Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              "Breakdown",
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontWeight: .bold,
              ),
            ),

            // Only show the tracker/sync button if there are actually breakdowns
            if (_currentBreakdown.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Instantly updates the main total to match the breakdown!
                  setState(() {
                    _amountController.text = _getCurrency(_allocatedAmount);
                  });
                },
                child: Row(
                  children: [
                    if (_difference != 0)
                      Icon(Icons.sync, size: 12, color: trackerColor),
                    if (_difference != 0) const SizedBox(width: 4),
                    Text(
                      trackerText,
                      style: TextStyle(
                        color: trackerColor,
                        fontSize: 12,
                        fontWeight: .bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        TextButton.icon(
          onPressed: () async {
            // We pass the exact algebraic difference into the dialog to auto-fill it!
            final newItem = await showAddBreakdownDialog(context, _difference);
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
    // The form is always valid now, because our Save method safely auto-syncs!
    final bool isFormValid =
        _amountController.text.isNotEmpty || _currentBreakdown.isNotEmpty;

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
      onPressed: isFormValid ? _saveData : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        disabledBackgroundColor: colors.surfaceContainerHighest,
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
      final symbol = CurrencyService.symbol;
      final currency = _getCurrency(item.amount ?? 0.0);

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
            // When editing, the allowance is the current
            // difference PLUS the item's own value
            final editAllowance = _difference + (item.amount ?? 0.0);
            final editedItem = await showEditBreakdownDialog(
              context,
              item,
              editAllowance,
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
              Text("$symbol $currency"),
            ],
          ),
        ),
      );
    });
  }
}

String _getCurrency(double amount) => AppFormatters.toCurrency(amount);
