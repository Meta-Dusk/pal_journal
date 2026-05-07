import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/utils/formatters.dart';
import 'package:pal_journal/components/buttons.dart';
import 'package:pal_journal/core/default_data.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'tag_editor_dialog.dart';
import 'tags_wrap.dart';

Future<ExpenseItem?> showAddBreakdownDialog(
  BuildContext context,
  double unallocatedAmount,
) {
  return showDialog<ExpenseItem>(
    context: context,
    builder: (context) => _BreakdownDialogForm(
      contextText: "Add Breakdown",
      unallocatedAmount: unallocatedAmount,
    ),
  );
}

Future<ExpenseItem?> showEditBreakdownDialog(
  BuildContext context,
  ExpenseItem currentItem,
  double unallocatedAmount,
) {
  return showDialog<ExpenseItem>(
    context: context,
    builder: (context) => _BreakdownDialogForm(
      contextText: "Edit Breakdown",
      itemToEdit: currentItem,
      unallocatedAmount: unallocatedAmount,
    ),
  );
}

class _BreakdownDialogForm extends StatefulWidget {
  final String contextText;
  final ExpenseItem? itemToEdit;
  final double unallocatedAmount;

  const _BreakdownDialogForm({
    required this.contextText,
    required this.unallocatedAmount,
    this.itemToEdit,
  });

  @override
  State<_BreakdownDialogForm> createState() => _BreakdownDialogFormState();
}

class _BreakdownDialogFormState extends State<_BreakdownDialogForm> {
  late final TextEditingController _categoryController;
  late final TextEditingController _amountController;
  List<String> _currentTags = [];
  bool _isLoadingTags = true;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(
      text: widget.itemToEdit?.category ?? "",
    );
    _amountController = TextEditingController(
      text: widget.itemToEdit?.amount != null
          ? AppFormatters.toCurrency(widget.itemToEdit!.amount!)
          : "",
    );
    _loadTags();
  }

  Future<void> _loadTags() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _currentTags = prefs.getStringList(tagsKey) ?? List.from(defaultTags);
      _isLoadingTags = false;
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// The Smart Save Logic
  void _saveAndPop() {
    final textInput = _amountController.text.trim();
    double value;

    if (textInput.isEmpty) {
      // RULE 1: Auto-fill with the exact mathematical difference!
      value = widget.unallocatedAmount;
    } else {
      // RULE 2: Just parse it.
      value = AppFormatters.parseCurrency(textInput);
    }

    // Fallback if they forget to pick a category
    if (_categoryController.text.trim().isEmpty) {
      _categoryController.text = "Uncategorized";
    }

    if (value != 0.0) {
      final item = ExpenseItem()
        ..category = _categoryController.text.trim()
        ..amount = value;
      Navigator.pop(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final currency = AppFormatters.toCurrency(widget.unallocatedAmount);
    final symbol = CurrencyService.symbol;
    final dialogContent = [
      TextField(
        controller: _categoryController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: "Category (e.g. Allowance)",
        ),
      ),
      const SizedBox(height: 16),

      _isLoadingTags
          ? CircularProgressIndicator(color: colors.primary)
          : TagsWrap(
              tags: _currentTags,
              categoryController: _categoryController,
              onEditAction: _onEditAction,
            ),

      const SizedBox(height: 16),
      TextField(
        controller: _amountController,
        keyboardType: const .numberWithOptions(decimal: true, signed: true),
        inputFormatters: [PnLFormatter()],
        decoration: InputDecoration(
          // Remind the user exactly how much space they have left
          hintText: "Remaining: $symbol$currency",
          prefixText: "$symbol ",
        ),
      ),
    ];

    return AlertDialog(
      title: Text(widget.contextText),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: dialogContent,
        ),
      ),
      actions: [
        DialogCancelButton(),
        TextButton(
          onPressed: _saveAndPop,
          child: Text("Save", style: TextStyle(color: colors.primary)),
        ),
      ],
    );
  }

  Future<void> _onEditAction() async {
    final updatedTags = await showDialog<List<String>>(
      context: context,
      builder: (context) => TagEditorDialog(currentTags: _currentTags),
    );
    if (updatedTags != null && mounted) {
      setState(() => _currentTags = updatedTags);
    }
  }
}
