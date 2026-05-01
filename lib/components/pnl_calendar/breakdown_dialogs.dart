import 'package:flutter/material.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/utils/formatters.dart';

Future<ExpenseItem?> showAddBreakdownDialog(BuildContext context) {
  String tempCategory = "";
  String tempAmount = "";

  return showDialog<ExpenseItem>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Add Breakdown", style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: .min,
        children: [
          TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Category (e.g. Allowance)",
            ),
            onChanged: (v) => tempCategory = v,
          ),
          TextField(
            keyboardType: const .numberWithOptions(decimal: true),
            inputFormatters: [PnLFormatter()],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Amount"),
            onChanged: (v) => tempAmount = v,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final amount = AppFormatters.parseCurrency(tempAmount);
            if (tempCategory.isNotEmpty) {
              Navigator.pop(
                context,
                ExpenseItem()
                  ..category = tempCategory
                  ..amount = amount,
              );
            }
          },
          child: const Text("Add"),
        ),
      ],
    ),
  );
}

Future<ExpenseItem?> showEditBreakdownDialog(
  BuildContext context,
  ExpenseItem currentItem,
) {
  String tempCategory = currentItem.category ?? "";
  String tempAmount = AppFormatters.toCurrency(currentItem.amount ?? 0.0);
  final categoryController = TextEditingController(text: tempCategory);
  final amountController = TextEditingController(text: tempAmount);

  return showDialog<ExpenseItem>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text(
        "Edit Breakdown",
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: .min,
        children: [
          TextField(
            controller: categoryController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Category (e.g. Allowance)",
            ),
            onChanged: (v) => tempCategory = v,
          ),
          TextField(
            controller: amountController,
            keyboardType: const .numberWithOptions(decimal: true),
            inputFormatters: [PnLFormatter()],
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Amount"),
            onChanged: (v) => tempAmount = v,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final val = AppFormatters.parseCurrency(tempAmount);
            if (tempCategory.isNotEmpty) {
              Navigator.pop(
                context,
                ExpenseItem()
                  ..category = tempCategory
                  ..amount = val,
              );
            }
          },
          child: const Text("Save"),
        ),
      ],
    ),
  ).then((value) {
    categoryController.dispose();
    amountController.dispose();
    return value;
  });
}
