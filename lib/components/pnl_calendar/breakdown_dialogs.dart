import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/utils/formatters.dart';

// The storage key and the fallback defaults
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
  final categoryController = TextEditingController();
  final amountController = TextEditingController();

  return showBreakdownDialog(
    context,
    categoryController,
    amountController,
    contextText: "Add Breakdown",
  ).then((value) {
    categoryController.dispose();
    amountController.dispose();
    return value;
  });
}

Future<ExpenseItem?> showEditBreakdownDialog(
  BuildContext context,
  ExpenseItem currentItem,
) {
  final categoryController = TextEditingController(
    text: currentItem.category ?? "",
  );
  final amountController = TextEditingController(
    text: currentItem.amount != null
        ? AppFormatters.toCurrency(currentItem.amount!)
        : "",
  );

  return showBreakdownDialog(
    context,
    categoryController,
    amountController,
    contextText: "Edit Breakdown",
  ).then((value) {
    categoryController.dispose();
    amountController.dispose();
    return value;
  });
}

Future<ExpenseItem?> showBreakdownDialog(
  BuildContext context,
  TextEditingController categoryController,
  TextEditingController amountController, {
  final String contextText = "Add/Edit Breakdown",
}) async {
  // Fetch tags from local storage
  final prefs = await SharedPreferences.getInstance();
  List<String> currentTags =
      prefs.getStringList(_tagsKey) ?? List.from(_defaultTags);

  if (!context.mounted) return null;

  return showDialog<ExpenseItem>(
    context: context,
    builder: (context) {
      // StatefulBuilder allows us to refresh the tags without closing the dialog
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final dialogContent = [
            TextField(
              controller: categoryController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Category (e.g. Allowance)",
              ),
            ),
            const SizedBox(height: 16),

            // Pass the state setter so the helper can trigger a rebuild
            newPresetTags(
              context,
              currentTags,
              categoryController,
              setDialogState,
            ),

            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const .numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [PnLFormatter()],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Amount",
                prefixText: "₱ ",
              ),
            ),
          ];

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              contextText,
              style: const TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: dialogContent,
              ),
            ),
            actions: [
              cancelButton(context),
              addCurrencyButton(amountController, categoryController, context),
            ],
          );
        },
      );
    },
  );
}

TextButton addCurrencyButton(
  TextEditingController amountController,
  TextEditingController categoryController,
  BuildContext context,
) {
  return TextButton(
    onPressed: () {
      final value = AppFormatters.parseCurrency(amountController.text);
      if (categoryController.text.isNotEmpty && value != 0.0) {
        Navigator.pop(
          context,
          ExpenseItem()
            ..category = categoryController.text
            ..amount = value,
        );
      }
    },
    child: const Text("Save", style: TextStyle(color: Colors.tealAccent)),
  );
}

TextButton cancelButton(BuildContext context) {
  return TextButton(
    onPressed: () => Navigator.pop(context),
    child: const Text("Cancel"),
  );
}

// --- PRESET TAGS COMPONENTS ---

Wrap newPresetTags(
  BuildContext context,
  List<String> tags,
  TextEditingController categoryController,
  StateSetter setDialogState,
) {
  final chips = tags
      .map((tag) => newActionChip(tag, categoryController))
      .toList();

  final editActionChip = ActionChip(
    label: const Row(
      mainAxisSize: .min,
      children: [
        Icon(Icons.edit, size: 12, color: Colors.tealAccent),
        SizedBox(width: 4),
        Text("Edit", style: TextStyle(fontSize: 12, color: Colors.tealAccent)),
      ],
    ),
    backgroundColor: Colors.tealAccent.withValues(alpha: 0.1),
    side: .none,
    shape: RoundedRectangleBorder(borderRadius: .circular(8)),
    onPressed: () async {
      // Open the editor and wait for the updated list
      final updatedTags = await newTagEditorDialog(context, tags);
      if (updatedTags != null) {
        // Rebuild the wrap with the new tags
        setDialogState(() {
          tags.clear();
          tags.addAll(updatedTags);
        });
      }
    },
  );
  chips.add(editActionChip); // Add the Edit button at the end of the list

  return Wrap(spacing: 8.0, runSpacing: 8.0, children: chips);
}

ActionChip newActionChip(String tag, TextEditingController categoryController) {
  return ActionChip(
    label: Text(
      tag,
      style: const TextStyle(fontSize: 12, color: Colors.white70),
    ),
    backgroundColor: Colors.white10,
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: .circular(8)),
    onPressed: () {
      categoryController.text = tag;
      categoryController.selection = .fromPosition(
        TextPosition(offset: categoryController.text.length),
      );
    },
  );
}

Future<List<String>?> newTagEditorDialog(
  BuildContext context,
  List<String> currentTags,
) {
  // Create a local copy so we don't mutate the original until 'Save' is pressed
  List<String> editableTags = List.from(currentTags);
  final newTagController = TextEditingController();

  return showDialog<List<String>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final saveButton = IconButton(
            icon: const Icon(Icons.add, color: Colors.tealAccent),
            onPressed: () {
              if (newTagController.text.isNotEmpty) {
                setModalState(() {
                  editableTags.add(newTagController.text.trim());
                  newTagController.clear();
                });
              }
            },
          );

          final tagTextField = Expanded(
            child: TextField(
              controller: newTagController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "New Tag Name"),
            ),
          );

          final dialogContent = [
            Row(children: [tagTextField, saveButton]),
            const SizedBox(height: 16),
            scrollableTagsList(editableTags, setModalState),
          ];

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              "Edit Tags",
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(mainAxisSize: .min, children: dialogContent),
            ),
            actions: [
              cancelButton(context),
              savePrefsButton(editableTags, context),
            ],
          );
        },
      );
    },
  ).then((val) {
    newTagController.dispose();
    return val;
  });
}

/// Scrollable list of given tags with delete buttons.
ConstrainedBox scrollableTagsList(
  List<String> editableTags,
  StateSetter setModalState,
) {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxHeight: 250),
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: editableTags.length,
      itemBuilder: (context, index) {
        void onPressed() {
          setModalState(() {
            editableTags.removeAt(index);
          });
        }

        return ListTile(
          contentPadding: .zero,
          title: Text(
            editableTags[index],
            style: const TextStyle(color: Colors.white),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: onPressed,
          ),
        );
      },
    ),
  );
}

TextButton savePrefsButton(List<String> editableTags, BuildContext context) {
  return TextButton(
    onPressed: () async {
      // Save the new list to SharedPreferences permanently
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_tagsKey, editableTags);
      if (context.mounted) Navigator.pop(context, editableTags);
    },
    child: const Text("Save", style: TextStyle(color: Colors.tealAccent)),
  );
}
