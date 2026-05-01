import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/utils/formatters.dart';
import 'package:pal_journal/components/buttons.dart';

const String _tagsKey = 'user_preset_tags';
const List<String> _defaultTags = [
  'Food',
  'Transport',
  'Salary',
  'Bills',
  'Shopping',
  'Allowance',
  'Leisure',
];

Future<ExpenseItem?> showAddBreakdownDialog(BuildContext context) {
  return showDialog<ExpenseItem>(
    context: context,
    builder: (context) =>
        const BreakdownDialogForm(contextText: "Add Breakdown"),
  );
}

Future<ExpenseItem?> showEditBreakdownDialog(
  BuildContext context,
  ExpenseItem currentItem,
) {
  return showDialog<ExpenseItem>(
    context: context,
    builder: (context) => BreakdownDialogForm(
      contextText: "Edit Breakdown",
      itemToEdit: currentItem,
    ),
  );
}

class BreakdownDialogForm extends StatefulWidget {
  final String contextText;
  final ExpenseItem? itemToEdit;

  const BreakdownDialogForm({
    super.key,
    required this.contextText,
    this.itemToEdit,
  });

  @override
  State<BreakdownDialogForm> createState() => _BreakdownDialogFormState();
}

class _BreakdownDialogFormState extends State<BreakdownDialogForm> {
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
    if (mounted) {
      setState(() {
        _currentTags = prefs.getStringList(_tagsKey) ?? List.from(_defaultTags);
        _isLoadingTags = false;
      });
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveAndPop() {
    final value = AppFormatters.parseCurrency(_amountController.text);
    if (_categoryController.text.isNotEmpty && value != 0.0) {
      Navigator.pop(
        context,
        ExpenseItem()
          ..category = _categoryController.text
          ..amount = value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
          : _buildTagsWrap(colors),

      const SizedBox(height: 16),
      TextField(
        controller: _amountController,
        keyboardType: const .numberWithOptions(decimal: true, signed: true),
        inputFormatters: [PnLFormatter()],
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: "Amount", prefixText: "₱ "),
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

  Widget _buildTagsWrap(ColorScheme colors) {
    final chips = _currentTags.map((tag) {
      return ActionChip(
        label: Text(
          tag,
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        backgroundColor: Colors.white10,
        side: .none,
        shape: RoundedRectangleBorder(borderRadius: .circular(8)),
        onPressed: () {
          _categoryController.text = tag;
          _categoryController.selection = .fromPosition(
            TextPosition(offset: _categoryController.text.length),
          );
        },
      );
    }).toList();

    chips.add(
      ActionChip(
        label: Row(
          mainAxisSize: .min,
          children: [
            Icon(Icons.edit, size: 12, color: colors.primary),
            SizedBox(width: 4),
            Text("Edit", style: TextStyle(fontSize: 12, color: colors.primary)),
          ],
        ),
        backgroundColor: colors.primaryContainer.withValues(alpha: 0.1),
        side: .none,
        shape: RoundedRectangleBorder(borderRadius: .circular(8)),
        onPressed: () async {
          final updatedTags = await showDialog<List<String>>(
            context: context,
            builder: (context) => TagEditorDialog(currentTags: _currentTags),
          );
          if (updatedTags != null && mounted) {
            setState(() {
              _currentTags = updatedTags;
            });
          }
        },
      ),
    );

    return Wrap(spacing: 8.0, runSpacing: 8.0, children: chips);
  }
}

class TagEditorDialog extends StatefulWidget {
  final List<String> currentTags;
  const TagEditorDialog({super.key, required this.currentTags});

  @override
  State<TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<TagEditorDialog> {
  late final TextEditingController _newTagController;
  late final List<String> _editableTags;

  @override
  void initState() {
    super.initState();
    _newTagController = TextEditingController();
    _editableTags = List.from(widget.currentTags);
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  Future<void> _savePrefsAndPop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_tagsKey, _editableTags);
    if (mounted) Navigator.pop(context, _editableTags);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final dialogContent = [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newTagController,
              decoration: const InputDecoration(hintText: "New Tag Name"),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, color: colors.primary),
            onPressed: () {
              if (_newTagController.text.isNotEmpty) {
                setState(() {
                  _editableTags.add(_newTagController.text.trim());
                  _newTagController.clear();
                });
              }
            },
          ),
        ],
      ),
      const SizedBox(height: 16),
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 250),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _editableTags.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: .zero,
              title: Text(_editableTags[index]),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
                onPressed: () {
                  setState(() {
                    _editableTags.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
      ),
    ];

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Edit Tags"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(mainAxisSize: .min, children: dialogContent),
      ),
      actions: [
        DialogCancelButton(),
        TextButton(
          onPressed: _savePrefsAndPop,
          child: Text("Save", style: TextStyle(color: colors.primary)),
        ),
      ],
    );
  }
}
